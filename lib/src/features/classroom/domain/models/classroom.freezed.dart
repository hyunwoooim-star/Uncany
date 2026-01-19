// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classroom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Classroom _$ClassroomFromJson(Map<String, dynamic> json) {
  return _Classroom.fromJson(json);
}

/// @nodoc
mixin _$Classroom {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_code_hash')
  String? get accessCodeHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'notice_message')
  String? get noticeMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'notice_updated_at')
  DateTime? get noticeUpdatedAt => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // v0.2: 학교 기반 멀티테넌시
  @JsonKey(name: 'school_id')
  String? get schoolId => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_type')
  String get roomType => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_settings')
  Map<String, dynamic>? get periodSettings =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy =>
      throw _privateConstructorUsedError; // v0.3: 생성자 정보 (JOIN으로 가져옴)
  @JsonKey(name: 'creator_name')
  String? get creatorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'creator_grade')
  int? get creatorGrade => throw _privateConstructorUsedError;
  @JsonKey(name: 'creator_class_num')
  int? get creatorClassNum => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Classroom value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Classroom value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Classroom value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this Classroom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Classroom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassroomCopyWith<Classroom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomCopyWith<$Res> {
  factory $ClassroomCopyWith(Classroom value, $Res Function(Classroom) then) =
      _$ClassroomCopyWithImpl<$Res, Classroom>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'access_code_hash') String? accessCodeHash,
      @JsonKey(name: 'notice_message') String? noticeMessage,
      @JsonKey(name: 'notice_updated_at') DateTime? noticeUpdatedAt,
      int? capacity,
      String? location,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      @JsonKey(name: 'school_id') String? schoolId,
      @JsonKey(name: 'room_type') String roomType,
      @JsonKey(name: 'period_settings') Map<String, dynamic>? periodSettings,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'creator_name') String? creatorName,
      @JsonKey(name: 'creator_grade') int? creatorGrade,
      @JsonKey(name: 'creator_class_num') int? creatorClassNum});
}

/// @nodoc
class _$ClassroomCopyWithImpl<$Res, $Val extends Classroom>
    implements $ClassroomCopyWith<$Res> {
  _$ClassroomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Classroom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? accessCodeHash = freezed,
    Object? noticeMessage = freezed,
    Object? noticeUpdatedAt = freezed,
    Object? capacity = freezed,
    Object? location = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? deletedAt = freezed,
    Object? schoolId = freezed,
    Object? roomType = null,
    Object? periodSettings = freezed,
    Object? createdBy = freezed,
    Object? creatorName = freezed,
    Object? creatorGrade = freezed,
    Object? creatorClassNum = freezed,
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
      accessCodeHash: freezed == accessCodeHash
          ? _value.accessCodeHash
          : accessCodeHash // ignore: cast_nullable_to_non_nullable
              as String?,
      noticeMessage: freezed == noticeMessage
          ? _value.noticeMessage
          : noticeMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      noticeUpdatedAt: freezed == noticeUpdatedAt
          ? _value.noticeUpdatedAt
          : noticeUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      schoolId: freezed == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as String,
      periodSettings: freezed == periodSettings
          ? _value.periodSettings
          : periodSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorGrade: freezed == creatorGrade
          ? _value.creatorGrade
          : creatorGrade // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorClassNum: freezed == creatorClassNum
          ? _value.creatorClassNum
          : creatorClassNum // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomImplCopyWith<$Res>
    implements $ClassroomCopyWith<$Res> {
  factory _$$ClassroomImplCopyWith(
          _$ClassroomImpl value, $Res Function(_$ClassroomImpl) then) =
      __$$ClassroomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'access_code_hash') String? accessCodeHash,
      @JsonKey(name: 'notice_message') String? noticeMessage,
      @JsonKey(name: 'notice_updated_at') DateTime? noticeUpdatedAt,
      int? capacity,
      String? location,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      @JsonKey(name: 'school_id') String? schoolId,
      @JsonKey(name: 'room_type') String roomType,
      @JsonKey(name: 'period_settings') Map<String, dynamic>? periodSettings,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'creator_name') String? creatorName,
      @JsonKey(name: 'creator_grade') int? creatorGrade,
      @JsonKey(name: 'creator_class_num') int? creatorClassNum});
}

