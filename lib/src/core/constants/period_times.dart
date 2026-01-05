/// 교시 시간 설정
///
/// 기본 교시 시간표 (50분 수업 + 10분 쉬는시간)
class PeriodTimes {
  PeriodTimes._();

  /// 기본 교시 시간 설정
  static const List<PeriodTime> defaultPeriods = [
    PeriodTime(period: 1, startHour: 9, startMinute: 0, endHour: 9, endMinute: 50),
    PeriodTime(period: 2, startHour: 10, startMinute: 0, endHour: 10, endMinute: 50),
    PeriodTime(period: 3, startHour: 11, startMinute: 0, endHour: 11, endMinute: 50),
    PeriodTime(period: 4, startHour: 12, startMinute: 0, endHour: 12, endMinute: 50),
    PeriodTime(period: 5, startHour: 14, startMinute: 0, endHour: 14, endMinute: 50), // 점심 후
    PeriodTime(period: 6, startHour: 15, startMinute: 0, endHour: 15, endMinute: 50),
    PeriodTime(period: 7, startHour: 16, startMinute: 0, endHour: 16, endMinute: 50),
    PeriodTime(period: 8, startHour: 17, startMinute: 0, endHour: 17, endMinute: 50),
    PeriodTime(period: 9, startHour: 18, startMinute: 0, endHour: 18, endMinute: 50),
    PeriodTime(period: 10, startHour: 19, startMinute: 0, endHour: 19, endMinute: 50),
  ];

  /// 교시 번호로 시간 조회
  static PeriodTime? getPeriod(int periodNumber) {
    if (periodNumber < 1 || periodNumber > defaultPeriods.length) {
      return null;
    }
    return defaultPeriods[periodNumber - 1];
  }

  /// 교시 라벨 (1교시, 2교시 등)
  static String getLabel(int periodNumber) => '$periodNumber교시';
}

/// 개별 교시 시간 정보
class PeriodTime {
  final int period;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const PeriodTime({
    required this.period,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  /// 시작 시간 문자열 (09:00)
  String get startTimeString =>
    '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  /// 종료 시간 문자열 (09:50)
  String get endTimeString =>
    '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  /// 시간 범위 문자열 (09:00 ~ 09:50)
  String get timeRangeString => '$startTimeString ~ $endTimeString';

  /// 라벨 (1교시)
  String get label => '$period교시';

  /// DateTime으로 변환 (특정 날짜 기준)
  DateTime toStartDateTime(DateTime date) => DateTime(
    date.year, date.month, date.day, startHour, startMinute,
  );

  DateTime toEndDateTime(DateTime date) => DateTime(
    date.year, date.month, date.day, endHour, endMinute,
  );

  /// JSON 변환
  Map<String, dynamic> toJson() => {
    'period': period,
    'start_hour': startHour,
    'start_minute': startMinute,
    'end_hour': endHour,
    'end_minute': endMinute,
  };

  factory PeriodTime.fromJson(Map<String, dynamic> json) => PeriodTime(
    period: json['period'] as int,
    startHour: json['start_hour'] as int,
    startMinute: json['start_minute'] as int,
    endHour: json['end_hour'] as int,
    endMinute: json['end_minute'] as int,
  );
}

/// 교실 유형
enum RoomType {
  computer('computer', '컴퓨터실'),
  music('music', '음악실'),
  science('science', '과학실'),
  art('art', '미술실'),
  library('library', '도서실'),
  gym('gym', '체육관'),
  auditorium('auditorium', '강당'),
  special('special', '특별실'),
  other('other', '기타');

  final String code;
  final String label;

  const RoomType(this.code, this.label);

  static RoomType fromCode(String code) {
    return RoomType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => RoomType.other,
    );
  }
}
