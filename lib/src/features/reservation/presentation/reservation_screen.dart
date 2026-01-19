import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/month_calendar.dart';
import 'package:uncany/src/shared/widgets/period_grid.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';
import 'package:uncany/src/shared/widgets/error_bottom_sheet.dart';
import 'package:uncany/src/features/reservation/data/repositories/reservation_repository.dart';
import 'package:uncany/src/features/reservation/domain/models/reservation.dart';
import 'package:uncany/src/features/classroom/domain/models/classroom.dart';
import 'package:uncany/src/core/providers/supabase_provider.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';
import 'home_screen.dart' show todayReservationsProvider, todayAllReservationsProvider;
import 'my_reservations_screen.dart' show myReservationsProvider;

/// 예약 화면 (v0.2)
///
/// 교시 기반 예약 시스템
/// - 상단: 월간 캘린더
/// - 하단: 교시 그리드 (1~6교시)
/// - 예약하기 버튼
class ReservationScreen extends ConsumerStatefulWidget {
  final String classroomId;
  final Classroom? classroom;

  const ReservationScreen({
    super.key,
    required this.classroomId,
    this.classroom,
  });

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  late DateTime _selectedDate;
  final Set<int> _selectedPeriods = {};
  Map<int, Reservation> _reservedPeriods = {};

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  Classroom? _classroom;

  /// 선택된 날짜가 과거인지 확인
  bool get _isPastDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return selected.isBefore(today);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _classroom = widget.classroom;

    // 교실 정보가 없으면 로드
    if (_classroom == null) {
      _loadClassroom();
    }

