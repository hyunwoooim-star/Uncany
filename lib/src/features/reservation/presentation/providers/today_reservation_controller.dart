import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/reservation_repository_provider.dart';
import '../../domain/models/reservation.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

part 'today_reservation_controller.g.dart';

/// 오늘의 내 예약 Controller (AsyncNotifier)
///
/// FutureProvider + setState 패턴을 대체하여 상태 관리 일관성 확보
@riverpod
class TodayMyReservationController extends _$TodayMyReservationController {
  @override
  Future<List<Reservation>> build() async {
    final repository = ref.watch(reservationRepositoryProvider);
    return await repository.getTodayMyReservations();
  }

  /// 데이터 강제 갱신 (Pull-to-refresh 용)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reservationRepositoryProvider);
      return await repository.getTodayMyReservations();
    });
  }

  /// 예약 취소
  ///
  /// [reservationId]: 취소할 예약 ID
  Future<void> cancelReservation(String reservationId) async {
    // 기존 데이터 백업 (실패 시 롤백용)
    final previousState = state;

    try {
      // Optimistic UI: 목록에서 즉시 제거
      state = state.whenData((reservations) {
        return reservations.where((r) => r.id != reservationId).toList();
      });

      // 실제 취소 요청
      final repository = ref.read(reservationRepositoryProvider);
      await repository.cancelReservation(reservationId);

      // 성공 시 전체 예약도 갱신
      ref.invalidate(todayAllReservationControllerProvider);
    } catch (e) {
      // 실패 시 롤백
      state = previousState;
      throw Exception(ErrorMessages.fromError(e));
    }
  }
}

/// 오늘의 전체 예약 Controller (AsyncNotifier)
@riverpod
class TodayAllReservationController extends _$TodayAllReservationController {
  @override
  Future<List<Reservation>> build() async {
    final repository = ref.watch(reservationRepositoryProvider);
    return await repository.getTodayAllReservations();
  }

  /// 데이터 강제 갱신
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reservationRepositoryProvider);
      return await repository.getTodayAllReservations();
    });
  }
}
