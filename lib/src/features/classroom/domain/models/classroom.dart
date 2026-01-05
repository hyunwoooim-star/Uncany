import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom.freezed.dart';
part 'classroom.g.dart';

/// 교실/리소스 모델 - v0.2
@freezed
class Classroom with _$Classroom {
  const Classroom._();

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
    // v0.2: 학교 기반 멀티테넌시
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'room_type') @Default('other') String roomType,
    @JsonKey(name: 'period_settings') Map<String, dynamic>? periodSettings,
    @JsonKey(name: 'created_by') String? createdBy,
  }) = _Classroom;

  factory Classroom.fromJson(Map<String, dynamic> json) =>
      _$ClassroomFromJson(json);

  /// 교실 유형 라벨 (한글)
  String get roomTypeLabel {
    switch (roomType) {
      case 'computer': return '컴퓨터실';
      case 'music': return '음악실';
      case 'science': return '과학실';
      case 'art': return '미술실';
      case 'library': return '도서실';
      case 'gym': return '체육관';
      case 'auditorium': return '강당';
      case 'special': return '특별실';
      default: return '기타';
    }
  }
}
