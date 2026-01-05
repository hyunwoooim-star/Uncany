// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferralCodeImpl _$$ReferralCodeImplFromJson(Map<String, dynamic> json) =>
    _$ReferralCodeImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      createdBy: json['createdBy'] as String,
      schoolName: json['schoolName'] as String,
      maxUses: (json['maxUses'] as num?)?.toInt() ?? 5,
      currentUses: (json['currentUses'] as num?)?.toInt() ?? 0,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ReferralCodeImplToJson(_$ReferralCodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'createdBy': instance.createdBy,
      'schoolName': instance.schoolName,
      'maxUses': instance.maxUses,
      'currentUses': instance.currentUses,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
