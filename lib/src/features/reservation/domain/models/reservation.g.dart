// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationImpl _$$ReservationImplFromJson(Map<String, dynamic> json) =>
    _$ReservationImpl(
      id: json['id'] as String,
      classroomId: json['classroom_id'] as String,
      teacherId: json['teacher_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      periods: (json['periods'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      teacherName: json['teacher_name'] as String?,
      teacherGrade: (json['teacher_grade'] as num?)?.toInt(),
      teacherClassNum: (json['teacher_class_num'] as num?)?.toInt(),
      classroomName: json['classroom_name'] as String?,
      classroomRoomType: json['classroom_room_type'] as String?,
    );

Map<String, dynamic> _$$ReservationImplToJson(_$ReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classroom_id': instance.classroomId,
      'teacher_id': instance.teacherId,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'periods': instance.periods,
      'teacher_name': instance.teacherName,
      'teacher_grade': instance.teacherGrade,
      'teacher_class_num': instance.teacherClassNum,
      'classroom_name': instance.classroomName,
      'classroom_room_type': instance.classroomRoomType,
    };
