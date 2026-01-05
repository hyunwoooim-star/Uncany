// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'education_office.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EducationOffice _$EducationOfficeFromJson(Map<String, dynamic> json) {
  return _EducationOffice.fromJson(json);
}

/// @nodoc
mixin _$EducationOffice {
  String get code => throw _privateConstructorUsedError; // 예: "seoul"
  String get nameKo => throw _privateConstructorUsedError; // 예: "서울특별시교육청"
  String get emailDomain =>
      throw _privateConstructorUsedError; // 예: "sen.go.kr"
  DateTime? get createdAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EducationOffice value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EducationOffice value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EducationOffice value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this EducationOffice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EducationOffice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EducationOfficeCopyWith<EducationOffice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EducationOfficeCopyWith<$Res> {
  factory $EducationOfficeCopyWith(
          EducationOffice value, $Res Function(EducationOffice) then) =
      _$EducationOfficeCopyWithImpl<$Res, EducationOffice>;
  @useResult
  $Res call(
      {String code, String nameKo, String emailDomain, DateTime? createdAt});
}

/// @nodoc
class _$EducationOfficeCopyWithImpl<$Res, $Val extends EducationOffice>
    implements $EducationOfficeCopyWith<$Res> {
  _$EducationOfficeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EducationOffice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? nameKo = null,
    Object? emailDomain = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      emailDomain: null == emailDomain
          ? _value.emailDomain
          : emailDomain // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EducationOfficeImplCopyWith<$Res>
    implements $EducationOfficeCopyWith<$Res> {
  factory _$$EducationOfficeImplCopyWith(_$EducationOfficeImpl value,
          $Res Function(_$EducationOfficeImpl) then) =
      __$$EducationOfficeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code, String nameKo, String emailDomain, DateTime? createdAt});
}

/// @nodoc
class __$$EducationOfficeImplCopyWithImpl<$Res>
    extends _$EducationOfficeCopyWithImpl<$Res, _$EducationOfficeImpl>
    implements _$$EducationOfficeImplCopyWith<$Res> {
  __$$EducationOfficeImplCopyWithImpl(
      _$EducationOfficeImpl _value, $Res Function(_$EducationOfficeImpl) _then)
      : super(_value, _then);

  /// Create a copy of EducationOffice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? nameKo = null,
    Object? emailDomain = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$EducationOfficeImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      emailDomain: null == emailDomain
          ? _value.emailDomain
          : emailDomain // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EducationOfficeImpl implements _EducationOffice {
  const _$EducationOfficeImpl(
      {required this.code,
      required this.nameKo,
      required this.emailDomain,
      this.createdAt});

  factory _$EducationOfficeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EducationOfficeImplFromJson(json);

  @override
  final String code;
// 예: "seoul"
  @override
  final String nameKo;
// 예: "서울특별시교육청"
  @override
  final String emailDomain;
// 예: "sen.go.kr"
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'EducationOffice(code: $code, nameKo: $nameKo, emailDomain: $emailDomain, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EducationOfficeImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.nameKo, nameKo) || other.nameKo == nameKo) &&
            (identical(other.emailDomain, emailDomain) ||
                other.emailDomain == emailDomain) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, code, nameKo, emailDomain, createdAt);

  /// Create a copy of EducationOffice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EducationOfficeImplCopyWith<_$EducationOfficeImpl> get copyWith =>
      __$$EducationOfficeImplCopyWithImpl<_$EducationOfficeImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EducationOffice value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EducationOffice value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EducationOffice value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EducationOfficeImplToJson(
      this,
    );
  }
}

abstract class _EducationOffice implements EducationOffice {
  const factory _EducationOffice(
      {required final String code,
      required final String nameKo,
      required final String emailDomain,
      final DateTime? createdAt}) = _$EducationOfficeImpl;

  factory _EducationOffice.fromJson(Map<String, dynamic> json) =
      _$EducationOfficeImpl.fromJson;

  @override
  String get code; // 예: "seoul"
  @override
  String get nameKo; // 예: "서울특별시교육청"
  @override
  String get emailDomain; // 예: "sen.go.kr"
  @override
  DateTime? get createdAt;

  /// Create a copy of EducationOffice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EducationOfficeImplCopyWith<_$EducationOfficeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
