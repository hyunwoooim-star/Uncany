import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/toss_skeleton.dart';
import 'package:uncany/src/core/constants/period_times.dart';
import 'package:uncany/src/core/providers/supabase_provider.dart';
import 'package:uncany/src/features/classroom/domain/models/classroom.dart';
import 'package:uncany/src/features/classroom/data/repositories/classroom_repository.dart';
import 'package:uncany/src/features/reservation/domain/models/reservation.dart';
import 'package:uncany/src/features/reservation/data/repositories/reservation_repository.dart';

/// 종합 시간표 대시보드 화면
///
/// 모든 교실의 오늘 예약 현황을 한눈에 볼 수 있는 대시보드
/// - 가로: 교시 (1~6교시)
/// - 세로: 교실 목록
class TimetableDashboardScreen extends ConsumerStatefulWidget {
  const TimetableDashboardScreen({super.key});

  @override
  ConsumerState<TimetableDashboardScreen> createState() =>
      _TimetableDashboardScreenState();
}

class _TimetableDashboardScreenState
    extends ConsumerState<TimetableDashboardScreen> {
  late DateTime _selectedDate;
  List<Classroom> _classrooms = [];
  Map<String, Map<int, Reservation>> _reservationMap = {};
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  // 표시할 교시 범위 (기본 1~6교시)
  final int _startPeriod = 1;
  final int _endPeriod = 6;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _loadData();
  }

  /// 데이터 로드 (교실 목록 + 예약 현황)
  ///
  /// N+1 쿼리 개선: 교실 목록과 예약 현황을 병렬로 조회
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final classroomRepo = ClassroomRepository(supabase);
      final reservationRepo = ReservationRepository(supabase);

      // 교실 목록과 예약 현황을 병렬로 조회 (N+1 → 2개 쿼리)
      final results = await Future.wait([
        classroomRepo.getClassrooms(activeOnly: true),
        reservationRepo.getAllReservationsForDate(_selectedDate),
      ]);

      final classrooms = results[0] as List<Classroom>;
      final reservationMap = results[1] as Map<String, Map<int, Reservation>>;

      if (mounted) {
        setState(() {
          _classrooms = classrooms;
          _reservationMap = reservationMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// 날짜 변경
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  /// 오늘로 이동
  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('종합 시간표'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 날짜 선택 헤더
          _buildDateHeader(),

          // 시간표 그리드
          Expanded(
            child: _isLoading
                ? _buildSkeletonLoading()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildTimetableGrid(),
          ),
        ],
      ),
    );
  }

  /// 날짜 선택 헤더
  Widget _buildDateHeader() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: TossColors.surface,
      child: Row(
        children: [
          // 이전 날짜
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
            color: TossColors.textSub,
          ),

          // 날짜 표시
          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? TossColors.primary.withOpacity(0.1)
                      : TossColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? TossColors.primary
                            : TossColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getWeekdayText(_selectedDate.weekday),
                      style: TextStyle(
                        fontSize: 13,
                        color: isToday
                            ? TossColors.primary
                            : TossColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 다음 날짜
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
            color: TossColors.textSub,
          ),

          // 오늘 버튼
          if (!isToday)
            TextButton(
              onPressed: _goToToday,
              child: Text(
                '오늘',
                style: TextStyle(
                  color: TossColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 날짜 선택 다이얼로그
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  /// 시간표 그리드
  Widget _buildTimetableGrid() {
    if (_classrooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 64,
              color: TossColors.textSub.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 교실이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: TossColors.textSub,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TossCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 헤더 (교시)
            _buildPeriodHeader(),
            const Divider(height: 1),
            // 교실별 행
            ..._classrooms.asMap().entries.map((entry) {
              final index = entry.key;
              final classroom = entry.value;
              return Column(
                children: [
                  _buildClassroomRow(classroom),
                  if (index < _classrooms.length - 1)
                    const Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 교시 헤더
  Widget _buildPeriodHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: TossColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // 교실명 열
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '교실',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TossColors.textSub,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // 교시 열들
          ...List.generate(_endPeriod - _startPeriod + 1, (index) {
            final period = _startPeriod + index;
            final periodTime = PeriodTimes.getPeriod(period);
            return Expanded(
              child: Column(
                children: [
                  Text(
                    '$period교시',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TossColors.textMain,
                    ),
                  ),
                  if (periodTime != null)
                    Text(
                      periodTime.startTimeString,
                      style: TextStyle(
                        fontSize: 10,
                        color: TossColors.textSub,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 교실별 행
  Widget _buildClassroomRow(Classroom classroom) {
    final reservations = _reservationMap[classroom.id] ?? {};

    return InkWell(
      onTap: () async {
        await context.push(
          '/reservations/${classroom.id}',
          extra: classroom,
        );
        // 예약 화면에서 돌아오면 데이터 새로고침
        if (mounted) _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 교실명
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TossColors.textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    classroom.roomTypeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: TossColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            // 교시별 예약 상태
            ...List.generate(_endPeriod - _startPeriod + 1, (index) {
              final period = _startPeriod + index;
              final reservation = reservations[period];
              return Expanded(
                child: _buildPeriodCell(period, reservation),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 교시 셀
  Widget _buildPeriodCell(int period, Reservation? reservation) {
    final isReserved = reservation != null;
    final isMyReservation = reservation != null &&
        _currentUserId != null &&
        reservation.teacherId == _currentUserId;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isReserved) {
      if (isMyReservation) {
        bgColor = TossColors.primary.withOpacity(0.2);
        borderColor = TossColors.primary;
        textColor = TossColors.primary;
      } else {
        bgColor = Colors.grey.shade200;
        borderColor = Colors.grey.shade400;
        textColor = Colors.grey.shade700;
      }
    } else {
      bgColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade600;
    }

    // 전체 정보 표시 (예: "3-2 임현우")
    String? gradeClassLabel;
    String? teacherLabel;
    if (reservation?.teacherGrade != null && reservation?.teacherClassNum != null) {
      gradeClassLabel = '${reservation!.teacherGrade}-${reservation.teacherClassNum}';
    } else if (reservation?.teacherGrade != null) {
      gradeClassLabel = '${reservation!.teacherGrade}학년';
    }
    if (reservation?.teacherName != null) {
      teacherLabel = reservation!.teacherName!;
    }

    final cell = Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: isReserved
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (gradeClassLabel != null)
                    Text(
                      gradeClassLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  if (teacherLabel != null)
                    Text(
                      teacherLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
            : Icon(
                Icons.check,
                size: 16,
                color: textColor,
              ),
      ),
    );

    // 예약된 셀은 탭하면 상세 정보 팝업
    if (isReserved) {
      return GestureDetector(
        onTap: () => _showReservationDetail(reservation),
        child: cell,
      );
    }

    return cell;
  }

  /// 예약 상세 정보 팝업
  void _showReservationDetail(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TossColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TossColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event_note,
                    color: TossColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예약 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TossColors.textMain,
                        ),
                      ),
                      Text(
                        reservation.periodsDisplay ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: TossColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 예약자 정보
            _buildDetailRow(
              Icons.person,
              '예약자',
              reservation.teacherDisplayName,
            ),
            const SizedBox(height: 12),
            // 수업 내용
            if (reservation.description?.isNotEmpty == true) ...[
              _buildDetailRow(
                Icons.description,
                '수업 내용',
                reservation.description!,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 상세 정보 행
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: TossColors.textSub),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: TossColors.textSub,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: TossColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 스켈레톤 로딩
  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TossCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 헤더 스켈레톤
            Row(
              children: [
                const TossSkeleton(width: 80, height: 20),
                ...List.generate(6, (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TossSkeleton(width: double.infinity, height: 30),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),
            // 행 스켈레톤
            ...List.generate(5, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const TossSkeleton(width: 80, height: 40),
                  ...List.generate(6, (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TossSkeleton(width: double.infinity, height: 40),
                    ),
                  )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TossColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '오류가 발생했습니다',
            style: TextStyle(
              fontSize: 16,
              color: TossColors.textSub,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getWeekdayText(int weekday) {
    const weekdays = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday];
  }
}

/// 범례 위젯
class TimetableLegend extends StatelessWidget {
  const TimetableLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            color: Colors.green.withOpacity(0.1),
            borderColor: Colors.green.shade300,
            label: '예약 가능',
          ),
          _buildLegendItem(
            color: TossColors.primary.withOpacity(0.2),
            borderColor: TossColors.primary,
            label: '내 예약',
          ),
          _buildLegendItem(
            color: Colors.grey.shade200,
            borderColor: Colors.grey.shade400,
            label: '예약됨',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: TossColors.textSub,
          ),
        ),
      ],
    );
  }
}
