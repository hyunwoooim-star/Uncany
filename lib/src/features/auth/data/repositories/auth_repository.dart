import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../domain/models/user.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/app_logger.dart';

/// 인증 관련 Repository
///
/// Supabase Auth와 users 테이블을 연동하여 인증 로직을 처리합니다.
class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// 현재 로그인된 사용자 정보 조회
  ///
  /// Supabase Auth 세션과 users 테이블을 조인하여 완전한 User 객체 반환
  Future<User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (response == null) return null;

      return User.fromJson(response);
    } on PostgrestException catch (e, stack) {
      AppLogger.error('AuthRepository.getCurrentUser', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.getCurrentUser', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 로그아웃
  ///
  /// Supabase 세션을 종료하고 로컬 저장소 초기화
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e, stack) {
      AppLogger.error('AuthRepository.signOut', e, stack);
      throw Exception(ErrorMessages.fromAuthError(e.message));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.signOut', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 프로필 정보 업데이트
  ///
  /// users 테이블의 name, school_name, grade, class_num 필드 수정
  Future<void> updateProfile({
    String? name,
    String? schoolName,
    int? grade,
    int? classNum,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (schoolName != null) updates['school_name'] = schoolName;
      if (grade != null) updates['grade'] = grade;
      if (classNum != null) updates['class_num'] = classNum;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', session.user.id);
    } on PostgrestException catch (e, stack) {
      AppLogger.error('AuthRepository.updateProfile', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.updateProfile', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 비밀번호 재설정 이메일 발송
  ///
  /// Supabase가 자동으로 비밀번호 재설정 링크를 이메일로 전송
  /// 환경에 따라 적절한 Redirect URL 사용
  Future<void> resetPassword(String email) async {
    try {
      // 환경에 따라 Redirect URL 결정
      // kDebugMode: 로컬 개발 환경
      // Release: Staging/Production 환경
      final redirectUrl = kDebugMode
          ? 'http://localhost:3000/auth/reset-password'
          : 'https://uncany-staging.web.app/auth/reset-password';

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
    } on AuthException catch (e, stack) {
      AppLogger.error('AuthRepository.resetPassword', e, stack, {'email': email});
      throw Exception(ErrorMessages.fromAuthError(e.message));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.resetPassword', e, stack, {'email': email});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 비밀번호 변경
  ///
  /// 로그인된 사용자의 비밀번호 업데이트
  Future<void> updatePassword(String newPassword) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e, stack) {
      AppLogger.error('AuthRepository.updatePassword', e, stack);
      throw Exception(ErrorMessages.fromAuthError(e.message));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.updatePassword', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 계정 삭제 (Soft Delete)
  ///
  /// users 테이블의 deleted_at 필드 업데이트
  Future<void> deleteAccount() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      await _supabase
          .from('users')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', session.user.id);

      // Supabase Auth 세션 종료
      await _supabase.auth.signOut();
    } on PostgrestException catch (e, stack) {
      AppLogger.error('AuthRepository.deleteAccount', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.deleteAccount', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }


  /// 인증 이메일 재발송
  ///
  /// 회원가입 후 이메일 인증을 완료하지 않은 사용자에게 재발송
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e, stack) {
      AppLogger.error('AuthRepository.resendVerificationEmail', e, stack, {'email': email});
      throw Exception(ErrorMessages.fromAuthError(e.message));
    } catch (e, stack) {
      AppLogger.error('AuthRepository.resendVerificationEmail', e, stack, {'email': email});
      throw Exception(ErrorMessages.fromError(e));
    }
  }
}