/// @nodoc
class __$$ClassroomImplCopyWithImpl<$Res>
    extends _$ClassroomCopyWithImpl<$Res, _$ClassroomImpl>
    implements _$$ClassroomImplCopyWith<$Res> {
  __$$ClassroomImplCopyWithImpl(
      _$ClassroomImpl _value, $Res Function(_$ClassroomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Classroom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? accessCodeHash = freezed,
    Object? noticeMessage = freezed,
    Object? noticeUpdatedAt = freezed,
    Object? capacity = freezed,
    Object? location = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? deletedAt = freezed,
    Object? schoolId = freezed,
    Object? roomType = null,
    Object? periodSettings = freezed,
    Object? createdBy = freezed,
    Object? creatorName = freezed,
    Object? creatorGrade = freezed,
    Object? creatorClassNum = freezed,
  }) {
    return _then(_$ClassroomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      accessCodeHash: freezed == accessCodeHash
          ? _value.accessCodeHash
          : accessCodeHash // ignore: cast_nullable_to_non_nullable
              as String?,
      noticeMessage: freezed == noticeMessage
          ? _value.noticeMessage
          : noticeMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      noticeUpdatedAt: freezed == noticeUpdatedAt
          ? _value.noticeUpdatedAt
          : noticeUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      schoolId: freezed == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as String,
      periodSettings: freezed == periodSettings
          ? _value._periodSettings
          : periodSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorGrade: freezed == creatorGrade
          ? _value.creatorGrade
          : creatorGrade // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorClassNum: freezed == creatorClassNum
          ? _value.creatorClassNum
          : creatorClassNum // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomImpl extends _Classroom {
  const _$ClassroomImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'access_code_hash') this.accessCodeHash,
      @JsonKey(name: 'notice_message') this.noticeMessage,
      @JsonKey(name: 'notice_updated_at') this.noticeUpdatedAt,
      this.capacity,
      this.location,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      @JsonKey(name: 'school_id') this.schoolId,
      @JsonKey(name: 'room_type') this.roomType = 'other',
      @JsonKey(name: 'period_settings')
      final Map<String, dynamic>? periodSettings,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'creator_name') this.creatorName,
      @JsonKey(name: 'creator_grade') this.creatorGrade,
      @JsonKey(name: 'creator_class_num') this.creatorClassNum})
      : _periodSettings = periodSettings,
        super._();

  factory _$ClassroomImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'access_code_hash')
  final String? accessCodeHash;
  @override
  @JsonKey(name: 'notice_message')
  final String? noticeMessage;
  @override
  @JsonKey(name: 'notice_updated_at')
  final DateTime? noticeUpdatedAt;
  @override
  final int? capacity;
  @override
  final String? location;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;
