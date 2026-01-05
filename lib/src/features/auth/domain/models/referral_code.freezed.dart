// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReferralCode _$ReferralCodeFromJson(Map<String, dynamic> json) {
  return _ReferralCode.fromJson(json);
}

/// @nodoc
mixin _$ReferralCode {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError; // 예: "SEOUL-ABC123"
  String get createdBy => throw _privateConstructorUsedError; // 생성자 User ID
  String get schoolName => throw _privateConstructorUsedError; // 같은 학교 검증용
  int get maxUses => throw _privateConstructorUsedError; // 최대 사용 횟수
  int get currentUses => throw _privateConstructorUsedError; // 현재 사용 횟수
  DateTime? get expiresAt => throw _privateConstructorUsedError; // 만료 일시
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferralCode value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferralCode value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferralCode value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ReferralCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferralCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferralCodeCopyWith<ReferralCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralCodeCopyWith<$Res> {
  factory $ReferralCodeCopyWith(
          ReferralCode value, $Res Function(ReferralCode) then) =
      _$ReferralCodeCopyWithImpl<$Res, ReferralCode>;
  @useResult
  $Res call(
      {String id,
      String code,
      String createdBy,
      String schoolName,
      int maxUses,
      int currentUses,
      DateTime? expiresAt,
      bool isActive,
      DateTime? createdAt});
}

/// @nodoc
class _$ReferralCodeCopyWithImpl<$Res, $Val extends ReferralCode>
    implements $ReferralCodeCopyWith<$Res> {
  _$ReferralCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferralCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? createdBy = null,
    Object? schoolName = null,
    Object? maxUses = null,
    Object? currentUses = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      schoolName: null == schoolName
          ? _value.schoolName
          : schoolName // ignore: cast_nullable_to_non_nullable
              as String,
      maxUses: null == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int,
      currentUses: null == currentUses
          ? _value.currentUses
          : currentUses // ignore: cast_nullable_to_non_nullable
              as int,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralCodeImplCopyWith<$Res>
    implements $ReferralCodeCopyWith<$Res> {
  factory _$$ReferralCodeImplCopyWith(
          _$ReferralCodeImpl value, $Res Function(_$ReferralCodeImpl) then) =
      __$$ReferralCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String createdBy,
      String schoolName,
      int maxUses,
      int currentUses,
      DateTime? expiresAt,
      bool isActive,
      DateTime? createdAt});
}

/// @nodoc
class __$$ReferralCodeImplCopyWithImpl<$Res>
    extends _$ReferralCodeCopyWithImpl<$Res, _$ReferralCodeImpl>
    implements _$$ReferralCodeImplCopyWith<$Res> {
  __$$ReferralCodeImplCopyWithImpl(
      _$ReferralCodeImpl _value, $Res Function(_$ReferralCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReferralCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? createdBy = null,
    Object? schoolName = null,
    Object? maxUses = null,
    Object? currentUses = null,
    Object? expiresAt = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ReferralCodeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      schoolName: null == schoolName
          ? _value.schoolName
          : schoolName // ignore: cast_nullable_to_non_nullable
              as String,
      maxUses: null == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int,
      currentUses: null == currentUses
          ? _value.currentUses
          : currentUses // ignore: cast_nullable_to_non_nullable
              as int,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralCodeImpl implements _ReferralCode {
  const _$ReferralCodeImpl(
      {required this.id,
      required this.code,
      required this.createdBy,
      required this.schoolName,
      this.maxUses = 5,
      this.currentUses = 0,
      this.expiresAt,
      this.isActive = true,
      this.createdAt});

  factory _$ReferralCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralCodeImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
// 예: "SEOUL-ABC123"
  @override
  final String createdBy;
// 생성자 User ID
  @override
  final String schoolName;
// 같은 학교 검증용
  @override
  @JsonKey()
  final int maxUses;
// 최대 사용 횟수
  @override
  @JsonKey()
  final int currentUses;
// 현재 사용 횟수
  @override
  final DateTime? expiresAt;
// 만료 일시
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ReferralCode(id: $id, code: $code, createdBy: $createdBy, schoolName: $schoolName, maxUses: $maxUses, currentUses: $currentUses, expiresAt: $expiresAt, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralCodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.schoolName, schoolName) ||
                other.schoolName == schoolName) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.currentUses, currentUses) ||
                other.currentUses == currentUses) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, createdBy, schoolName,
      maxUses, currentUses, expiresAt, isActive, createdAt);

  /// Create a copy of ReferralCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralCodeImplCopyWith<_$ReferralCodeImpl> get copyWith =>
      __$$ReferralCodeImplCopyWithImpl<_$ReferralCodeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferralCode value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferralCode value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferralCode value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralCodeImplToJson(
      this,
    );
  }
}

abstract class _ReferralCode implements ReferralCode {
  const factory _ReferralCode(
      {required final String id,
      required final String code,
      required final String createdBy,
      required final String schoolName,
      final int maxUses,
      final int currentUses,
      final DateTime? expiresAt,
      final bool isActive,
      final DateTime? createdAt}) = _$ReferralCodeImpl;

  factory _ReferralCode.fromJson(Map<String, dynamic> json) =
      _$ReferralCodeImpl.fromJson;

  @override
  String get id;
  @override
  String get code; // 예: "SEOUL-ABC123"
  @override
  String get createdBy; // 생성자 User ID
  @override
  String get schoolName; // 같은 학교 검증용
  @override
  int get maxUses; // 최대 사용 횟수
  @override
  int get currentUses; // 현재 사용 횟수
  @override
  DateTime? get expiresAt; // 만료 일시
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;

  /// Create a copy of ReferralCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferralCodeImplCopyWith<_$ReferralCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
