import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral_code.freezed.dart';
part 'referral_code.g.dart';

/// 추천인 코드 모델
@freezed
class ReferralCode with _$ReferralCode {
  const factory ReferralCode({
    required String id,
    required String code, // 예: "SEOUL-ABC123"
    required String createdBy, // 생성자 User ID
    required String schoolName, // 같은 학교 검증용
    @Default(5) int maxUses, // 최대 사용 횟수
    @Default(0) int currentUses, // 현재 사용 횟수
    DateTime? expiresAt, // 만료 일시
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _ReferralCode;

  factory ReferralCode.fromJson(Map<String, dynamic> json) =>
      _$ReferralCodeFromJson(json);
}

/// 추천 코드 확장
extension ReferralCodeX on ReferralCode {
  /// 사용 가능한지 확인
  bool get isAvailable {
    if (!isActive) return false;
    if (currentUses >= maxUses) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    return true;
  }

  /// 남은 사용 횟수
  int get remainingUses => maxUses - currentUses;

  /// 만료까지 남은 일수
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }
}
