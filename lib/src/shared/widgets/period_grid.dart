import 'package:flutter/material.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/core/constants/period_times.dart';
import 'package:uncany/src/features/reservation/domain/models/reservation.dart';

/// 교시 그리드 위젯
///
/// 1~10교시를 그리드 형태로 표시
/// - 비어있음: 선택 가능 (흰색)
/// - 선택됨: 선택 중 (파란색)
/// - 예약됨: 다른 사람 예약 (회색, 선택 불가)
class PeriodGrid extends StatelessWidget {
  /// 선택된 교시 목록
  final Set<int> selectedPeriods;

  /// 예약된 교시 맵 (교시 번호 -> 예약 정보)
  final Map<int, Reservation> reservedPeriods;

  /// 교시 선택 콜백
  final void Function(int period)? onPeriodTap;

  /// 현재 로그인한 사용자 ID
  final String? currentUserId;

  /// 표시할 최대 교시 수 (기본 6, 최대 10)
  final int maxPeriods;

  const PeriodGrid({
    super.key,
    required this.selectedPeriods,
    required this.reservedPeriods,
    this.onPeriodTap,
    this.currentUserId,
    this.maxPeriods = 6,
  });

  @override
  Widget build(BuildContext context) {
    final displayPeriods = maxPeriods.clamp(1, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Text(
                '교시 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TossColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              if (selectedPeriods.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TossColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedPeriods.length}개 선택',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: TossColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 범례
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              _LegendItem(color: Colors.white, label: '선택 가능'),
              const SizedBox(width: 12),
              _LegendItem(color: TossColors.primary, label: '선택됨'),
              const SizedBox(width: 12),
              _LegendItem(color: Colors.grey.shade300, label: '예약됨'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: displayPeriods,
          itemBuilder: (context, index) {
            final period = index + 1;
            final periodTime = PeriodTimes.getPeriod(period);
            final reservation = reservedPeriods[period];
            final isSelected = selectedPeriods.contains(period);
            final isReserved = reservation != null;
            final isMyReservation = isReserved &&
                currentUserId != null &&
                reservation.teacherId == currentUserId;

            return _PeriodCell(
              period: period,
              periodTime: periodTime,
              isSelected: isSelected,
              isReserved: isReserved,
              isMyReservation: isMyReservation,
              reservation: reservation,
              onTap: onPeriodTap != null && !isReserved
                  ? () => onPeriodTap!(period)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

/// 개별 교시 셀
class _PeriodCell extends StatelessWidget {
  final int period;
  final PeriodTime? periodTime;
  final bool isSelected;
  final bool isReserved;
  final bool isMyReservation;
  final Reservation? reservation;
  final VoidCallback? onTap;

  const _PeriodCell({
    required this.period,
    required this.periodTime,
    required this.isSelected,
    required this.isReserved,
    required this.isMyReservation,
    this.reservation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = TossColors.primary;
      textColor = Colors.white;
      borderColor = TossColors.primary;
    } else if (isReserved) {
      if (isMyReservation) {
        backgroundColor = TossColors.primary.withOpacity(0.2);
        textColor = TossColors.primary;
        borderColor = TossColors.primary.withOpacity(0.5);
      } else {
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
        borderColor = Colors.grey.shade300;
      }
    } else {
      backgroundColor = Colors.white;
      textColor = TossColors.textMain;
      borderColor = TossColors.divider;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 교시 번호
            Text(
              '$period교시',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),

            // 시간
            if (periodTime != null)
              Text(
                periodTime!.startTimeString,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : textColor.withOpacity(0.6),
                ),
              ),

            // 예약자 표시 (예약된 경우)
            if (isReserved && reservation != null) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  reservation!.teacherShortName,
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 범례 아이템
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: TossColors.textSub,
          ),
        ),
      ],
    );
  }
}

/// 확장형 교시 그리드 (상세 보기용)
class PeriodGridExpanded extends StatelessWidget {
  final Set<int> selectedPeriods;
  final Map<int, Reservation> reservedPeriods;
  final void Function(int period)? onPeriodTap;
  final String? currentUserId;

  const PeriodGridExpanded({
    super.key,
    required this.selectedPeriods,
    required this.reservedPeriods,
    this.onPeriodTap,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final period = index + 1;
        final periodTime = PeriodTimes.getPeriod(period);
        final reservation = reservedPeriods[period];
        final isSelected = selectedPeriods.contains(period);
        final isReserved = reservation != null;
        final isMyReservation = isReserved &&
            currentUserId != null &&
            reservation.teacherId == currentUserId;

        return _PeriodRow(
          period: period,
          periodTime: periodTime,
          isSelected: isSelected,
          isReserved: isReserved,
          isMyReservation: isMyReservation,
          reservation: reservation,
          onTap: onPeriodTap != null && !isReserved
              ? () => onPeriodTap!(period)
              : null,
        );
      },
    );
  }
}

/// 교시 행 (리스트 형태)
class _PeriodRow extends StatelessWidget {
  final int period;
  final PeriodTime? periodTime;
  final bool isSelected;
  final bool isReserved;
  final bool isMyReservation;
  final Reservation? reservation;
  final VoidCallback? onTap;

  const _PeriodRow({
    required this.period,
    required this.periodTime,
    required this.isSelected,
    required this.isReserved,
    required this.isMyReservation,
    this.reservation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = TossColors.primary;
      textColor = Colors.white;
      borderColor = TossColors.primary;
    } else if (isReserved) {
      if (isMyReservation) {
        backgroundColor = TossColors.primary.withOpacity(0.1);
        textColor = TossColors.primary;
        borderColor = TossColors.primary.withOpacity(0.3);
      } else {
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        borderColor = Colors.grey.shade200;
      }
    } else {
      backgroundColor = Colors.white;
      textColor = TossColors.textMain;
      borderColor = TossColors.divider;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // 교시 번호
            Container(
              width: 50,
              child: Text(
                '$period교시',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            // 시간
            if (periodTime != null)
              Expanded(
                child: Text(
                  periodTime!.timeRangeString,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : TossColors.textSub,
                  ),
                ),
              ),

            // 상태 표시
            if (isReserved && reservation != null)
              Expanded(
                child: Text(
                  reservation!.teacherDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              )
            else
              Icon(
                Icons.add_circle_outline,
                color: TossColors.textSub.withOpacity(0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
