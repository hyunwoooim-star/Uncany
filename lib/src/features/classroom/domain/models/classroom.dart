import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom.freezed.dart';
part 'classroom.g.dart';

/// 교실/리소스 모델
@freezed
class Classroom with _$Classroom {
  const factory Classroom({
    required String id,
    required String name,
    @JsonKey(name: 'access_code_hash') String? accessCodeHash,
    @JsonKey(name: 'notice_message') String? noticeMessage,
    @JsonKey(name: 'notice_updated_at') DateTime? noticeUpdatedAt,
    int? capacity,
    String? location,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Classroom;

  factory Classroom.fromJson(Map<String, dynamic> json) =>
      _$ClassroomFromJson(json);
}
