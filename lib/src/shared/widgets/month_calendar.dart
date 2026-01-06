import 'package:flutter/material.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';

/// 월간 캘린더 위젯
///
/// 참고: 수업 예약 앱 디자인
class MonthCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime? focusedMonth;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;

  const MonthCalendar({
    super.key,
    required this.selectedDate,
    this.focusedMonth,
    required this.onDateSelected,
    this.onMonthChanged,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.focusedMonth ?? widget.selectedDate;
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
    widget.onMonthChanged?.call(_focusedMonth);
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
    widget.onMonthChanged?.call(_focusedMonth);
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(today.year, today.month, 1);
    });
    widget.onDateSelected(today);
    widget.onMonthChanged?.call(_focusedMonth);
  }
  /// 날짜 데코레이션 - 오늘과 선택 날짜 구분
  BoxDecoration? _getDateDecoration(bool isToday, bool isSelected) {
    if (isSelected) {
      // 선택된 날짜: 파란색 채움
      return BoxDecoration(
        color: TossColors.primary,
        shape: BoxShape.circle,
      );
    } else if (isToday) {
      // 오늘 날짜 (선택 안됨): 파란색 테두리만
      return BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: TossColors.primary, width: 2),
      );
    }
    return null;
  }

  /// 날짜 텍스트 색상 - 오늘과 선택 날짜 구분
  Color _getDateTextColor(bool isToday, bool isSelected, Color defaultColor) {
    if (isSelected) {
      return Colors.white; // 선택: 흰색
    } else if (isToday) {
      return TossColors.primary; // 오늘 (선택 안됨): 파란색
    }
    return defaultColor;
  }

  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 월 네비게이션
        _buildMonthNavigation(),
        const SizedBox(height: 16),
        // 요일 헤더
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        // 날짜 그리드
        _buildDateGrid(),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // 이전 월 버튼
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: Icon(
              Icons.chevron_left,
              color: TossColors.textSub,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // 년월 표시
          Expanded(
            child: Text(
              '${_focusedMonth.year}년 ${_focusedMonth.month.toString().padLeft(2, '0')}월',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),
          ),
          // 다음 월 버튼
          IconButton(
            onPressed: _goToNextMonth,
            icon: Icon(
              Icons.chevron_right,
              color: TossColors.textSub,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          // 주간 버튼 (비활성화 표시)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: TossColors.divider),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '주간',
              style: TextStyle(
                fontSize: 12,
                color: TossColors.textSub,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 오늘 버튼
          GestureDetector(
            onTap: _goToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: TossColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '오늘',
                style: TextStyle(
                  fontSize: 12,
                  color: TossColors.textSub,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: weekdays.asMap().entries.map((entry) {
        final index = entry.key;
        final weekday = entry.value;
        Color textColor;
        if (index == 0) {
          textColor = const Color(0xFFE53935); // 일요일 빨간색
        } else if (index == 6) {
          textColor = TossColors.primary; // 토요일 파란색
        } else {
          textColor = TossColors.textSub;
        }
        return Expanded(
          child: Center(
            child: Text(
              weekday,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final isToday = (DateTime day) =>
        day.year == today.year && day.month == today.month && day.day == today.day;
    final isSelected = (DateTime day) =>
        day.year == widget.selectedDate.year &&
        day.month == widget.selectedDate.month &&
        day.day == widget.selectedDate.day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // 첫 주 빈 칸
    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(Expanded(child: Container()));
    }

    // 날짜 채우기
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final weekday = date.weekday % 7;

      Color textColor;
      if (weekday == 0) {
        textColor = const Color(0xFFE53935); // 일요일
      } else if (weekday == 6) {
        textColor = TossColors.primary; // 토요일
      } else {
        textColor = TossColors.textMain;
      }

      currentRow.add(
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: _getDateDecoration(isToday(date), isSelected(date)),
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday(date) || isSelected(date)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _getDateTextColor(isToday(date), isSelected(date), textColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // 토요일이면 새 줄
      if (weekday == 6 || day == daysInMonth) {
        // 마지막 주 빈 칸 채우기
        while (currentRow.length < 7) {
          currentRow.add(Expanded(child: Container()));
        }
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }

    return Column(children: rows);
  }
}
