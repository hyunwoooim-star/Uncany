import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 사용자 (교사) 모델 - v0.2
@freezed
class User with _$User {
  const User._();

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
    // v0.2: 학교 기반 멀티테넌시
    @JsonKey(name: 'school_id') String? schoolId,
    int? grade,
    @JsonKey(name: 'class_num') int? classNum,
    String? username,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// 표시용 이름: "임현우 선생님"
  String get displayName => '$name 선생님';

  /// 전체 표시: "임현우 선생님 (3학년 2반)"
  String get fullDisplayName {
    if (grade != null && classNum != null) {
      return '$name 선생님 ($grade학년 $classNum반)';
    } else if (grade != null) {
      return '$name 선생님 ($grade학년)';
    }
    return displayName;
  }

  /// 짧은 학년반 표시: "3학년 2반"
  String? get gradeClassDisplay {
    if (grade != null && classNum != null) {
      return '$grade학년 $classNum반';
    } else if (grade != null) {
      return '$grade학년';
    }
    return null;
  }
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
