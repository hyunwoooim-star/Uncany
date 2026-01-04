import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

/// 예약 모델
@freezed
class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String classroomId,
    required String teacherId,
    required DateTime startTime,
    required DateTime endTime,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt, // Soft Delete
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

/// 예약 상태 계산용 확장
extension ReservationX on Reservation {
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
}
