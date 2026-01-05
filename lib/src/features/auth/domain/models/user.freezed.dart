// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'school_name')
  String get schoolName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'education_office')
  String? get educationOffice => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'verification_status')
  VerificationStatus get verificationStatus =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'verification_document_url')
  String? get verificationDocumentUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejected_reason')
  String? get rejectedReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // v0.2: 학교 기반 멀티테넌시
  @JsonKey(name: 'school_id')
  String? get schoolId => throw _privateConstructorUsedError;
  int? get grade => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_num')
  int? get classNum => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_User value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_User value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_User value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'school_name') String schoolName,
      String? email,
      @JsonKey(name: 'education_office') String? educationOffice,
      UserRole role,
      @JsonKey(name: 'verification_status')
      VerificationStatus verificationStatus,
      @JsonKey(name: 'verification_document_url')
      String? verificationDocumentUrl,
      @JsonKey(name: 'rejected_reason') String? rejectedReason,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      @JsonKey(name: 'school_id') String? schoolId,
      int? grade,
      @JsonKey(name: 'class_num') int? classNum,
      String? username});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? schoolName = null,
    Object? email = freezed,
    Object? educationOffice = freezed,
    Object? role = null,
    Object? verificationStatus = null,
    Object? verificationDocumentUrl = freezed,
    Object? rejectedReason = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? schoolId = freezed,
    Object? grade = freezed,
    Object? classNum = freezed,
    Object? username = freezed,
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
      schoolName: null == schoolName
          ? _value.schoolName
          : schoolName // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      educationOffice: freezed == educationOffice
          ? _value.educationOffice
          : educationOffice // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as VerificationStatus,
      verificationDocumentUrl: freezed == verificationDocumentUrl
          ? _value.verificationDocumentUrl
          : verificationDocumentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectedReason: freezed == rejectedReason
          ? _value.rejectedReason
          : rejectedReason // ignore: cast_nullable_to_non_nullable
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
      schoolId: freezed == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as int?,
      classNum: freezed == classNum
          ? _value.classNum
          : classNum // ignore: cast_nullable_to_non_nullable
              as int?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'school_name') String schoolName,
      String? email,
      @JsonKey(name: 'education_office') String? educationOffice,
      UserRole role,
      @JsonKey(name: 'verification_status')
      VerificationStatus verificationStatus,
      @JsonKey(name: 'verification_document_url')
      String? verificationDocumentUrl,
      @JsonKey(name: 'rejected_reason') String? rejectedReason,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      @JsonKey(name: 'school_id') String? schoolId,
      int? grade,
      @JsonKey(name: 'class_num') int? classNum,
      String? username});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? schoolName = null,
    Object? email = freezed,
    Object? educationOffice = freezed,
    Object? role = null,
    Object? verificationStatus = null,
    Object? verificationDocumentUrl = freezed,
    Object? rejectedReason = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? schoolId = freezed,
    Object? grade = freezed,
    Object? classNum = freezed,
    Object? username = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      schoolName: null == schoolName
          ? _value.schoolName
          : schoolName // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      educationOffice: freezed == educationOffice
          ? _value.educationOffice
          : educationOffice // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as VerificationStatus,
      verificationDocumentUrl: freezed == verificationDocumentUrl
          ? _value.verificationDocumentUrl
          : verificationDocumentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectedReason: freezed == rejectedReason
          ? _value.rejectedReason
          : rejectedReason // ignore: cast_nullable_to_non_nullable
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
      schoolId: freezed == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as int?,
      classNum: freezed == classNum
          ? _value.classNum
          : classNum // ignore: cast_nullable_to_non_nullable
              as int?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl extends _User {
  const _$UserImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'school_name') required this.schoolName,
      this.email,
      @JsonKey(name: 'education_office') this.educationOffice,
      this.role = UserRole.teacher,
      @JsonKey(name: 'verification_status')
      this.verificationStatus = VerificationStatus.pending,
      @JsonKey(name: 'verification_document_url') this.verificationDocumentUrl,
      @JsonKey(name: 'rejected_reason') this.rejectedReason,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      @JsonKey(name: 'school_id') this.schoolId,
      this.grade,
      @JsonKey(name: 'class_num') this.classNum,
      this.username})
      : super._();

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'school_name')
  final String schoolName;
  @override
  final String? email;
  @override
  @JsonKey(name: 'education_office')
  final String? educationOffice;
  @override
  @JsonKey()
  final UserRole role;
  @override
  @JsonKey(name: 'verification_status')
  final VerificationStatus verificationStatus;
  @override
  @JsonKey(name: 'verification_document_url')
  final String? verificationDocumentUrl;
  @override
  @JsonKey(name: 'rejected_reason')
  final String? rejectedReason;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;
// v0.2: 학교 기반 멀티테넌시
  @override
  @JsonKey(name: 'school_id')
  final String? schoolId;
  @override
  final int? grade;
  @override
  @JsonKey(name: 'class_num')
  final int? classNum;
  @override
  final String? username;

  @override
  String toString() {
    return 'User(id: $id, name: $name, schoolName: $schoolName, email: $email, educationOffice: $educationOffice, role: $role, verificationStatus: $verificationStatus, verificationDocumentUrl: $verificationDocumentUrl, rejectedReason: $rejectedReason, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, schoolId: $schoolId, grade: $grade, classNum: $classNum, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.schoolName, schoolName) ||
                other.schoolName == schoolName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.educationOffice, educationOffice) ||
                other.educationOffice == educationOffice) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.verificationStatus, verificationStatus) ||
                other.verificationStatus == verificationStatus) &&
            (identical(
                    other.verificationDocumentUrl, verificationDocumentUrl) ||
                other.verificationDocumentUrl == verificationDocumentUrl) &&
            (identical(other.rejectedReason, rejectedReason) ||
                other.rejectedReason == rejectedReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.classNum, classNum) ||
                other.classNum == classNum) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      schoolName,
      email,
      educationOffice,
      role,
      verificationStatus,
      verificationDocumentUrl,
      rejectedReason,
      createdAt,
      updatedAt,
      deletedAt,
      schoolId,
      grade,
      classNum,
      username);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_User value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_User value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_User value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User extends User {
  const factory _User(
      {required final String id,
      required final String name,
      @JsonKey(name: 'school_name') required final String schoolName,
      final String? email,
      @JsonKey(name: 'education_office') final String? educationOffice,
      final UserRole role,
      @JsonKey(name: 'verification_status')
      final VerificationStatus verificationStatus,
      @JsonKey(name: 'verification_document_url')
      final String? verificationDocumentUrl,
      @JsonKey(name: 'rejected_reason') final String? rejectedReason,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
      @JsonKey(name: 'school_id') final String? schoolId,
      final int? grade,
      @JsonKey(name: 'class_num') final int? classNum,
      final String? username}) = _$UserImpl;
  const _User._() : super._();

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'school_name')
  String get schoolName;
  @override
  String? get email;
  @override
  @JsonKey(name: 'education_office')
  String? get educationOffice;
  @override
  UserRole get role;
  @override
  @JsonKey(name: 'verification_status')
  VerificationStatus get verificationStatus;
  @override
  @JsonKey(name: 'verification_document_url')
  String? get verificationDocumentUrl;
  @override
  @JsonKey(name: 'rejected_reason')
  String? get rejectedReason;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt; // v0.2: 학교 기반 멀티테넌시
  @override
  @JsonKey(name: 'school_id')
  String? get schoolId;
  @override
  int? get grade;
  @override
  @JsonKey(name: 'class_num')
  int? get classNum;
  @override
  String? get username;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
