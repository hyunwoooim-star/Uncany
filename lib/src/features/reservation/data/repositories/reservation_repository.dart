import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/reservation.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/app_logger.dart';
import 'package:uncany/src/core/constants/period_times.dart';

/// 예약 관리 Repository (v0.2)
///
/// 교시(period) 기반 예약 시스템
/// reservations 테이블 CRUD 및 충돌 검증
class ReservationRepository {
  final SupabaseClient _supabase;

  ReservationRepository(this._supabase);

  /// 내 예약 목록 조회
  ///
  /// [startDate], [endDate]로 기간 필터링 가능
  /// classroom 정보 JOIN 포함
  Future<List<Reservation>> getMyReservations({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      // classroom 정보 JOIN 포함
      var query = _supabase
          .from('reservations')
          .select('''
            *,
            classrooms:classroom_id (
              name,
              room_type,
              location
            )
          ''')
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
      final response = await query.order('start_time', ascending: true);

      return (response as List).map((item) {
        final json = item as Map<String, dynamic>;
        final classroomData = json['classrooms'] as Map<String, dynamic>?;
        return Reservation.fromJson({
          ...json,
          'classroom_name': classroomData?['name'],
          'classroom_room_type': classroomData?['room_type'],
          'classroom_location': classroomData?['location'],
        });
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교실별 예약 목록 조회 (특정 날짜)
  ///
  /// 예약자 정보 (이름, 학년, 반)를 함께 조회
  Future<List<Reservation>> getReservationsByClassroom(
    String classroomId, {
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('reservations')
          .select('''
            *,
            users:teacher_id (
              name,
              grade,
              class_num
            )
          ''')
          .eq('classroom_id', classroomId)
          .isFilter('deleted_at', null)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String())
          .order('start_time', ascending: true);

      return (response as List).map((item) {
        // users 관계에서 정보 추출
        final json = item as Map<String, dynamic>;
        final userData = json['users'] as Map<String, dynamic>?;
        return Reservation.fromJson({
          ...json,
          'teacher_name': userData?['name'],
          'teacher_grade': userData?['grade'],
          'teacher_class_num': userData?['class_num'],
        });
      }).toList();
    } on PostgrestException catch (e, stack) {
      AppLogger.error('ReservationRepository.getReservationsByClassroom', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('ReservationRepository.getReservationsByClassroom', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 특정 예약 조회
  Future<Reservation?> getReservation(String id) async {
    try {
      final response = await _supabase
          .from('reservations')
          .select('''
            *,
            users:teacher_id (
              name,
              grade,
              class_num
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      final userData = response['users'] as Map<String, dynamic>?;
      return Reservation.fromJson({
        ...response,
        'teacher_name': userData?['name'],
        'teacher_grade': userData?['grade'],
        'teacher_class_num': userData?['class_num'],
      });
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교시 기반 충돌 검증
  ///
  /// 같은 교실, 같은 날짜, 같은 교시에 다른 예약이 있는지 확인
  Future<List<int>> getConflictingPeriods(
    String classroomId,
    DateTime date,
    List<int> periods, {
    String? excludeReservationId,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      var query = _supabase
          .from('reservations')
          .select('periods')
          .eq('classroom_id', classroomId)
          .isFilter('deleted_at', null)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String());

      // 자기 자신 제외 (예약 수정 시)
      if (excludeReservationId != null) {
        query = query.neq('id', excludeReservationId);
      }

      final response = await query;

      // 기존 예약된 교시 목록 수집
      final reservedPeriods = <int>{};
      for (final row in response as List) {
        final existingPeriods = row['periods'] as List<dynamic>?;
        if (existingPeriods != null) {
          reservedPeriods.addAll(existingPeriods.cast<int>());
        }
      }

      // 충돌하는 교시 반환
      return periods.where((p) => reservedPeriods.contains(p)).toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 특정 날짜의 예약된 교시 목록 조회
  Future<Map<int, Reservation>> getReservedPeriodsMap(
    String classroomId,
    DateTime date,
  ) async {
    try {
      final reservations = await getReservationsByClassroom(classroomId, date: date);

      final periodMap = <int, Reservation>{};
      for (final reservation in reservations) {
        if (reservation.periods != null) {
          for (final period in reservation.periods!) {
            periodMap[period] = reservation;
          }
        }
      }

      return periodMap;
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 교시 기반 예약 생성
  ///
  /// 충돌 검증 후 reservations 테이블에 INSERT
  Future<Reservation> createReservation({
    required String classroomId,
    required DateTime date,
    required List<int> periods,
    String? description,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      // 교시 유효성 검증
      if (periods.isEmpty) {
        throw Exception('최소 1교시 이상 선택해주세요');
      }

      if (periods.any((p) => p < 1 || p > 10)) {
        throw Exception('교시는 1~10 사이여야 합니다');
      }

      // 과거 날짜 검증
      final today = DateTime.now();
      final selectedDate = DateTime(date.year, date.month, date.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      if (selectedDate.isBefore(todayDate)) {
        throw Exception('과거 날짜로 예약할 수 없습니다');
      }

      // 충돌 검증
      final conflicts = await getConflictingPeriods(
        classroomId,
        date,
        periods,
      );

      if (conflicts.isNotEmpty) {
        throw Exception('${conflicts.join(", ")}교시는 이미 예약되어 있습니다');
      }

      // 교시에서 실제 시간 계산
      final sortedPeriods = List<int>.from(periods)..sort();
      final firstPeriod = PeriodTimes.getPeriod(sortedPeriods.first);
      final lastPeriod = PeriodTimes.getPeriod(sortedPeriods.last);
      
      if (firstPeriod == null || lastPeriod == null) {
        throw Exception('유효하지 않은 교시입니다');
      }
      
      final startTime = firstPeriod.toStartDateTime(date);
      final endTime = lastPeriod.toEndDateTime(date);

      final data = {
        'classroom_id': classroomId,
        'teacher_id': session.user.id,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'periods': periods,
        'description': description,
      };

      final response = await _supabase
          .from('reservations')
          .insert(data)
          .select('''
            *,
            users:teacher_id (
              name,
              grade,
              class_num
            )
          ''')
          .single();

      final userData = response['users'] as Map<String, dynamic>?;
      return Reservation.fromJson({
        ...response,
        'teacher_name': userData?['name'],
        'teacher_grade': userData?['grade'],
        'teacher_class_num': userData?['class_num'],
      });
    } on PostgrestException catch (e, stack) {
      AppLogger.error('ReservationRepository.createReservation', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    } catch (e, stack) {
      AppLogger.error('ReservationRepository.createReservation', e, stack);
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 예약 수정 (교시 변경)
  Future<void> updateReservation(
    String id, {
    List<int>? periods,
    String? description,
  }) async {
    try {
      // 기존 예약 조회
      final existing = await getReservation(id);
      if (existing == null) {
        throw Exception('예약을 찾을 수 없습니다');
      }

      final updates = <String, dynamic>{};

      if (periods != null) {
        // 충돌 검증
        final conflicts = await getConflictingPeriods(
          existing.classroomId,
          existing.startTime,
          periods,
          excludeReservationId: id,
        );

        if (conflicts.isNotEmpty) {
          throw Exception('${conflicts.join(", ")}교시는 이미 예약되어 있습니다');
        }

        updates['periods'] = periods;
      }

      if (description != null) {
        updates['description'] = description;
      }

      if (updates.isEmpty) return;

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

  /// 예약 복원
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
          .select('id')
          .eq('teacher_id', session.user.id)
          .isFilter('deleted_at', null)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String());

      return (response as List).length;
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 오늘의 내 예약 목록 조회
  Future<List<Reservation>> getTodayMyReservations() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return [];

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('reservations')
          .select('''
            *,
            classrooms:classroom_id (
              name,
              room_type
            )
          ''')
          .eq('teacher_id', session.user.id)
          .isFilter('deleted_at', null)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String())
          .order('start_time', ascending: true);

      return (response as List).map((item) {
        // classrooms 관계에서 정보 추출
        final json = item as Map<String, dynamic>;
        final classroomData = json['classrooms'] as Map<String, dynamic>?;
        return Reservation.fromJson({
          ...json,
          'classroom_name': classroomData?['name'],
          'classroom_room_type': classroomData?['room_type'],
        });
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }
}
