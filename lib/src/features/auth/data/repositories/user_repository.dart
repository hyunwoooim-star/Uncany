import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../domain/models/user.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/app_logger.dart';

/// 사용자 관리 Repository (관리자 전용)
///
/// users 테이블 CRUD 및 승인/반려 로직 처리
class UserRepository {
  final SupabaseClient _supabase;

  UserRepository(this._supabase);

  /// 사용자 목록 조회
  ///
  /// [status]로 인증 상태 필터링 가능
  /// [activeOnly]가 true면 deleted_at이 null인 사용자만 조회
  Future<List<User>> getUsers({
    VerificationStatus? status,
    bool activeOnly = true,
  }) async {
    try {
      dynamic query = _supabase.from('users').select();

      // Soft Delete 필터
      if (activeOnly) {
        query = query.isFilter('deleted_at', null);
      }

      // 인증 상태 필터
      if (status != null) {
        query = query.eq('verification_status', status.name);
      }

      // 최신순 정렬
      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.getUsers', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.getUsers', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 특정 사용자 조회
  Future<User?> getUser(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return User.fromJson(response);
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.getUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.getUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 사용자 승인
  ///
  /// verification_status를 'approved'로 변경
  Future<void> approveUser(String userId) async {
    try {
      await _supabase.from('users').update({
        'verification_status': VerificationStatus.approved.name,
        'updated_at': DateTime.now().toIso8601String(),
        'rejected_reason': null, // 반려 사유 초기화
      }).eq('id', userId);

      // TODO: 승인 알림 발송 (Phase 3)
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.approveUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.approveUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 사용자 반려
  ///
  /// verification_status를 'rejected'로 변경하고 사유 저장
  Future<void> rejectUser(String userId, String reason) async {
    try {
      if (reason.trim().isEmpty) {
        throw Exception('반려 사유를 입력해주세요');
      }

      await _supabase.from('users').update({
        'verification_status': VerificationStatus.rejected.name,
        'rejected_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // TODO: 반려 알림 발송 (Phase 3)
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.rejectUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.rejectUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 사용자 역할 변경
  ///
  /// [role]을 teacher 또는 admin으로 변경
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _supabase.from('users').update({
        'role': role.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.updateUserRole', e, stack, {'userId': userId, 'role': role.name});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.updateUserRole', e, stack, {'userId': userId, 'role': role.name});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 사용자 삭제 (Soft Delete)
  ///
  /// deleted_at 필드 업데이트
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.deleteUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.deleteUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 사용자 복원 (Soft Delete 취소)
  ///
  /// deleted_at을 null로 설정
  Future<void> restoreUser(String userId) async {
    try {
      await _supabase.from('users').update({
        'deleted_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.restoreUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.restoreUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 사용자 완전 삭제 (Hard Delete - 관리자 전용)
  ///
  /// users 테이블에서 완전히 삭제 (복구 불가)
  /// 관련 데이터 (예약, 추천인 코드 등)도 함께 처리됨 (CASCADE or SET NULL)
  Future<void> hardDeleteUser(String userId) async {
    try {
      // 1. 사용자의 예약 soft delete
      await _supabase.from('reservations').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('teacher_id', userId);

      // 2. 사용자의 추천인 코드 비활성화
      await _supabase.from('referral_codes').update({
        'is_active': false,
      }).eq('created_by', userId);

      // 3. users 테이블에서 삭제
      await _supabase.from('users').delete().eq('id', userId);

      // 참고: Supabase Auth의 사용자는 Admin API로만 삭제 가능
      // 클라이언트에서는 접근 불가. 필요시 Edge Function이나 백엔드 API 필요
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.hardDeleteUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.hardDeleteUser', e, stack, {'userId': userId});
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 승인 대기 중인 사용자 수 조회
  ///
  /// 관리자 대시보드 배지 표시용
  Future<int> getPendingCount() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('verification_status', VerificationStatus.pending.name)
          .isFilter('deleted_at', null);

      return (response as List).length;
    } on PostgrestException catch (e, stack) {
      AppLogger.error('UserRepository.getPendingCount', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('UserRepository.getPendingCount', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }
}
