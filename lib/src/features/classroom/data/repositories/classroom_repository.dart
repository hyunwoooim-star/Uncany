import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/classroom.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/app_logger.dart';

/// 교실 관리 Repository
///
/// classrooms 테이블 CRUD 및 비밀번호 보호 기능
class ClassroomRepository {
  final SupabaseClient _supabase;

  ClassroomRepository(this._supabase);

  /// 교실 목록 조회
  ///
  /// [activeOnly]가 true면 deleted_at이 null이고 is_active가 true인 교실만 조회
  Future<List<Classroom>> getClassrooms({bool activeOnly = true}) async {
    try {
      dynamic query = _supabase.from('classrooms').select();

      if (activeOnly) {
        query = query
            .isFilter('deleted_at', null)
            .eq('is_active', true);
      }

      // 이름순 정렬
      query = query.order('name', ascending: true);

      final response = await query;

      return (response as List)
          .map((json) => Classroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 특정 교실 조회
  Future<Classroom?> getClassroom(String id) async {
    try {
      final response = await _supabase
          .from('classrooms')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return Classroom.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실 생성 (모든 선생님 가능)
  ///
  /// [accessCode]를 제공하면 SHA-256 해시로 저장
  Future<Classroom> createClassroom({
    required String name,
    String? accessCode,
    String? noticeMessage,
    int? capacity,
    String? location,
    String? roomType,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      // 비밀번호 해싱 (제공된 경우만)
      String? hashedCode;
      if (accessCode != null && accessCode.isNotEmpty) {
        hashedCode = _hashAccessCode(accessCode);
      }

      final data = {
        'name': name,
        'access_code_hash': hashedCode,
        'notice_message': noticeMessage,
        'capacity': capacity,
        'location': location,
        'is_active': true,
        'room_type': roomType ?? 'other',
        'created_by': session.user.id,
      };

      final response = await _supabase
          .from('classrooms')
          .insert(data)
          .select()
          .single();

      return Classroom.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실 수정
  Future<void> updateClassroom(
    String id, {
    String? name,
    String? accessCode,
    bool? clearAccessCode, // 비밀번호 제거
    String? noticeMessage,
    bool? clearNotice, // 공지사항 제거
    int? capacity,
    String? location,
    bool? isActive,
    String? roomType,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;

      if (clearAccessCode == true) {
        updates['access_code_hash'] = null;
      } else if (accessCode != null && accessCode.isNotEmpty) {
        updates['access_code_hash'] = _hashAccessCode(accessCode);
      }

      if (clearNotice == true) {
        updates['notice_message'] = null;
        updates['notice_updated_at'] = null;
      } else if (noticeMessage != null) {
        updates['notice_message'] = noticeMessage;
        updates['notice_updated_at'] = DateTime.now().toIso8601String();
      }

      if (capacity != null) updates['capacity'] = capacity;
      if (location != null) updates['location'] = location;
      if (isActive != null) updates['is_active'] = isActive;
      if (roomType != null) updates['room_type'] = roomType;

      if (updates.isEmpty) return; // 변경 사항 없음

      await _supabase.from('classrooms').update(updates).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실 삭제 (Soft Delete)
  Future<void> deleteClassroom(String id) async {
    try {
      await _supabase.from('classrooms').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실 복원 (Soft Delete 취소)
  Future<void> restoreClassroom(String id) async {
    try {
      await _supabase.from('classrooms').update({
        'deleted_at': null,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 비밀번호 검증
  ///
  /// [classroomId]: 교실 ID
  /// [code]: 사용자가 입력한 비밀번호
  ///
  /// Returns: 비밀번호가 일치하면 true, 교실에 비밀번호가 없으면 true
  Future<bool> verifyAccessCode(String classroomId, String code) async {
    try {
      final classroom = await getClassroom(classroomId);

      if (classroom == null) {
        throw Exception('교실을 찾을 수 없습니다');
      }

      // 비밀번호가 설정되지 않은 교실
      if (classroom.accessCodeHash == null) {
        return true;
      }

      // 비밀번호 해싱 후 비교
      final hashedInput = _hashAccessCode(code);
      return hashedInput == classroom.accessCodeHash;
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실 활성화 상태 토글
  Future<void> toggleActiveStatus(String id) async {
    try {
      final classroom = await getClassroom(id);
      if (classroom == null) {
        throw Exception('교실을 찾을 수 없습니다');
      }

      await _supabase.from('classrooms').update({
        'is_active': !classroom.isActive,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 공지사항 업데이트
  Future<void> updateNotice(String id, String? message) async {
    try {
      await _supabase.from('classrooms').update({
        'notice_message': message,
        'notice_updated_at':
            message != null ? DateTime.now().toIso8601String() : null,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 비밀번호 해싱 (SHA-256)
  ///
  /// 프로덕션에서는 Argon2id 사용 권장 (별도 패키지 필요)
  String _hashAccessCode(String code) {
    final bytes = utf8.encode(code);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
