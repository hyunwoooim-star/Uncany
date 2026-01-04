import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/reservation.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 예약 관리 Repository
///
/// reservations 테이블 CRUD 및 충돌 검증
class ReservationRepository {
  final SupabaseClient _supabase;

  ReservationRepository(this._supabase);

  /// 내 예약 목록 조회
  ///
  /// [startDate], [endDate]로 기간 필터링 가능
  Future<List<Reservation>> getMyReservations({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      var query = _supabase
          .from('reservations')
          .select()
          .eq('teacher_id', session.user.id)
          .isFilter('deleted_at', null);

      // 기간 필터
      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('end_time', endDate.toIso8601String());
      }

      // 시작 시간 기준 정렬
      query = query.order('start_time', ascending: true);

      final response = await query;

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실별 예약 목록 조회
  ///
  /// 특정 날짜의 모든 예약 조회
  Future<List<Reservation>> getReservationsByClassroom(
    String classroomId, {
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('reservations')
          .select()
          .eq('classroom_id', classroomId)
          .isFilter('deleted_at', null)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('end_time', endOfDay.toIso8601String())
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 특정 예약 조회
  Future<Reservation?> getReservation(String id) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return Reservation.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 예약 충돌 검증
  ///
  /// 같은 교실, 같은 시간에 다른 예약이 있는지 확인
  Future<bool> hasConflict(
    String classroomId,
    DateTime startTime,
    DateTime endTime, {
    String? excludeReservationId, // 수정 시 자기 자신 제외
  }) async {
    try {
      var query = _supabase
          .from('reservations')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('classroom_id', classroomId)
          .isFilter('deleted_at', null);

      // 자기 자신 제외 (예약 수정 시)
      if (excludeReservationId != null) {
        query = query.neq('id', excludeReservationId);
      }

      // 시간 중복 조건: (start_time < end_time_param AND end_time > start_time_param)
      query = query
          .lt('start_time', endTime.toIso8601String())
          .gt('end_time', startTime.toIso8601String());

      final response = await query;

      return (response.count ?? 0) > 0;
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 예약 생성
  ///
  /// 충돌 검증 후 reservations 테이블에 INSERT
  Future<Reservation> createReservation({
    required String classroomId,
    required DateTime startTime,
    required DateTime endTime,
    String? title,
    String? description,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      // 시간 유효성 검증
      if (!endTime.isAfter(startTime)) {
        throw Exception('종료 시간은 시작 시간보다 늦어야 합니다');
      }

      // 과거 시간 검증
      if (startTime.isBefore(DateTime.now())) {
        throw Exception('과거 시간으로 예약할 수 없습니다');
      }

      // 충돌 검증
      final hasConflict = await this.hasConflict(
        classroomId,
        startTime,
        endTime,
      );

      if (hasConflict) {
        throw Exception('이미 예약된 시간입니다');
      }

      final data = {
        'classroom_id': classroomId,
        'teacher_id': session.user.id,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'title': title,
        'description': description,
      };

      final response = await _supabase
          .from('reservations')
          .insert(data)
          .select()
          .single();

      return Reservation.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 예약 수정
  Future<void> updateReservation(
    String id, {
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? description,
  }) async {
    try {
      // 기존 예약 조회
      final existing = await getReservation(id);
      if (existing == null) {
        throw Exception('예약을 찾을 수 없습니다');
      }

      final updates = <String, dynamic>{};

      if (startTime != null) updates['start_time'] = startTime.toIso8601String();
      if (endTime != null) updates['end_time'] = endTime.toIso8601String();
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;

      // 시간 변경 시 충돌 검증
      if (startTime != null || endTime != null) {
        final newStartTime = startTime ?? existing.startTime;
        final newEndTime = endTime ?? existing.endTime;

        if (!newEndTime.isAfter(newStartTime)) {
          throw Exception('종료 시간은 시작 시간보다 늦어야 합니다');
        }

        final hasConflict = await this.hasConflict(
          existing.classroomId,
          newStartTime,
          newEndTime,
          excludeReservationId: id,
        );

        if (hasConflict) {
          throw Exception('이미 예약된 시간입니다');
        }
      }

      if (updates.isEmpty) return; // 변경 사항 없음

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('reservations').update(updates).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 예약 취소 (Soft Delete)
  Future<void> cancelReservation(String id) async {
    try {
      await _supabase.from('reservations').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 예약 복원 (Soft Delete 취소)
  Future<void> restoreReservation(String id) async {
    try {
      await _supabase.from('reservations').update({
        'deleted_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 오늘의 예약 수 조회
  Future<int> getTodayReservationCount() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return 0;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('reservations')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('teacher_id', session.user.id)
          .isFilter('deleted_at', null)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('end_time', endOfDay.toIso8601String());

      return response.count ?? 0;
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }
}
