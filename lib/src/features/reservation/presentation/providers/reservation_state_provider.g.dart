// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reservationScreenNotifierHash() =>
    r'3a5078955acb789338ae58e6e3aa250543fab30e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ReservationScreenNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ReservationState> {
  late final String classroomId;

  FutureOr<ReservationState> build({
    required String classroomId,
  });
}

/// 예약 화면 상태 관리 Notifier
///
/// Riverpod 2.0 스타일 (AsyncNotifier 사용)
/// ✅ Gemini 피드백 반영: classroomId를 state에 저장하여 Hot Reload 안전성 확보
///
/// Copied from [ReservationScreenNotifier].
@ProviderFor(ReservationScreenNotifier)
const reservationScreenNotifierProvider = ReservationScreenNotifierFamily();

/// 예약 화면 상태 관리 Notifier
///
/// Riverpod 2.0 스타일 (AsyncNotifier 사용)
/// ✅ Gemini 피드백 반영: classroomId를 state에 저장하여 Hot Reload 안전성 확보
///
/// Copied from [ReservationScreenNotifier].
class ReservationScreenNotifierFamily
    extends Family<AsyncValue<ReservationState>> {
  /// 예약 화면 상태 관리 Notifier
  ///
  /// Riverpod 2.0 스타일 (AsyncNotifier 사용)
  /// ✅ Gemini 피드백 반영: classroomId를 state에 저장하여 Hot Reload 안전성 확보
  ///
  /// Copied from [ReservationScreenNotifier].
  const ReservationScreenNotifierFamily();

  /// 예약 화면 상태 관리 Notifier
  ///
  /// Riverpod 2.0 스타일 (AsyncNotifier 사용)
  /// ✅ Gemini 피드백 반영: classroomId를 state에 저장하여 Hot Reload 안전성 확보
  ///
  /// Copied from [ReservationScreenNotifier].
  ReservationScreenNotifierProvider call({
    required String classroomId,
  }) {
    return ReservationScreenNotifierProvider(
      classroomId: classroomId,
    );
  }

  @override
  ReservationScreenNotifierProvider getProviderOverride(
    covariant ReservationScreenNotifierProvider provider,
  ) {
    return call(
      classroomId: provider.classroomId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reservationScreenNotifierProvider';
}

/// 예약 화면 상태 관리 Notifier
///
/// Riverpod 2.0 스타일 (AsyncNotifier 사용)
/// ✅ Gemini 피드백 반영: classroomId를 state에 저장하여 Hot Reload 안전성 확보
///
/// Copied from [ReservationScreenNotifier].
class ReservationScreenNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ReservationScreenNotifier,
        ReservationState> {
  /// 예약 화면 상태 관리 Notifier
  ///
  /// Riverpod 2.0 스타일 (AsyncNotifier 사용)
  /// ✅ Gemini 피드백 반영: classroomId를 state에 저장하여 Hot Reload 안전성 확보
  ///
  /// Copied from [ReservationScreenNotifier].
  ReservationScreenNotifierProvider({
    required String classroomId,
  }) : this._internal(
          () => ReservationScreenNotifier()..classroomId = classroomId,
          from: reservationScreenNotifierProvider,
          name: r'reservationScreenNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reservationScreenNotifierHash,
          dependencies: ReservationScreenNotifierFamily._dependencies,
          allTransitiveDependencies:
              ReservationScreenNotifierFamily._allTransitiveDependencies,
          classroomId: classroomId,
        );

  ReservationScreenNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classroomId,
  }) : super.internal();

  final String classroomId;

  @override
  FutureOr<ReservationState> runNotifierBuild(
    covariant ReservationScreenNotifier notifier,
  ) {
    return notifier.build(
      classroomId: classroomId,
    );
  }

  @override
  Override overrideWith(ReservationScreenNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReservationScreenNotifierProvider._internal(
        () => create()..classroomId = classroomId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classroomId: classroomId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ReservationScreenNotifier,
      ReservationState> createElement() {
    return _ReservationScreenNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReservationScreenNotifierProvider &&
        other.classroomId == classroomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classroomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReservationScreenNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<ReservationState> {
  /// The parameter `classroomId` of this provider.
  String get classroomId;
}

class _ReservationScreenNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ReservationScreenNotifier,
        ReservationState> with ReservationScreenNotifierRef {
  _ReservationScreenNotifierProviderElement(super.provider);

  @override
  String get classroomId =>
      (origin as ReservationScreenNotifierProvider).classroomId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
