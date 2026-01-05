import 'package:freezed_annotation/freezed_annotation.dart';

part 'school.freezed.dart';
part 'school.g.dart';

/// 학교 모델
@freezed
class School with _$School {
  const factory School({
    required String id,
    required String name,
    String? address,
    @Default('elementary') String type,
    @JsonKey(name: 'education_office') String? educationOffice,
    @JsonKey(name: 'neis_code') String? neisCode,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}

/// 학교 유형
enum SchoolType {
  @JsonValue('elementary')
  elementary, // 초등학교
  @JsonValue('middle')
  middle, // 중학교
  @JsonValue('high')
  high, // 고등학교
}
