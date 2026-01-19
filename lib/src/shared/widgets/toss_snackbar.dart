import 'package:flutter/material.dart';

/// 토스 스타일의 통일된 SnackBar 헬퍼 클래스
///
/// 사용법:
/// ```dart
/// TossSnackBar.show(context, message: '저장되었습니다');
/// TossSnackBar.success(context, message: '예약이 완료되었습니다');
/// TossSnackBar.error(context, message: '오류가 발생했습니다');
/// TossSnackBar.info(context, message: '알림 메시지');
/// ```
class TossSnackBar {
  TossSnackBar._();

  // 기본 지속 시간
  static const Duration _successDuration = Duration(seconds: 2);
  static const Duration _errorDuration = Duration(seconds: 3);
  static const Duration _infoDuration = Duration(seconds: 2);

  // 토스 스타일 색상
  static const Color _successColor = Color(0xFF3182F6); // 토스 블루
  static const Color _errorColor = Color(0xFFFF6B6B); // 부드러운 레드
  static const Color _infoColor = Color(0xFF6B7684); // 뉴트럴 그레이
  static const Color _warningColor = Color(0xFFFF9F43); // 부드러운 오렌지

  /// 기본 성공 메시지 (토스 블루)
  static void show(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: _successColor,
      icon: Icons.check_circle_rounded,
      duration: duration ?? _successDuration,
    );
  }

  /// 성공 메시지 (토스 블루 + 체크 아이콘)
  static void success(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: _successColor,
      icon: Icons.check_circle_rounded,
      duration: duration ?? _successDuration,
    );
  }

  /// 에러 메시지 (부드러운 레드 + 경고 아이콘)
  static void error(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: _errorColor,
      icon: Icons.error_rounded,
      duration: duration ?? _errorDuration,
    );
  }

  /// 정보 메시지 (뉴트럴 그레이 + 정보 아이콘)
  static void info(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: _infoColor,
      icon: Icons.info_rounded,
      duration: duration ?? _infoDuration,
    );
  }

  /// 경고 메시지 (부드러운 오렌지 + 경고 아이콘)
  static void warning(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: _warningColor,
      icon: Icons.warning_rounded,
      duration: duration ?? _errorDuration,
    );
  }

  /// 내부 SnackBar 표시 메서드
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    // 기존 SnackBar 제거 (중복 방지)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // 토스처럼 더 둥글게
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: duration,
        elevation: 2,
      ),
    );
  }
}
