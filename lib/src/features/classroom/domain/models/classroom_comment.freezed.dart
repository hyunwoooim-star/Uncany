// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classroom_comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassroomComment _$ClassroomCommentFromJson(Map<String, dynamic> json) {
  return _ClassroomComment.fromJson(json);
}

/// @nodoc
mixin _$ClassroomComment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'classroom_id')
  String get classroomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError; // 문제 해결 여부
  @JsonKey(name: 'is_resolved')
  bool get isResolved => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError; // 댓글 유형
  @JsonKey(name: 'comment_type')
  String get commentType => throw _privateConstructorUsedError; // 타임스탬프
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // JOIN으로 가져오는 사용자 정보
  @JsonKey(name: 'user_name')
  String? get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_grade')
  int? get userGrade => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_class_num')
  int? get userClassNum => throw _privateConstructorUsedError; // 해결자 정보 (JOIN)
  @JsonKey(name: 'resolver_name')
  String? get resolverName => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ClassroomComment value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ClassroomComment value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ClassroomComment value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ClassroomComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassroomComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassroomCommentCopyWith<ClassroomComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomCommentCopyWith<$Res> {
  factory $ClassroomCommentCopyWith(
          ClassroomComment value, $Res Function(ClassroomComment) then) =
      _$ClassroomCommentCopyWithImpl<$Res, ClassroomComment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'classroom_id') String classroomId,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'is_resolved') bool isResolved,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'comment_type') String commentType,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      @JsonKey(name: 'user_name') String? userName,
      @JsonKey(name: 'user_grade') int? userGrade,
      @JsonKey(name: 'user_class_num') int? userClassNum,
      @JsonKey(name: 'resolver_name') String? resolverName});
}

/// @nodoc
class _$ClassroomCommentCopyWithImpl<$Res, $Val extends ClassroomComment>
    implements $ClassroomCommentCopyWith<$Res> {
  _$ClassroomCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassroomComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classroomId = null,
    Object? userId = null,
    Object? content = null,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? commentType = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? userName = freezed,
    Object? userGrade = freezed,
    Object? userClassNum = freezed,
    Object? resolverName = freezed,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      commentType: null == commentType
          ? _value.commentType
          : commentType // ignore: cast_nullable_to_non_nullable
              as String,
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
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userGrade: freezed == userGrade
          ? _value.userGrade
          : userGrade // ignore: cast_nullable_to_non_nullable
              as int?,
      userClassNum: freezed == userClassNum
          ? _value.userClassNum
          : userClassNum // ignore: cast_nullable_to_non_nullable
              as int?,
      resolverName: freezed == resolverName
          ? _value.resolverName
          : resolverName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomCommentImplCopyWith<$Res>
    implements $ClassroomCommentCopyWith<$Res> {
  factory _$$ClassroomCommentImplCopyWith(_$ClassroomCommentImpl value,
          $Res Function(_$ClassroomCommentImpl) then) =
      __$$ClassroomCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'classroom_id') String classroomId,
      @JsonKey(name: 'user_id') String userId,
      String content,
      @JsonKey(name: 'is_resolved') bool isResolved,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'comment_type') String commentType,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'deleted_at') DateTime? deletedAt,
      @JsonKey(name: 'user_name') String? userName,
      @JsonKey(name: 'user_grade') int? userGrade,
      @JsonKey(name: 'user_class_num') int? userClassNum,
      @JsonKey(name: 'resolver_name') String? resolverName});
}

