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
import 'package:uncany/src/features/reservation/data/repositories/reservation_repository.dart';
import 'package:uncany/src/features/reservation/domain/models/reservation.dart';
import 'package:uncany/src/features/classroom/domain/models/classroom.dart';
import 'package:uncany/src/core/providers/supabase_provider.dart';

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
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final repository = ReservationRepository(supabase);

      final reservedMap = await repository.getReservedPeriodsMap(
        widget.classroomId,
        _selectedDate,
      );

      if (mounted) {
        setState(() {
          _reservedPeriods = reservedMap;
          _isLoading = false;

          // 날짜 변경 시 선택 초기화
          _selectedPeriods.clear();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('교시를 선택해주세요'),
          backgroundColor: TossColors.error,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getFormattedDate(_selectedDate)} ${_getPeriodsText(_selectedPeriods)} 예약이 완료되었습니다',
            ),
            backgroundColor: TossColors.primary,
          ),
        );

        // 예약 목록 새로고침
        _loadReservations();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? '예약에 실패했습니다'),
            backgroundColor: TossColors.error,
          ),
        );
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
    return '${sorted.first}~${sorted.last}교시';
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

          // 하단 예약 버튼
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
              child: Column(
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
