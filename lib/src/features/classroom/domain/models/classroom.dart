import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom.freezed.dart';
part 'classroom.g.dart';

/// 교실/리소스 모델
@freezed
class Classroom with _$Classroom {
  const factory Classroom({
    required String id,
    required String name,
    String? accessCodeHash, // 비밀번호 보호 (Argon2 해시)
    String? noticeMessage, // 공지사항
    DateTime? noticeUpdatedAt,
    int? capacity, // 수용 인원
    String? location, // 위치 설명
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) = _Classroom;

  factory Classroom.fromJson(Map<String, dynamic> json) =>
      _$ClassroomFromJson(json);
}