// v0.2: 학교 기반 멀티테넌시
  @override
  @JsonKey(name: 'school_id')
  final String? schoolId;
  @override
  @JsonKey(name: 'room_type')
  final String roomType;
  final Map<String, dynamic>? _periodSettings;
  @override
  @JsonKey(name: 'period_settings')
  Map<String, dynamic>? get periodSettings {
    final value = _periodSettings;
    if (value == null) return null;
    if (_periodSettings is EqualUnmodifiableMapView) return _periodSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
// v0.3: 생성자 정보 (JOIN으로 가져옴)
  @override
  @JsonKey(name: 'creator_name')
  final String? creatorName;
  @override
  @JsonKey(name: 'creator_grade')
  final int? creatorGrade;
  @override
  @JsonKey(name: 'creator_class_num')
  final int? creatorClassNum;

  @override
  String toString() {
    return 'Classroom(id: $id, name: $name, accessCodeHash: $accessCodeHash, noticeMessage: $noticeMessage, noticeUpdatedAt: $noticeUpdatedAt, capacity: $capacity, location: $location, isActive: $isActive, createdAt: $createdAt, deletedAt: $deletedAt, schoolId: $schoolId, roomType: $roomType, periodSettings: $periodSettings, createdBy: $createdBy, creatorName: $creatorName, creatorGrade: $creatorGrade, creatorClassNum: $creatorClassNum)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accessCodeHash, accessCodeHash) ||
                other.accessCodeHash == accessCodeHash) &&
            (identical(other.noticeMessage, noticeMessage) ||
                other.noticeMessage == noticeMessage) &&
            (identical(other.noticeUpdatedAt, noticeUpdatedAt) ||
                other.noticeUpdatedAt == noticeUpdatedAt) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType) &&
            const DeepCollectionEquality()
                .equals(other._periodSettings, _periodSettings) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.creatorGrade, creatorGrade) ||
                other.creatorGrade == creatorGrade) &&
            (identical(other.creatorClassNum, creatorClassNum) ||
                other.creatorClassNum == creatorClassNum));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      accessCodeHash,
      noticeMessage,
      noticeUpdatedAt,
      capacity,
      location,
      isActive,
      createdAt,
      deletedAt,
      schoolId,
      roomType,
      const DeepCollectionEquality().hash(_periodSettings),
      createdBy,
      creatorName,
      creatorGrade,
      creatorClassNum);

  /// Create a copy of Classroom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomImplCopyWith<_$ClassroomImpl> get copyWith =>
      __$$ClassroomImplCopyWithImpl<_$ClassroomImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Classroom value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Classroom value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Classroom value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomImplToJson(
      this,
    );
  }
}

abstract class _Classroom extends Classroom {
  const factory _Classroom(
          {required final String id,
          required final String name,
          @JsonKey(name: 'access_code_hash') final String? accessCodeHash,
          @JsonKey(name: 'notice_message') final String? noticeMessage,
          @JsonKey(name: 'notice_updated_at') final DateTime? noticeUpdatedAt,
          final int? capacity,
          final String? location,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
          @JsonKey(name: 'school_id') final String? schoolId,
          @JsonKey(name: 'room_type') final String roomType,
          @JsonKey(name: 'period_settings')
          final Map<String, dynamic>? periodSettings,
          @JsonKey(name: 'created_by') final String? createdBy,
          @JsonKey(name: 'creator_name') final String? creatorName,
          @JsonKey(name: 'creator_grade') final int? creatorGrade,
          @JsonKey(name: 'creator_class_num') final int? creatorClassNum}) =
      _$ClassroomImpl;
  const _Classroom._() : super._();

  factory _Classroom.fromJson(Map<String, dynamic> json) =
      _$ClassroomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'access_code_hash')
  String? get accessCodeHash;
  @override
  @JsonKey(name: 'notice_message')
  String? get noticeMessage;
  @override
  @JsonKey(name: 'notice_updated_at')
  DateTime? get noticeUpdatedAt;
  @override
  int? get capacity;
  @override
  String? get location;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt; // v0.2: 학교 기반 멀티테넌시
  @override
  @JsonKey(name: 'school_id')
  String? get schoolId;
  @override
  @JsonKey(name: 'room_type')
  String get roomType;
  @override
  @JsonKey(name: 'period_settings')
  Map<String, dynamic>? get periodSettings;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy; // v0.3: 생성자 정보 (JOIN으로 가져옴)
  @override
  @JsonKey(name: 'creator_name')
  String? get creatorName;
  @override
  @JsonKey(name: 'creator_grade')
  int? get creatorGrade;
  @override
  @JsonKey(name: 'creator_class_num')
  int? get creatorClassNum;

  /// Create a copy of Classroom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassroomImplCopyWith<_$ClassroomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
