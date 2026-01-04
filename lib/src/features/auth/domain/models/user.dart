import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 사용자 (교사) 모델
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String schoolName,
    String? email,
    String? educationOffice, // 교육청 코드 (seoul, busan 등)
    @Default(UserRole.teacher) UserRole role,
    @Default(VerificationStatus.pending)
    VerificationStatus verificationStatus,
    String? verificationDocumentUrl,
    String? rejectedReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
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
