// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      schoolName: json['school_name'] as String,
      email: json['email'] as String?,
      educationOffice: json['education_office'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.teacher,
      verificationStatus: $enumDecodeNullable(
              _$VerificationStatusEnumMap, json['verification_status']) ??
          VerificationStatus.pending,
      verificationDocumentUrl: json['verification_document_url'] as String?,
      rejectedReason: json['rejected_reason'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      schoolId: json['school_id'] as String?,
      grade: (json['grade'] as num?)?.toInt(),
      classNum: (json['class_num'] as num?)?.toInt(),
      username: json['username'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'school_name': instance.schoolName,
      'email': instance.email,
      'education_office': instance.educationOffice,
      'role': _$UserRoleEnumMap[instance.role]!,
      'verification_status':
          _$VerificationStatusEnumMap[instance.verificationStatus]!,
      'verification_document_url': instance.verificationDocumentUrl,
      'rejected_reason': instance.rejectedReason,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'school_id': instance.schoolId,
      'grade': instance.grade,
      'class_num': instance.classNum,
      'username': instance.username,
    };

const _$UserRoleEnumMap = {
  UserRole.teacher: 'teacher',
  UserRole.admin: 'admin',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};
