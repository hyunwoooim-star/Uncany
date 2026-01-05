// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SchoolImpl _$$SchoolImplFromJson(Map<String, dynamic> json) => _$SchoolImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      type: json['type'] as String? ?? 'elementary',
      educationOffice: json['education_office'] as String?,
      neisCode: json['neis_code'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SchoolImplToJson(_$SchoolImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'type': instance.type,
      'education_office': instance.educationOffice,
      'neis_code': instance.neisCode,
      'created_at': instance.createdAt?.toIso8601String(),
    };
