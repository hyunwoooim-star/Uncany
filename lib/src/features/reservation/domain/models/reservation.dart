import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

/// 예약 모델 - v0.2
@freezed
class Reservation with _$Reservation {
  const Reservation._();

  const factory Reservation({
    required String id,
    @JsonKey(name: 'classroom_id') required String classroomId,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    String? title,
    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    // v0.2: 교시 기반 예약
    List<int>? periods,  // [1, 2, 3] 형태로 교시 저장
    // 예약자 정보 (JOIN용)
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'teacher_grade') int? teacherGrade,
    @JsonKey(name: 'teacher_class_num') int? teacherClassNum,
    // 교실 정보 (JOIN용)
    @JsonKey(name: 'classroom_name') String? classroomName,
    @JsonKey(name: 'classroom_room_type') String? classroomRoomType,
    @JsonKey(name: 'classroom_location') String? classroomLocation,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  /// 예약이 활성 상태인지 (삭제되지 않음)
  bool get isActive => deletedAt == null;

  /// 예약이 진행 중인지
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime) && isActive;
  }

  /// 예약이 예정되어 있는지
  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startTime) && isActive;
  }

  /// 예약이 완료되었는지
  bool get isCompleted {
    final now = DateTime.now();
    return now.isAfter(endTime) || !isActive;
  }

  /// 예약 기간 (분)
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// 교시 표시 (연속: 1~3교시, 비연속: 1, 3, 5교시)
  String? get periodsDisplay {
    if (periods == null || periods!.isEmpty) return null;
    final sorted = List<int>.from(periods!)..sort();
    if (sorted.length == 1) {
      return '${sorted.first}교시';
    }

    // 연속된 교시인지 확인
    bool isConsecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) {
        isConsecutive = false;
        break;
      }
    }

    if (isConsecutive) {
      return '${sorted.first}~${sorted.last}교시';
    } else {
      return '${sorted.join(", ")}교시';
    }
  }

  /// 예약자 전체 표시: "임현우 선생님 (3학년 2반)"
  String get teacherDisplayName {
    if (teacherName == null) return '알 수 없음';
    if (teacherGrade != null && teacherClassNum != null) {
      return '$teacherName 선생님 ($teacherGrade학년 $teacherClassNum반)';
    } else if (teacherGrade != null) {
      return '$teacherName 선생님 ($teacherGrade학년)';
    }
    return '$teacherName 선생님';
  }

  /// 짧은 예약자 표시: "임현우 선생님"
  String get teacherShortName {
    if (teacherName == null) return '알 수 없음';
    return '$teacherName 선생님';
  }
}
