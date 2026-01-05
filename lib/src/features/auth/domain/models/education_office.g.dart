// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_office.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EducationOfficeImpl _$$EducationOfficeImplFromJson(
        Map<String, dynamic> json) =>
    _$EducationOfficeImpl(
      code: json['code'] as String,
      nameKo: json['nameKo'] as String,
      emailDomain: json['emailDomain'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EducationOfficeImplToJson(
        _$EducationOfficeImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'nameKo': instance.nameKo,
      'emailDomain': instance.emailDomain,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
