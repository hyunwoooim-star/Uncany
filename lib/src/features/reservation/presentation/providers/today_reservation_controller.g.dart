// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_reservation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayMyReservationControllerHash() =>
    r'2dc540aa0dee815e9018d730c2b3f0db837d25ea';

/// 오늘의 내 예약 Controller (AsyncNotifier)
///
/// FutureProvider + setState 패턴을 대체하여 상태 관리 일관성 확보
///
/// Copied from [TodayMyReservationController].
@ProviderFor(TodayMyReservationController)
final todayMyReservationControllerProvider = AutoDisposeAsyncNotifierProvider<
    TodayMyReservationController, List<Reservation>>.internal(
  TodayMyReservationController.new,
  name: r'todayMyReservationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayMyReservationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodayMyReservationController
    = AutoDisposeAsyncNotifier<List<Reservation>>;
String _$todayAllReservationControllerHash() =>
    r'6ef007b14c39671e6c72a529dd3c08ea577d750b';

/// 오늘의 전체 예약 Controller (AsyncNotifier)
///
/// Copied from [TodayAllReservationController].
@ProviderFor(TodayAllReservationController)
final todayAllReservationControllerProvider = AutoDisposeAsyncNotifierProvider<
    TodayAllReservationController, List<Reservation>>.internal(
  TodayAllReservationController.new,
  name: r'todayAllReservationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayAllReservationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodayAllReservationController
    = AutoDisposeAsyncNotifier<List<Reservation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
