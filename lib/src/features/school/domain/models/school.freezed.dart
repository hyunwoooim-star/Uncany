// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

School _$SchoolFromJson(Map<String, dynamic> json) {
  return _School.fromJson(json);
}

/// @nodoc
mixin _$School {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'education_office')
  String? get educationOffice => throw _privateConstructorUsedError;
  @JsonKey(name: 'neis_code')
  String? get neisCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_School value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_School value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_School value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this School to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of School
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SchoolCopyWith<School> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SchoolCopyWith<$Res> {
  factory $SchoolCopyWith(School value, $Res Function(School) then) =
      _$SchoolCopyWithImpl<$Res, School>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? address,
      String type,
      @JsonKey(name: 'education_office') String? educationOffice,
      @JsonKey(name: 'neis_code') String? neisCode,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$SchoolCopyWithImpl<$Res, $Val extends School>
    implements $SchoolCopyWith<$Res> {
  _$SchoolCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of School
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = freezed,
    Object? type = null,
    Object? educationOffice = freezed,
    Object? neisCode = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      educationOffice: freezed == educationOffice
          ? _value.educationOffice
          : educationOffice // ignore: cast_nullable_to_non_nullable
              as String?,
      neisCode: freezed == neisCode
          ? _value.neisCode
          : neisCode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SchoolImplCopyWith<$Res> implements $SchoolCopyWith<$Res> {
  factory _$$SchoolImplCopyWith(
          _$SchoolImpl value, $Res Function(_$SchoolImpl) then) =
      __$$SchoolImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? address,
      String type,
      @JsonKey(name: 'education_office') String? educationOffice,
      @JsonKey(name: 'neis_code') String? neisCode,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$SchoolImplCopyWithImpl<$Res>
    extends _$SchoolCopyWithImpl<$Res, _$SchoolImpl>
    implements _$$SchoolImplCopyWith<$Res> {
  __$$SchoolImplCopyWithImpl(
      _$SchoolImpl _value, $Res Function(_$SchoolImpl) _then)
      : super(_value, _then);

  /// Create a copy of School
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = freezed,
    Object? type = null,
    Object? educationOffice = freezed,
    Object? neisCode = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$SchoolImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      educationOffice: freezed == educationOffice
          ? _value.educationOffice
          : educationOffice // ignore: cast_nullable_to_non_nullable
              as String?,
      neisCode: freezed == neisCode
          ? _value.neisCode
          : neisCode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SchoolImpl implements _School {
  const _$SchoolImpl(
      {required this.id,
      required this.name,
      this.address,
      this.type = 'elementary',
      @JsonKey(name: 'education_office') this.educationOffice,
      @JsonKey(name: 'neis_code') this.neisCode,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$SchoolImpl.fromJson(Map<String, dynamic> json) =>
      _$$SchoolImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? address;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey(name: 'education_office')
  final String? educationOffice;
  @override
  @JsonKey(name: 'neis_code')
  final String? neisCode;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'School(id: $id, name: $name, address: $address, type: $type, educationOffice: $educationOffice, neisCode: $neisCode, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SchoolImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.educationOffice, educationOffice) ||
                other.educationOffice == educationOffice) &&
            (identical(other.neisCode, neisCode) ||
                other.neisCode == neisCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, address, type,
      educationOffice, neisCode, createdAt);

  /// Create a copy of School
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SchoolImplCopyWith<_$SchoolImpl> get copyWith =>
      __$$SchoolImplCopyWithImpl<_$SchoolImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_School value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_School value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_School value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SchoolImplToJson(
      this,
    );
  }
}

abstract class _School implements School {
  const factory _School(
      {required final String id,
      required final String name,
      final String? address,
      final String type,
      @JsonKey(name: 'education_office') final String? educationOffice,
      @JsonKey(name: 'neis_code') final String? neisCode,
      @JsonKey(name: 'created_at') final DateTime? createdAt}) = _$SchoolImpl;

  factory _School.fromJson(Map<String, dynamic> json) = _$SchoolImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get address;
  @override
  String get type;
  @override
  @JsonKey(name: 'education_office')
  String? get educationOffice;
  @override
  @JsonKey(name: 'neis_code')
  String? get neisCode;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of School
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SchoolImplCopyWith<_$SchoolImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
