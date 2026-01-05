import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 전역 로깅 서비스
///
/// 개발 환경: 콘솔 출력
/// 프로덕션 환경: Supabase app_logs 테이블에 저장
class AppLogger {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 에러 로깅
  static Future<void> error(
    String tag,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? extraData,
  ]) async {
    final message = error.toString();
    final data = {
      'error': message,
      if (stackTrace != null) 'stack_trace': stackTrace.toString().split('\n').take(10).join('\n'),
      if (extraData != null) ...extraData,
    };

    await _log('error', tag, message, data);
  }

  /// 정보 로깅
  static Future<void> info(String tag, String message, [Map<String, dynamic>? data]) async {
    await _log('info', tag, message, data);
  }

  /// 사용자 액션 로깅 (회원가입, 로그인, 예약 등)
  static Future<void> action(
    String tag,
    String action, [
    Map<String, dynamic>? data,
  ]) async {
    await _log('action', tag, action, data);
  }

  /// 경고 로깅
  static Future<void> warning(String tag, String message, [Map<String, dynamic>? data]) async {
    await _log('warning', tag, message, data);
  }

  /// 내부 로깅 메서드
  static Future<void> _log(
    String level,
    String tag,
    String message,
    Map<String, dynamic>? data,
  ) async {
    final timestamp = DateTime.now().toIso8601String();
    final userId = _supabase.auth.currentUser?.id;

    // 개발 환경: 콘솔 출력
    if (kDebugMode) {
      final emoji = switch (level) {
        'error' => '❌',
        'warning' => '⚠️',
        'action' => '🎯',
        _ => 'ℹ️',
      };
      debugPrint('$emoji [$level] $tag: $message');
      if (data != null) {
        debugPrint('   Data: ${jsonEncode(data)}');
      }
      return;
    }

    // 프로덕션 환경: Supabase 저장
    try {
      await _supabase.from('app_logs').insert({
        'level': level,
        'tag': tag,
        'message': message,
        'data': data,
        'user_id': userId,
        'created_at': timestamp,
      });
    } catch (e) {
      // 로깅 실패는 무시 (무한 루프 방지)
      debugPrint('로깅 실패: $e');
    }
  }
}