    // 오늘 날짜의 예약 정보 로드
    _loadReservations();
  }

  /// 교실 정보 로드
  Future<void> _loadClassroom() async {
    try {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase
          .from('classrooms')
          .select()
          .eq('id', widget.classroomId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _classroom = Classroom.fromJson(response);
        });
      }
    } catch (e) {
      // 에러 무시 (기본 정보로 표시)
    }
  }

  /// 선택된 날짜의 예약 정보 로드
  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // 날짜 변경 시 이전 데이터 즉시 초기화
      _reservedPeriods = {};
      _selectedPeriods.clear();
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final repository = ReservationRepository(supabase);

      // 디버그: 선택된 날짜 확인
      debugPrint('📅 예약 조회: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}');

      final reservedMap = await repository.getReservedPeriodsMap(
        widget.classroomId,
        _selectedDate,
      );

      // 디버그: 조회된 예약 수 확인
      debugPrint('📋 조회된 교시 수: ${reservedMap.length}');

      if (mounted) {
        setState(() {
          _reservedPeriods = reservedMap;
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

  /// 날짜 선택
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadReservations();
  }

  /// 교시 선택/해제
  void _onPeriodTap(int period) {
    // 과거 날짜는 조회만 가능
    if (_isPastDate) return;

    setState(() {
      if (_selectedPeriods.contains(period)) {
        _selectedPeriods.remove(period);
      } else {
        _selectedPeriods.add(period);
      }
    });
  }

  /// 예약 생성
  Future<void> _createReservation() async {
    if (_selectedPeriods.isEmpty) {
      TossSnackBar.error(context, message: '교시를 선택해주세요');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final repository = ReservationRepository(supabase);

      await repository.createReservation(
        classroomId: widget.classroomId,
        date: _selectedDate,
        periods: _selectedPeriods.toList(),
      );

      if (mounted) {
        TossSnackBar.success(context, message: '${_getFormattedDate(_selectedDate)} ${_getPeriodsText(_selectedPeriods)} 예약 완료');

        // 모든 예약 관련 Provider 무효화 (동기화)
        ref.invalidate(todayReservationsProvider);
        ref.invalidate(todayAllReservationsProvider);
        ref.invalidate(myReservationsProvider);

        // 예약 목록 새로고침
        _loadReservations();
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        final errorMessage = ErrorMessages.fromPostgrestException(e);
        setState(() {
          _errorMessage = errorMessage;
        });

        // 예약 충돌 에러인 경우 바텀시트로 표시
        if (ErrorMessages.isReservationConflictError(e)) {
          ErrorBottomSheet.showReservationConflict(
            context,
            message: errorMessage,
            onRetry: () {
              // 예약 정보 새로고침 후 선택 초기화
              _loadReservations();
            },
          );
        } else {
          ErrorBottomSheet.showError(
            context,
            title: '예약 실패',
            message: errorMessage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _errorMessage = errorMessage;
        });

        // 네트워크 에러 확인
        if (errorMessage.contains('네트워크') || errorMessage.contains('연결')) {
          ErrorBottomSheet.showNetworkError(
            context,
            onRetry: _createReservation,
          );
        } else if (ErrorMessages.isReservationConflictError(e)) {
          // 예약 충돌 에러인 경우 친절한 바텀시트로 표시
          ErrorBottomSheet.showReservationConflict(
            context,
            message: errorMessage,
            onRetry: _loadReservations,
          );
        } else {
          ErrorBottomSheet.showError(
            context,
            title: '예약 실패',
            message: errorMessage,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getFormattedDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  String _getPeriodsText(Set<int> periods) {
    if (periods.isEmpty) return '';
    final sorted = periods.toList()..sort();
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: Text(_classroom?.name ?? '예약하기'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveContent(
        child: Column(
          children: [
            // 스크롤 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                children: [
                  // 교실 정보
                  if (_classroom != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: TossColors.surface,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: TossColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getRoomTypeIcon(_classroom!.roomType),
                              color: TossColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _classroom!.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: TossColors.textMain,
                                  ),
                                ),
                                if (_classroom!.location != null)
                                  Text(
                                    _classroom!.location!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: TossColors.textSub,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 캘린더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TossCard(
                      padding: const EdgeInsets.all(16),
                      child: MonthCalendar(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 선택된 날짜 표시
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TossColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: TossColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: TossColors.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _getWeekdayText(_selectedDate.weekday),
                            style: TextStyle(
                              fontSize: 14,
                              color: TossColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 교시 그리드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TossCard(
                      padding: const EdgeInsets.all(16),
                      child: _isLoading
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : PeriodGrid(
                              selectedPeriods: _selectedPeriods,
                              reservedPeriods: _reservedPeriods,
                              onPeriodTap: _onPeriodTap,
                              currentUserId: currentUserId,
                              maxPeriods: 6,
                            ),
                    ),
                  ),

                  // 에러 메시지
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TossColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: TossColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                    color: TossColors.error, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // 버튼 공간 확보
                ],
              ),
            ),
          ),

          // 하단 예약 버튼 또는 과거 날짜 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: _isPastDate
                  // 과거 날짜: 조회 전용 안내
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '지난 날짜입니다',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '과거 예약 내역을 확인할 수 있습니다',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  // 오늘/미래 날짜: 예약 버튼
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 선택 요약
                        if (_selectedPeriods.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Text(
                                  '선택: ${_getPeriodsText(_selectedPeriods)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: TossColors.textMain,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedPeriods.clear();
                                    });
                                  },
                                  child: Text(
                                    '초기화',
                                    style: TextStyle(
                                      color: TossColors.textSub,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 예약 버튼
                        TossButton(
                          onPressed: _selectedPeriods.isNotEmpty && !_isSubmitting
                              ? _createReservation
                              : null,
                          isLoading: _isSubmitting,
                          isDisabled: _selectedPeriods.isEmpty,
                          child: Text(_selectedPeriods.isEmpty
                              ? '교시를 선택해주세요'
                              : '예약하기'),
                        ),
                      ],
                    ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayText(int weekday) {
    const weekdays = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday];
  }

  IconData _getRoomTypeIcon(String roomType) {
    switch (roomType) {
      case 'computer':
        return Icons.computer;
      case 'music':
        return Icons.music_note;
      case 'science':
        return Icons.science;
      case 'art':
        return Icons.palette;
      case 'library':
        return Icons.menu_book;
      case 'gym':
        return Icons.sports_basketball;
      case 'auditorium':
        return Icons.theater_comedy;
      case 'special':
        return Icons.star;
      default:
        return Icons.room;
    }
  }
}
