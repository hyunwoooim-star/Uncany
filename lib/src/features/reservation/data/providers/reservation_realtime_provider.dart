import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uncany/src/core/providers/supabase_provider.dart';
import '../../domain/models/reservation.dart';
import '../repositories/reservation_repository.dart';
import 'reservation_repository_provider.dart';

/// 특정 교실의 특정 날짜 예약 실시간 스트림 Provider
///
/// Supabase Realtime을 사용하여 예약 변경사항을 실시간으로 감지
final classroomReservationsStreamProvider = StreamProvider.autoDispose
    .family<List<Reservation>, ({String classroomId, DateTime date})>(
  (ref, params) async* {
    final repository = ref.watch(reservationRepositoryProvider);
    final supabase = ref.watch(supabaseProvider);

    // StreamController 생성
    final controller = StreamController<List<Reservation>>();

    // 초기 데이터 로드
    try {
      final initial = await repository.getReservationsByClassroom(
        params.classroomId,
        date: params.date,
      );
      controller.add(initial);
    } catch (e) {
      controller.addError(e);
    }

    // Realtime 구독 설정
    final channel = supabase
        .channel('classroom_${params.classroomId}_${params.date.millisecondsSinceEpoch}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reservations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'classroom_id',
            value: params.classroomId,
          ),
          callback: (_) async {
            try {
              final updated = await repository.getReservationsByClassroom(
                params.classroomId,
                date: params.date,
              );
              if (!controller.isClosed) {
                controller.add(updated);
              }
            } catch (e) {
              if (!controller.isClosed) {
                controller.addError(e);
              }
            }
          },
        )
        .subscribe();

    // Provider가 dispose될 때 구독 해제
    ref.onDispose(() {
      channel.unsubscribe();
      controller.close();
    });

    yield* controller.stream;
  },
);

/// 내 예약 목록 실시간 스트림 Provider
final myReservationsStreamProvider =
    StreamProvider.autoDispose<List<Reservation>>((ref) async* {
  final repository = ref.watch(reservationRepositoryProvider);
  final supabase = ref.watch(supabaseProvider);

  // 현재 사용자 ID 가져오기
  final session = supabase.auth.currentSession;
  if (session == null) {
    yield [];
    return;
  }

  final userId = session.user.id;

  // StreamController 생성
  final controller = StreamController<List<Reservation>>();

  // 초기 데이터 로드
  try {
    final initial = await repository.getMyReservations();
    controller.add(initial);
  } catch (e) {
    controller.addError(e);
  }

  // Realtime 구독
  final channel = supabase
      .channel('my_reservations_$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'teacher_id',
          value: userId,
        ),
        callback: (_) async {
          try {
            final updated = await repository.getMyReservations();
            if (!controller.isClosed) {
              controller.add(updated);
            }
          } catch (e) {
            if (!controller.isClosed) {
              controller.addError(e);
            }
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  yield* controller.stream;
});