/// @nodoc
class __$$ClassroomCommentImplCopyWithImpl<$Res>
    extends _$ClassroomCommentCopyWithImpl<$Res, _$ClassroomCommentImpl>
    implements _$$ClassroomCommentImplCopyWith<$Res> {
  __$$ClassroomCommentImplCopyWithImpl(_$ClassroomCommentImpl _value,
      $Res Function(_$ClassroomCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassroomComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classroomId = null,
    Object? userId = null,
    Object? content = null,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? commentType = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? userName = freezed,
    Object? userGrade = freezed,
    Object? userClassNum = freezed,
    Object? resolverName = freezed,
  }) {
    return _then(_$ClassroomCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      commentType: null == commentType
          ? _value.commentType
          : commentType // ignore: cast_nullable_to_non_nullable
              as String,
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
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userGrade: freezed == userGrade
          ? _value.userGrade
          : userGrade // ignore: cast_nullable_to_non_nullable
              as int?,
      userClassNum: freezed == userClassNum
          ? _value.userClassNum
          : userClassNum // ignore: cast_nullable_to_non_nullable
              as int?,
      resolverName: freezed == resolverName
          ? _value.resolverName
          : resolverName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomCommentImpl extends _ClassroomComment {
  const _$ClassroomCommentImpl(
      {required this.id,
      @JsonKey(name: 'classroom_id') required this.classroomId,
      @JsonKey(name: 'user_id') required this.userId,
      required this.content,
      @JsonKey(name: 'is_resolved') this.isResolved = false,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      @JsonKey(name: 'resolved_by') this.resolvedBy,
      @JsonKey(name: 'comment_type') this.commentType = 'general',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      @JsonKey(name: 'user_name') this.userName,
      @JsonKey(name: 'user_grade') this.userGrade,
      @JsonKey(name: 'user_class_num') this.userClassNum,
      @JsonKey(name: 'resolver_name') this.resolverName})
      : super._();

  factory _$ClassroomCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomCommentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'classroom_id')
  final String classroomId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String content;
// 문제 해결 여부
  @override
  @JsonKey(name: 'is_resolved')
  final bool isResolved;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
// 댓글 유형
  @override
  @JsonKey(name: 'comment_type')
  final String commentType;
// 타임스탬프
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;
// JOIN으로 가져오는 사용자 정보
  @override
  @JsonKey(name: 'user_name')
  final String? userName;
  @override
  @JsonKey(name: 'user_grade')
  final int? userGrade;
  @override
  @JsonKey(name: 'user_class_num')
  final int? userClassNum;
// 해결자 정보 (JOIN)
  @override
  @JsonKey(name: 'resolver_name')
  final String? resolverName;

  @override
  String toString() {
    return 'ClassroomComment(id: $id, classroomId: $classroomId, userId: $userId, content: $content, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, commentType: $commentType, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, userName: $userName, userGrade: $userGrade, userClassNum: $userClassNum, resolverName: $resolverName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.commentType, commentType) ||
                other.commentType == commentType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userGrade, userGrade) ||
                other.userGrade == userGrade) &&
            (identical(other.userClassNum, userClassNum) ||
                other.userClassNum == userClassNum) &&
            (identical(other.resolverName, resolverName) ||
                other.resolverName == resolverName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      classroomId,
      userId,
      content,
      isResolved,
      resolvedAt,
      resolvedBy,
      commentType,
      createdAt,
      updatedAt,
      deletedAt,
      userName,
      userGrade,
      userClassNum,
      resolverName);

  /// Create a copy of ClassroomComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomCommentImplCopyWith<_$ClassroomCommentImpl> get copyWith =>
      __$$ClassroomCommentImplCopyWithImpl<_$ClassroomCommentImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ClassroomComment value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ClassroomComment value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ClassroomComment value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomCommentImplToJson(
      this,
    );
  }
}

abstract class _ClassroomComment extends ClassroomComment {
  const factory _ClassroomComment(
          {required final String id,
          @JsonKey(name: 'classroom_id') required final String classroomId,
          @JsonKey(name: 'user_id') required final String userId,
          required final String content,
          @JsonKey(name: 'is_resolved') final bool isResolved,
          @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
          @JsonKey(name: 'resolved_by') final String? resolvedBy,
          @JsonKey(name: 'comment_type') final String commentType,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt,
          @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
          @JsonKey(name: 'user_name') final String? userName,
          @JsonKey(name: 'user_grade') final int? userGrade,
          @JsonKey(name: 'user_class_num') final int? userClassNum,
          @JsonKey(name: 'resolver_name') final String? resolverName}) =
      _$ClassroomCommentImpl;
  const _ClassroomComment._() : super._();

  factory _ClassroomComment.fromJson(Map<String, dynamic> json) =
      _$ClassroomCommentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'classroom_id')
  String get classroomId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get content; // 문제 해결 여부
  @override
  @JsonKey(name: 'is_resolved')
  bool get isResolved;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy; // 댓글 유형
  @override
  @JsonKey(name: 'comment_type')
  String get commentType; // 타임스탬프
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt; // JOIN으로 가져오는 사용자 정보
  @override
  @JsonKey(name: 'user_name')
  String? get userName;
  @override
  @JsonKey(name: 'user_grade')
  int? get userGrade;
  @override
  @JsonKey(name: 'user_class_num')
  int? get userClassNum; // 해결자 정보 (JOIN)
  @override
  @JsonKey(name: 'resolver_name')
  String? get resolverName;

  /// Create a copy of ClassroomComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassroomCommentImplCopyWith<_$ClassroomCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
