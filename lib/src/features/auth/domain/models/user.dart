import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 사용자 (교사) 모델
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    @JsonKey(name: 'school_name') required String schoolName,
    String? email,
    @JsonKey(name: 'education_office') String? educationOffice,
    @Default(UserRole.teacher) UserRole role,
    @JsonKey(name: 'verification_status')
    @Default(VerificationStatus.pending)
    VerificationStatus verificationStatus,
    @JsonKey(name: 'verification_document_url') String? verificationDocumentUrl,
    @JsonKey(name: 'rejected_reason') String? rejectedReason,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// 사용자 역할
enum UserRole {
  @JsonValue('teacher')
  teacher,
  @JsonValue('admin')
  admin,
}

/// 인증 상태
enum VerificationStatus {
  @JsonValue('pending')
  pending, // 승인 대기
  @JsonValue('approved')
  approved, // 승인 완료
  @JsonValue('rejected')
  rejected, // 반려
}
