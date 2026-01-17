// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reservation _$ReservationFromJson(Map<String, dynamic> json) {
  return _Reservation.fromJson(json);
}

/// @nodoc
mixin _$Reservation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'classroom_id')
  String get classroomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_id')
  String get teacherId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  DateTime get endTime => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // v0.2: 교시 기반 예약
  List<int>? get periods =>
      throw _privateConstructorUsedError; // [1, 2, 3] 형태로 교시 저장
// 예약자 정보 (JOIN용)
  @JsonKey(name: 'teacher_name')
  String? get teacherName => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_grade')
  int? get teacherGrade => throw _privateConstructorUsedError;
  @JsonKey(name: 'teacher_class_num')
  int? get teacherClassNum =>
      throw _privateConstructorUsedError; // 교실 정보 (JOIN용)
  @JsonKey(name: 'classroom_name')
  String? get classroomName => throw _privateConstructorUsedError;
  @JsonKey(name: 'classroom_room_type')
  String? get classroomRoomType => throw _privateConstructorUsedError;
  @JsonKey(name: 'classroom_location')
  String? get classroomLocation => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Reservation value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Reservation value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Reservation value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationCopyWith<Reservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationCopyWith<$Res> {
  factory $ReservationCopyWith(
          Reservation value, $Res Function(Reservation) then) =
      _$ReservationCopyWithImpl<$Res, Reservation>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'classroom_id') String classroomId,
      @JsonKey(name: 'teacher_id') String teacherId,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime endTime,
      String? title,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      List<int>? periods,
      @JsonKey(name: 'teacher_name') String? teacherName,
      @JsonKey(name: 'teacher_grade') int? teacherGrade,
      @JsonKey(name: 'teacher_class_num') int? teacherClassNum,
      @JsonKey(name: 'classroom_name') String? classroomName,
      @JsonKey(name: 'classroom_room_type') String? classroomRoomType,
      @JsonKey(name: 'classroom_location') String? classroomLocation});
}

/// @nodoc
class _$ReservationCopyWithImpl<$Res, $Val extends Reservation>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classroomId = null,
    Object? teacherId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? periods = freezed,
    Object? teacherName = freezed,
    Object? teacherGrade = freezed,
    Object? teacherClassNum = freezed,
    Object? classroomName = freezed,
    Object? classroomRoomType = freezed,
    Object? classroomLocation = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: null == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periods: freezed == periods
          ? _value.periods
          : periods // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      teacherName: freezed == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String?,
      teacherGrade: freezed == teacherGrade
          ? _value.teacherGrade
          : teacherGrade // ignore: cast_nullable_to_non_nullable
              as int?,
      teacherClassNum: freezed == teacherClassNum
          ? _value.teacherClassNum
          : teacherClassNum // ignore: cast_nullable_to_non_nullable
              as int?,
      classroomName: freezed == classroomName
          ? _value.classroomName
          : classroomName // ignore: cast_nullable_to_non_nullable
              as String?,
      classroomRoomType: freezed == classroomRoomType
          ? _value.classroomRoomType
          : classroomRoomType // ignore: cast_nullable_to_non_nullable
              as String?,
      classroomLocation: freezed == classroomLocation
          ? _value.classroomLocation
          : classroomLocation // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReservationImplCopyWith<$Res>
    implements $ReservationCopyWith<$Res> {
  factory _$$ReservationImplCopyWith(
          _$ReservationImpl value, $Res Function(_$ReservationImpl) then) =
      __$$ReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'classroom_id') String classroomId,
      @JsonKey(name: 'teacher_id') String teacherId,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime endTime,
      String? title,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      List<int>? periods,
      @JsonKey(name: 'teacher_name') String? teacherName,
      @JsonKey(name: 'teacher_grade') int? teacherGrade,
      @JsonKey(name: 'teacher_class_num') int? teacherClassNum,
      @JsonKey(name: 'classroom_name') String? classroomName,
      @JsonKey(name: 'classroom_room_type') String? classroomRoomType,
      @JsonKey(name: 'classroom_location') String? classroomLocation});
}

