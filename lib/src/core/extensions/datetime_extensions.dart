import '../utils/date_time_utils.dart';

/// DateTime 확장 메서드
extension DateTimeExtensions on DateTime {
  /// 오늘인지 확인
  bool get isToday => DateTimeUtils.isToday(this);

  /// 과거인지 확인
  bool get isPast => isBefore(DateTime.now());

  /// 미래인지 확인
  bool get isFuture => isAfter(DateTime.now());

  /// 어제인지 확인
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateTimeUtils.isSameDay(this, yesterday);
  }

  /// 내일인지 확인
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTimeUtils.isSameDay(this, tomorrow);
  }

  /// 같은 날짜인지 확인
  bool isSameDayAs(DateTime other) {
    return DateTimeUtils.isSameDay(this, other);
  }

  /// 같은 주인지 확인
  bool isSameWeekAs(DateTime other) {
    final thisStart = DateTimeUtils.startOfWeek(this);
    final otherStart = DateTimeUtils.startOfWeek(other);
    return thisStart.isSameDayAs(otherStart);
  }

  /// 같은 월인지 확인
  bool isSameMonthAs(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// 같은 년도인지 확인
  bool isSameYearAs(DateTime other) {
    return year == other.year;
  }

  /// 날짜의 시작 시간 (00:00:00)
  DateTime get startOfDay => DateTimeUtils.startOfDay(this);

  /// 날짜의 종료 시간 (23:59:59)
  DateTime get endOfDay => DateTimeUtils.endOfDay(this);

  /// 주의 시작일 (월요일)
  DateTime get startOfWeek => DateTimeUtils.startOfWeek(this);

  /// 주의 종료일 (일요일)
  DateTime get endOfWeek => DateTimeUtils.endOfWeek(this);

  /// 월의 시작일
  DateTime get startOfMonth => DateTimeUtils.startOfMonth(this);

  /// 월의 종료일
  DateTime get endOfMonth => DateTimeUtils.endOfMonth(this);

  /// 다음 날
  DateTime get nextDay => add(const Duration(days: 1));

  /// 이전 날
  DateTime get previousDay => subtract(const Duration(days: 1));

  /// 다음 주
  DateTime get nextWeek => add(const Duration(days: 7));

  /// 이전 주
  DateTime get previousWeek => subtract(const Duration(days: 7));

  /// 다음 월
  DateTime get nextMonth => DateTime(year, month + 1, day);

  /// 이전 월
  DateTime get previousMonth => DateTime(year, month - 1, day);

  /// 한국어 날짜 포맷
  String get toKoreanDate => DateTimeUtils.formatKoreanDate(this);

  /// 한국어 날짜+시간 포맷
  String get toKoreanDateTime => DateTimeUtils.formatKoreanDateTime(this);

  /// 시간 포맷 (HH:mm)
  String get toTimeString => DateTimeUtils.formatTime(this);

  /// 상대적 시간 표시
  String get toRelativeTime => DateTimeUtils.formatRelativeTime(this);

  /// 요일 번호 (월요일 = 1, 일요일 = 7)
  int get weekdayNumber => weekday;

  /// 요일 이름 (한글)
  String get weekdayName {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  /// 요일 이름 (한글 전체)
  String get weekdayFullName {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }

  /// 월 이름 (한글)
  String get monthName => '$month월';

  /// 주말인지 확인
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// 평일인지 확인
  bool get isWeekday => !isWeekend;

  /// 오전인지 확인
  bool get isAM => hour < 12;

  /// 오후인지 확인
  bool get isPM => hour >= 12;

  /// 자정인지 확인
  bool get isMidnight => hour == 0 && minute == 0 && second == 0;

  /// 정오인지 확인
  bool get isNoon => hour == 12 && minute == 0 && second == 0;

  /// 두 날짜 사이의 일수
  int daysBetween(DateTime other) {
    final from = startOfDay;
    final to = other.startOfDay;
    return (to.difference(from).inHours / 24).round();
  }

  /// 두 날짜 사이의 주수
  int weeksBetween(DateTime other) {
    return (daysBetween(other) / 7).round();
  }

  /// 두 날짜 사이의 월수 (근사값)
  int monthsBetween(DateTime other) {
    return (other.year - year) * 12 + (other.month - month);
  }

  /// 두 날짜 사이의 년수
  int yearsBetween(DateTime other) {
    return other.year - year;
  }

  /// 특정 시간으로 설정
  DateTime setTime(int hour, int minute, [int second = 0, int millisecond = 0]) {
    return DateTime(year, month, day, hour, minute, second, millisecond);
  }

  /// 특정 날짜로 설정 (시간 유지)
  DateTime setDate(int year, int month, int day) {
    return DateTime(
      year,
      month,
      day,
      this.hour,
      minute,
      second,
      millisecond,
    );
  }

  /// 시간만 복사 (날짜는 현재)
  DateTime copyTimeToToday() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
      millisecond,
    );
  }

  /// 날짜만 복사 (시간은 0시)
  DateTime get dateOnly => DateTime(year, month, day);

  /// 시간이 특정 범위 내에 있는지 확인
  bool isTimeBetween(DateTime start, DateTime end) {
    final time = hour * 60 + minute;
    final startTime = start.hour * 60 + start.minute;
    final endTime = end.hour * 60 + end.minute;

    return time >= startTime && time <= endTime;
  }

  /// 날짜가 특정 범위 내에 있는지 확인
  bool isDateBetween(DateTime start, DateTime end) {
    final date = startOfDay;
    final startDate = start.startOfDay;
    final endDate = end.endOfDay;

    return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
        (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
  }

  /// 나이 계산
  int get age {
    final today = DateTime.now();
    int age = today.year - year;

    if (today.month < month || (today.month == month && today.day < day)) {
      age--;
    }

    return age;
  }

  /// 월의 마지막 날짜
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// 해당 월의 첫 번째 날의 요일
  int get firstDayOfMonthWeekday {
    return DateTime(year, month, 1).weekday;
  }

  /// 윤년인지 확인
  bool get isLeapYear {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// 분기 (1-4)
  int get quarter {
    return ((month - 1) ~/ 3) + 1;
  }

  /// 해당 년도의 몇 번째 날인지
  int get dayOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    return difference(firstDayOfYear).inDays + 1;
  }

  /// 해당 년도의 몇 번째 주인지 (ISO 8601)
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final firstMonday = firstDayOfYear.add(
      Duration(days: (8 - firstDayOfYear.weekday) % 7),
    );

    if (isBefore(firstMonday)) {
      return DateTime(year - 1, 12, 31).weekOfYear;
    }

    return ((difference(firstMonday).inDays) / 7).floor() + 1;
  }

  /// Unix 타임스탬프 (초)
  int get unixTimestamp => millisecondsSinceEpoch ~/ 1000;

  /// ISO 8601 문자열로 변환 (UTC)
  String get toIso8601StringUTC => toUtc().toIso8601String();

  /// 포맷된 문자열 (사용자 정의)
  String format(String pattern) {
    // 간단한 패턴 매칭
    return pattern
        .replaceAll('yyyy', year.toString().padLeft(4, '0'))
        .replaceAll('MM', month.toString().padLeft(2, '0'))
        .replaceAll('dd', day.toString().padLeft(2, '0'))
        .replaceAll('HH', hour.toString().padLeft(2, '0'))
        .replaceAll('mm', minute.toString().padLeft(2, '0'))
        .replaceAll('ss', second.toString().padLeft(2, '0'));
  }

  /// 가장 가까운 시간으로 반올림 (분 단위)
  DateTime roundToNearestMinute(int minutes) {
    final remainder = minute % minutes;
    if (remainder < minutes / 2) {
      return subtract(Duration(minutes: remainder));
    } else {
      return add(Duration(minutes: minutes - remainder));
    }
  }

  /// 가장 가까운 시간으로 반올림 (시간 단위)
  DateTime roundToNearestHour() {
    if (minute < 30) {
      return DateTime(year, month, day, hour);
    } else {
      return DateTime(year, month, day, hour + 1);
    }
  }
}

/// nullable DateTime 확장 메서드
extension NullableDateTimeExtensions on DateTime? {
  /// null이면 기본값 반환
  DateTime orDefault(DateTime defaultValue) => this ?? defaultValue;

  /// null이면 현재 시간 반환
  DateTime get orNow => this ?? DateTime.now();

  /// null-safe 포맷
  String formatOrDefault(String Function(DateTime) formatter, String defaultValue) {
    return this != null ? formatter(this!) : defaultValue;
  }

  /// null이면 '-' 반환, 아니면 한국어 날짜로 포맷
  String get toKoreanDateOrDash {
    return this?.toKoreanDate ?? '-';
  }

  /// null이면 '-' 반환, 아니면 시간으로 포맷
  String get toTimeStringOrDash {
    return this?.toTimeString ?? '-';
  }
}
