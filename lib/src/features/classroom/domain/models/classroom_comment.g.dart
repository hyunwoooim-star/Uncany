// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassroomCommentImpl _$$ClassroomCommentImplFromJson(
        Map<String, dynamic> json) =>
    _$ClassroomCommentImpl(
      id: json['id'] as String,
      classroomId: json['classroom_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      isResolved: json['is_resolved'] as bool? ?? false,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolvedBy: json['resolved_by'] as String?,
      commentType: json['comment_type'] as String? ?? 'general',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      userName: json['user_name'] as String?,
      userGrade: (json['user_grade'] as num?)?.toInt(),
      userClassNum: (json['user_class_num'] as num?)?.toInt(),
      resolverName: json['resolver_name'] as String?,
    );

Map<String, dynamic> _$$ClassroomCommentImplToJson(
        _$ClassroomCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classroom_id': instance.classroomId,
      'user_id': instance.userId,
      'content': instance.content,
      'is_resolved': instance.isResolved,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolved_by': instance.resolvedBy,
      'comment_type': instance.commentType,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'user_name': instance.userName,
      'user_grade': instance.userGrade,
      'user_class_num': instance.userClassNum,
      'resolver_name': instance.resolverName,
    };
