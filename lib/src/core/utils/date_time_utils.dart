import 'package:intl/intl.dart';

/// 날짜 및 시간 포맷팅 유틸리티
class DateTimeUtils {
  DateTimeUtils._();

  /// 한국어 날짜 포맷터
  static final koreanDateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');

  /// 한국어 날짜+시간 포맷터
  static final koreanDateTimeFormat =
      DateFormat('yyyy년 M월 d일 (E) HH:mm', 'ko_KR');

  /// 시간만 포맷터 (24시간)
  static final timeFormat = DateFormat('HH:mm');

  /// 시간만 포맷터 (AM/PM)
  static final time12Format = DateFormat('a hh:mm', 'ko_KR');

  /// 짧은 날짜 포맷 (월/일)
  static final shortDateFormat = DateFormat('M월 d일 (E)', 'ko_KR');

  /// 날짜를 한국어로 포맷
  static String formatKoreanDate(DateTime date) {
    return koreanDateFormat.format(date);
  }

  /// 날짜+시간을 한국어로 포맷
  static String formatKoreanDateTime(DateTime dateTime) {
    return koreanDateTimeFormat.format(dateTime);
  }

  /// 시간을 포맷 (HH:mm)
  static String formatTime(DateTime time) {
    return timeFormat.format(time);
  }

  /// 두 시간 사이의 기간을 포맷
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// 분 단위를 시간 문자열로 변환
  /// 예: 90분 -> "1시간 30분", 60분 -> "1시간", 45분 -> "45분"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    }

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) {
      return '$hours시간';
    }

    return '$hours시간 $mins분';
  }

  /// 오늘인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 과거인지 확인
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// 미래인지 확인
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// 같은 날짜인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 상대적 시간 표시 (예: "3시간 전", "2일 후")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // 과거
      final absDiff = difference.abs();

      if (absDiff.inSeconds < 60) {
        return '방금 전';
      } else if (absDiff.inMinutes < 60) {
        return '${absDiff.inMinutes}분 전';
      } else if (absDiff.inHours < 24) {
        return '${absDiff.inHours}시간 전';
      } else if (absDiff.inDays < 7) {
        return '${absDiff.inDays}일 전';
      } else if (absDiff.inDays < 30) {
        return '${absDiff.inDays ~/ 7}주 전';
      } else if (absDiff.inDays < 365) {
        return '${absDiff.inDays ~/ 30}개월 전';
      } else {
        return '${absDiff.inDays ~/ 365}년 전';
      }
    } else {
      // 미래
      if (difference.inSeconds < 60) {
        return '곧';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}분 후';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}시간 후';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 후';
      } else if (difference.inDays < 30) {
        return '${difference.inDays ~/ 7}주 후';
      } else if (difference.inDays < 365) {
        return '${difference.inDays ~/ 30}개월 후';
      } else {
        return '${difference.inDays ~/ 365}년 후';
      }
    }
  }

  /// 날짜의 시작 시간 (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 날짜의 종료 시간 (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// 주의 시작일 (월요일)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  /// 주의 종료일 (일요일)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }

  /// 월의 시작일
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 월의 종료일
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }
}
