import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/reservation.dart';
import '../../../../shared/theme/toss_colors.dart';

/// 시간표 그리드 위젯
///
/// 하루의 예약을 시간대별로 시각화하여 표시
class TimeTableGrid extends StatelessWidget {
  final List<Reservation> reservations;
  final DateTime selectedDate;
  final VoidCallback? onTimeSlotTap;
  final int startHour; // 시작 시간 (기본: 8시)
  final int endHour; // 종료 시간 (기본: 18시)

  const TimeTableGrid({
    super.key,
    required this.reservations,
    required this.selectedDate,
    this.onTimeSlotTap,
    this.startHour = 8,
    this.endHour = 18,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Column(
      children: [
        // 시간표 그리드
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: endHour - startHour,
            itemBuilder: (context, index) {
              final hour = startHour + index;
              final hourStart = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                hour,
              );
              final hourEnd = hourStart.add(const Duration(hours: 1));

              // 이 시간대의 예약 찾기
              final hourReservations = reservations.where((r) {
                return r.startTime.isBefore(hourEnd) &&
                    r.endTime.isAfter(hourStart);
              }).toList();

              // 현재 시간 표시 여부
              final isCurrentHour = isToday &&
                  now.hour == hour;

              return _HourRow(
                hour: hour,
                reservations: hourReservations,
                isCurrentHour: isCurrentHour,
                currentMinute: isCurrentHour ? now.minute : null,
                onTap: onTimeSlotTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourRow extends StatelessWidget {
  final int hour;
  final List<Reservation> reservations;
  final bool isCurrentHour;
  final int? currentMinute;
  final VoidCallback? onTap;

  const _HourRow({
    required this.hour,
    required this.reservations,
    required this.isCurrentHour,
    this.currentMinute,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:00');
    final hourTime = DateTime(2000, 1, 1, hour);

    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          // 배경 및 시간 레이블
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간 레이블
              SizedBox(
                width: 60,
                child: Text(
                  timeFormat.format(hourTime),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isCurrentHour
                        ? TossColors.primary
                        : TossColors.textSub,
                  ),
                ),
              ),

              // 시간대 영역
              Expanded(
                child: GestureDetector(
                  onTap: reservations.isEmpty ? onTap : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: reservations.isEmpty
                          ? TossColors.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentHour
                            ? TossColors.primary.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        width: isCurrentHour ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 현재 시간 인디케이터
                        if (isCurrentHour && currentMinute != null)
                          Positioned(
                            top: (currentMinute! / 60) * 80,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: TossColors.primary,
                            ),
                          ),

                        // 예약 블록들
                        ...reservations.map((reservation) {
                          return _ReservationBlock(
                            reservation: reservation,
                            hourStart: DateTime(2000, 1, 1, hour),
                          );
                        }),

                        // 빈 슬롯 힌트
                        if (reservations.isEmpty)
                          Center(
                            child: Text(
                              '예약 가능',
                              style: TextStyle(
                                fontSize: 12,
                                color: TossColors.textSub.withOpacity(0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReservationBlock extends StatelessWidget {
  final Reservation reservation;
  final DateTime hourStart;

  const _ReservationBlock({
    required this.reservation,
    required this.hourStart,
  });

  @override
  Widget build(BuildContext context) {
    final hourEnd = hourStart.add(const Duration(hours: 1));

    // 예약 시작/종료 시간을 이 시간대 내에서 계산
    final blockStart = reservation.startTime.isBefore(hourStart)
        ? hourStart
        : reservation.startTime;
    final blockEnd =
        reservation.endTime.isAfter(hourEnd) ? hourEnd : reservation.endTime;

    // 시간대 내에서의 위치 계산 (0.0 ~ 1.0)
    final startOffset = blockStart.difference(hourStart).inMinutes / 60;
    final duration = blockEnd.difference(blockStart).inMinutes / 60;

    // 상태별 색상
    Color color;
    if (reservation.isOngoing) {
      color = Colors.green;
    } else if (reservation.isUpcoming) {
      color = TossColors.primary;
    } else {
      color = Colors.grey;
    }

    return Positioned(
      top: startOffset * 80,
      left: 0,
      right: 0,
      height: duration * 80,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 시간 범위
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${DateFormat('HH:mm').format(reservation.startTime)} - ${DateFormat('HH:mm').format(reservation.endTime)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // 제목 (있는 경우)
            if (reservation.title != null && reservation.title!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                reservation.title!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: TossColors.textMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
