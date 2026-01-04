import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/referral_code.dart';
import '../../../core/utils/error_messages.dart';

/// 추천인 코드 Repository
///
/// referral_codes, referral_usage 테이블 관리
class ReferralCodeRepository {
  final SupabaseClient _supabase;

  ReferralCodeRepository(this._supabase);

  /// 내가 생성한 추천인 코드 목록 조회
  Future<List<ReferralCode>> getMyReferralCodes() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      final response = await _supabase
          .from('referral_codes')
          .select()
          .eq('created_by', session.user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReferralCode.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 새 추천인 코드 생성
  ///
  /// [schoolName]: 같은 학교 제약 검증용
  /// [maxUses]: 최대 사용 횟수 (기본 5회)
  /// [expiresInDays]: 만료일 (기본 30일)
  Future<ReferralCode> createReferralCode({
    required String schoolName,
    int maxUses = 5,
    int expiresInDays = 30,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      // 6자리 랜덤 코드 생성 (예: "SEOUL-ABC123")
      final code = _generateCode(schoolName);

      final data = {
        'code': code,
        'created_by': session.user.id,
        'school_name': schoolName,
        'max_uses': maxUses,
        'current_uses': 0,
        'expires_at': DateTime.now()
            .add(Duration(days: expiresInDays))
            .toIso8601String(),
        'is_active': true,
      };

      final response = await _supabase
          .from('referral_codes')
          .insert(data)
          .select()
          .single();

      return ReferralCode.fromJson(response);
    } on PostgrestException catch (e) {
      // 중복 코드 에러 처리
      if (e.code == '23505') {
        // Unique constraint violation
        throw Exception('코드 생성 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 추천인 코드 검증
  ///
  /// 코드가 유효한지 확인 (존재, 활성, 만료 안됨, 사용 횟수 남음)
  /// [userSchoolName]: 같은 학교인지 검증
  Future<ReferralCode?> validateCode(String code, String userSchoolName) async {
    try {
      final response = await _supabase
          .from('referral_codes')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw Exception('유효하지 않은 추천인 코드입니다');
      }

      final referralCode = ReferralCode.fromJson(response);

      // 같은 학교 제약 검증
      if (referralCode.schoolName != userSchoolName) {
        throw Exception('같은 학교의 추천인 코드만 사용할 수 있습니다');
      }

      // 만료 확인
      if (referralCode.expiresAt != null &&
          DateTime.now().isAfter(referralCode.expiresAt!)) {
        throw Exception('만료된 추천인 코드입니다');
      }

      // 사용 횟수 확인
      if (referralCode.currentUses >= referralCode.maxUses) {
        throw Exception('사용 가능 횟수를 초과한 추천인 코드입니다');
      }

      return referralCode;
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 추천인 코드 사용 처리
  ///
  /// referral_usage 테이블에 기록하고 current_uses 증가
  Future<void> useReferralCode(String codeId, String userId) async {
    try {
      // 1. 이미 사용했는지 확인
      final existing = await _supabase
          .from('referral_usage')
          .select()
          .eq('used_by', userId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('이미 추천인 코드를 사용하셨습니다');
      }

      // 2. 사용 기록 생성
      await _supabase.from('referral_usage').insert({
        'referral_code_id': codeId,
        'used_by': userId,
        'used_at': DateTime.now().toIso8601String(),
      });

      // 3. current_uses 증가
      await _supabase.rpc('increment_referral_uses', params: {
        'code_id': codeId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation
        throw Exception('이미 추천인 코드를 사용하셨습니다');
      }
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 코드 비활성화
  Future<void> deactivateCode(String codeId) async {
    try {
      await _supabase.from('referral_codes').update({
        'is_active': false,
      }).eq('id', codeId);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 코드 재활성화
  Future<void> reactivateCode(String codeId) async {
    try {
      await _supabase.from('referral_codes').update({
        'is_active': true,
      }).eq('id', codeId);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 6자리 랜덤 코드 생성 (예: "SEOUL-ABC123")
  String _generateCode(String schoolName) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // 학교명 앞 2글자 추출 (한글 → 로마자 변환 필요시 추가)
    final prefix = schoolName.length >= 2
        ? schoolName.substring(0, 2).toUpperCase()
        : 'XX';

    // 6자리 랜덤 문자열
    final suffix = List.generate(
      6,
      (index) => chars[random.nextInt(chars.length)],
    ).join();

    return '$prefix-$suffix';
  }
}
