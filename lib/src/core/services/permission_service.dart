import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 권한 관리 서비스 (Android 13+ 대응)
class PermissionService {
  PermissionService._();

  /// 사진 라이브러리 권한 요청 (Android 13+ 대응)
  ///
  /// - Android 13+ (API 33+): READ_MEDIA_IMAGES
  /// - Android 12 이하: READ_EXTERNAL_STORAGE
  /// - iOS: Photos Library
  static Future<bool> requestPhotoLibraryPermission() async {
    if (kIsWeb) return true; // Web은 권한 불필요

    try {
      // Android
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 33) {
          // Android 13+: READ_MEDIA_IMAGES
          final status = await Permission.photos.request();
          return status.isGranted || status.isLimited;
        } else {
          // Android 12 이하: READ_EXTERNAL_STORAGE
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      }

      // iOS
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        // iOS는 limited 허용 (일부 사진만 접근)
        return status.isGranted || status.isLimited;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ 권한 요청 실패: $e');
      return false;
    }
  }

  /// 카메라 권한 요청
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;

    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('⚠️ 카메라 권한 요청 실패: $e');
      return false;
    }
  }

  /// 권한 상태 확인 (요청 없이)
  static Future<bool> checkPhotoLibraryPermission() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 33) {
          final status = await Permission.photos.status;
          return status.isGranted || status.isLimited;
        } else {
          final status = await Permission.storage.status;
          return status.isGranted;
        }
      }

      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        return status.isGranted || status.isLimited;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ 권한 상태 확인 실패: $e');
      return false;
    }
  }

  /// 권한이 영구 거부되었는지 확인
  static Future<bool> isPermissionPermanentlyDenied() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        final permission =
            androidVersion >= 33 ? Permission.photos : Permission.storage;

        final status = await permission.status;
        return status.isPermanentlyDenied;
      }

      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        return status.isPermanentlyDenied;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ 권한 거부 상태 확인 실패: $e');
      return false;
    }
  }

  /// 설정 화면 열기
  static Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('⚠️ 설정 화면 열기 실패: $e');
    }
  }

  /// Android 버전 확인 (내부 헬퍼)
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return deviceInfo.version.sdkInt;
    } catch (e) {
      debugPrint('⚠️ Android 버전 확인 실패: $e');
      return 30; // 기본값 (Android 11)
    }
  }
}
