// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassroomImpl _$$ClassroomImplFromJson(Map<String, dynamic> json) =>
    _$ClassroomImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      accessCodeHash: json['access_code_hash'] as String?,
      noticeMessage: json['notice_message'] as String?,
      noticeUpdatedAt: json['notice_updated_at'] == null
          ? null
          : DateTime.parse(json['notice_updated_at'] as String),
      capacity: (json['capacity'] as num?)?.toInt(),
      location: json['location'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      schoolId: json['school_id'] as String?,
      roomType: json['room_type'] as String? ?? 'other',
      periodSettings: json['period_settings'] as Map<String, dynamic>?,
      createdBy: json['created_by'] as String?,
      creatorName: json['creator_name'] as String?,
      creatorGrade: (json['creator_grade'] as num?)?.toInt(),
      creatorClassNum: (json['creator_class_num'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ClassroomImplToJson(_$ClassroomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'access_code_hash': instance.accessCodeHash,
      'notice_message': instance.noticeMessage,
      'notice_updated_at': instance.noticeUpdatedAt?.toIso8601String(),
      'capacity': instance.capacity,
      'location': instance.location,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'school_id': instance.schoolId,
      'room_type': instance.roomType,
      'period_settings': instance.periodSettings,
      'created_by': instance.createdBy,
      'creator_name': instance.creatorName,
      'creator_grade': instance.creatorGrade,
      'creator_class_num': instance.creatorClassNum,
    };