/// @nodoc
class __$$ReservationImplCopyWithImpl<$Res>
    extends _$ReservationCopyWithImpl<$Res, _$ReservationImpl>
    implements _$$ReservationImplCopyWith<$Res> {
  __$$ReservationImplCopyWithImpl(
      _$ReservationImpl _value, $Res Function(_$ReservationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classroomId = null,
    Object? teacherId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? periods = freezed,
    Object? teacherName = freezed,
    Object? teacherGrade = freezed,
    Object? teacherClassNum = freezed,
    Object? classroomName = freezed,
    Object? classroomRoomType = freezed,
    Object? classroomLocation = freezed,
  }) {
    return _then(_$ReservationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: null == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periods: freezed == periods
          ? _value._periods
          : periods // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      teacherName: freezed == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String?,
      teacherGrade: freezed == teacherGrade
          ? _value.teacherGrade
          : teacherGrade // ignore: cast_nullable_to_non_nullable
              as int?,
      teacherClassNum: freezed == teacherClassNum
          ? _value.teacherClassNum
          : teacherClassNum // ignore: cast_nullable_to_non_nullable
              as int?,
      classroomName: freezed == classroomName
          ? _value.classroomName
          : classroomName // ignore: cast_nullable_to_non_nullable
              as String?,
      classroomRoomType: freezed == classroomRoomType
          ? _value.classroomRoomType
          : classroomRoomType // ignore: cast_nullable_to_non_nullable
              as String?,
      classroomLocation: freezed == classroomLocation
          ? _value.classroomLocation
          : classroomLocation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationImpl extends _Reservation {
  const _$ReservationImpl(
      {required this.id,
      @JsonKey(name: 'classroom_id') required this.classroomId,
      @JsonKey(name: 'teacher_id') required this.teacherId,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      this.title,
      this.description,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      final List<int>? periods,
      @JsonKey(name: 'teacher_name') this.teacherName,
      @JsonKey(name: 'teacher_grade') this.teacherGrade,
      @JsonKey(name: 'teacher_class_num') this.teacherClassNum,
      @JsonKey(name: 'classroom_name') this.classroomName,
      @JsonKey(name: 'classroom_room_type') this.classroomRoomType,
      @JsonKey(name: 'classroom_location') this.classroomLocation})
      : _periods = periods,
        super._();

  factory _$ReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'classroom_id')
  final String classroomId;
  @override
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;
// v0.2: 교시 기반 예약
  final List<int>? _periods;
// v0.2: 교시 기반 예약
  @override
  List<int>? get periods {
    final value = _periods;
    if (value == null) return null;
    if (_periods is EqualUnmodifiableListView) return _periods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// [1, 2, 3] 형태로 교시 저장
// 예약자 정보 (JOIN용)
  @override
  @JsonKey(name: 'teacher_name')
  final String? teacherName;
  @override
  @JsonKey(name: 'teacher_grade')
  final int? teacherGrade;
  @override
  @JsonKey(name: 'teacher_class_num')
  final int? teacherClassNum;
// 교실 정보 (JOIN용)
  @override
  @JsonKey(name: 'classroom_name')
  final String? classroomName;
  @override
  @JsonKey(name: 'classroom_room_type')
  final String? classroomRoomType;
  @override
  @JsonKey(name: 'classroom_location')
  final String? classroomLocation;

  @override
  String toString() {
    return 'Reservation(id: $id, classroomId: $classroomId, teacherId: $teacherId, startTime: $startTime, endTime: $endTime, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, periods: $periods, teacherName: $teacherName, teacherGrade: $teacherGrade, teacherClassNum: $teacherClassNum, classroomName: $classroomName, classroomRoomType: $classroomRoomType, classroomLocation: $classroomLocation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            const DeepCollectionEquality().equals(other._periods, _periods) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.teacherGrade, teacherGrade) ||
                other.teacherGrade == teacherGrade) &&
            (identical(other.teacherClassNum, teacherClassNum) ||
                other.teacherClassNum == teacherClassNum) &&
            (identical(other.classroomName, classroomName) ||
                other.classroomName == classroomName) &&
            (identical(other.classroomRoomType, classroomRoomType) ||
                other.classroomRoomType == classroomRoomType) &&
            (identical(other.classroomLocation, classroomLocation) ||
                other.classroomLocation == classroomLocation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      classroomId,
      teacherId,
      startTime,
      endTime,
      title,
      description,
      createdAt,
      updatedAt,
      deletedAt,
      const DeepCollectionEquality().hash(_periods),
      teacherName,
      teacherGrade,
      teacherClassNum,
      classroomName,
      classroomRoomType,
      classroomLocation);

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationImplCopyWith<_$ReservationImpl> get copyWith =>
      __$$ReservationImplCopyWithImpl<_$ReservationImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Reservation value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Reservation value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Reservation value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationImplToJson(
      this,
    );
  }
}

abstract class _Reservation extends Reservation {
  const factory _Reservation(
      {required final String id,
      @JsonKey(name: 'classroom_id') required final String classroomId,
      @JsonKey(name: 'teacher_id') required final String teacherId,
      @JsonKey(name: 'start_time') required final DateTime startTime,
      @JsonKey(name: 'end_time') required final DateTime endTime,
      final String? title,
      final String? description,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
      final List<int>? periods,
      @JsonKey(name: 'teacher_name') final String? teacherName,
      @JsonKey(name: 'teacher_grade') final int? teacherGrade,
      @JsonKey(name: 'teacher_class_num') final int? teacherClassNum,
      @JsonKey(name: 'classroom_name') final String? classroomName,
      @JsonKey(name: 'classroom_room_type') final String? classroomRoomType,
      @JsonKey(name: 'classroom_location')
      final String? classroomLocation}) = _$ReservationImpl;
  const _Reservation._() : super._();

  factory _Reservation.fromJson(Map<String, dynamic> json) =
      _$ReservationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'classroom_id')
  String get classroomId;
  @override
  @JsonKey(name: 'teacher_id')
  String get teacherId;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  @JsonKey(name: 'end_time')
  DateTime get endTime;
  @override
  String? get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt; // v0.2: 교시 기반 예약
  @override
  List<int>? get periods; // [1, 2, 3] 형태로 교시 저장
// 예약자 정보 (JOIN용)
  @override
  @JsonKey(name: 'teacher_name')
  String? get teacherName;
  @override
  @JsonKey(name: 'teacher_grade')
  int? get teacherGrade;
  @override
  @JsonKey(name: 'teacher_class_num')
  int? get teacherClassNum; // 교실 정보 (JOIN용)
  @override
  @JsonKey(name: 'classroom_name')
  String? get classroomName;
  @override
  @JsonKey(name: 'classroom_room_type')
  String? get classroomRoomType;
  @override
  @JsonKey(name: 'classroom_location')
  String? get classroomLocation;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationImplCopyWith<_$ReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
