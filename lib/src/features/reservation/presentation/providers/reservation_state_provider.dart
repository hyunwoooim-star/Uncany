import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/reservation.dart';
import '../../data/providers/reservation_repository_provider.dart';

part 'reservation_state_provider.g.dart';

/// 예약 정보 상태 (특정 교실, 특정 날짜)
class ReservationState {
  final Map<int, Reservation> reservedPeriods;
  final Set<int> selectedPeriods;
  final DateTime selectedDate;

  const ReservationState({
    required this.reservedPeriods,
    required this.selectedPeriods,
    required this.selectedDate,
  });

  ReservationState copyWith({
    Map<int, Reservation>? reservedPeriods,
    Set<int>? selectedPeriods,
    DateTime? selectedDate,
  }) {
    return ReservationState(
      reservedPeriods: reservedPeriods ?? this.reservedPeriods,
      selectedPeriods: selectedPeriods ?? this.selectedPeriods,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// 예약 화면 상태 관리 Notifier
///
/// Riverpod 2.0 스타일 (AsyncNotifier 사용)
@riverpod
class ReservationScreenNotifier extends _$ReservationScreenNotifier {
  String? _classroomId;

  @override
  Future<ReservationState> build({required String classroomId}) async {
    _classroomId = classroomId;
    final today = DateTime.now();

    // 초기 예약 정보 로드
    final reservedMap = await _loadReservations(today);

    return ReservationState(
      reservedPeriods: reservedMap,
      selectedPeriods: {},
      selectedDate: today,
    );
  }

  /// 예약 정보 로드 (내부 헬퍼)
  Future<Map<int, Reservation>> _loadReservations(DateTime date) async {
    final repository = ref.read(reservationRepositoryProvider);
    return await repository.getReservedPeriodsMap(_classroomId!, date);
  }

  /// 날짜 변경
  Future<void> selectDate(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final reservedMap = await _loadReservations(date);
      final current = await future;
      return current.copyWith(
        selectedDate: date,
        reservedPeriods: reservedMap,
        selectedPeriods: {}, // 날짜 변경 시 선택 초기화
      );
    });
  }

  /// 교시 선택/해제
  void togglePeriod(int period) {
    state.whenData((current) {
      final newSelected = Set<int>.from(current.selectedPeriods);
      if (newSelected.contains(period)) {
        newSelected.remove(period);
      } else {
        newSelected.add(period);
      }
      state = AsyncValue.data(current.copyWith(selectedPeriods: newSelected));
    });
  }

  /// 선택 초기화
  void clearSelection() {
    state.whenData((current) {
      state = AsyncValue.data(current.copyWith(selectedPeriods: {}));
    });
  }

  /// 예약 생성
  Future<void> createReservation() async {
    final current = state.value;
    if (current == null || current.selectedPeriods.isEmpty) {
      throw Exception('교시를 선택해주세요');
    }

    final repository = ref.read(reservationRepositoryProvider);
    await repository.createReservation(
      classroomId: _classroomId!,
      date: current.selectedDate,
      periods: current.selectedPeriods.toList(),
    );

    // 예약 후 목록 새로고침
    await selectDate(current.selectedDate);
  }
}
