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
import 'package:uncany/src/features/classroom/domain/models/classroom.dart';
import 'package:uncany/src/core/providers/supabase_provider.dart';

import 'providers/reservation_state_provider.dart';
import 'home_screen.dart' show todayReservationsProvider;

/// 예약 화면 (v2.0 - Riverpod 2.0 리팩토링)
///
/// ♻️ 개선 사항:
/// - StatefulWidget → ConsumerWidget 전환
/// - setState → AsyncValue 상태 관리
/// - ReservationRepository Provider 활용
/// - 코드 생성 기반 Notifier 사용
class ReservationScreenV2 extends ConsumerWidget {
  final String classroomId;
  final Classroom? classroom;

  const ReservationScreenV2({
    super.key,
    required this.classroomId,
    this.classroom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(
      reservationScreenNotifierProvider(classroomId: classroomId),
    );
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: Text(classroom?.name ?? '예약하기'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: reservationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error.toString()),
        data: (state) => _ReservationContent(
          classroomId: classroomId,
          classroom: classroom,
          state: state,
          currentUserId: currentUserId,
        ),
      ),
    );
  }
}

/// 예약 화면 메인 콘텐츠
class _ReservationContent extends ConsumerWidget {
  final String classroomId;
  final Classroom? classroom;
  final ReservationState state;
  final String? currentUserId;

  const _ReservationContent({
    required this.classroomId,
    required this.classroom,
    required this.state,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      reservationScreenNotifierProvider(classroomId: classroomId).notifier,
    );

    return ResponsiveContent(
      child: Column(
        children: [
          // 스크롤 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 교실 정보
                  if (classroom != null) _ClassroomInfoCard(classroom: classroom!),

                  const SizedBox(height: 16),

                  // 캘린더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TossCard(
                      padding: const EdgeInsets.all(16),
                      child: MonthCalendar(
                        selectedDate: state.selectedDate,
                        onDateSelected: notifier.selectDate,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 선택된 날짜 표시
                  _SelectedDateHeader(date: state.selectedDate),

                  const SizedBox(height: 16),

                  // 교시 그리드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TossCard(
                      padding: const EdgeInsets.all(16),
                      child: PeriodGrid(
                        selectedPeriods: state.selectedPeriods,
                        reservedPeriods: state.reservedPeriods,
                        onPeriodTap: notifier.togglePeriod,
                        currentUserId: currentUserId,
                        maxPeriods: 6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // 버튼 공간 확보
                ],
              ),
            ),
          ),

          // 하단 예약 버튼
          _ReservationBottomBar(
            classroomId: classroomId,
            selectedPeriods: state.selectedPeriods,
          ),
        ],
      ),
    );
  }
}

/// 교실 정보 카드
class _ClassroomInfoCard extends StatelessWidget {
  final Classroom classroom;

  const _ClassroomInfoCard({required this.classroom});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              _getRoomTypeIcon(classroom.roomType),
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
                  classroom.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: TossColors.textMain,
                  ),
                ),
                if (classroom.location != null)
                  Text(
                    classroom.location!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: TossColors.textSub,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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

/// 선택된 날짜 헤더
class _SelectedDateHeader extends StatelessWidget {
  final DateTime date;

  const _SelectedDateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            const Icon(
              Icons.event,
              color: TossColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${date.year}년 ${date.month}월 ${date.day}일',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TossColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              _getWeekdayText(date.weekday),
              style: const TextStyle(
                fontSize: 14,
                color: TossColors.primary,
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
}

/// 하단 예약 버튼 영역
class _ReservationBottomBar extends ConsumerStatefulWidget {
  final String classroomId;
  final Set<int> selectedPeriods;

  const _ReservationBottomBar({
    required this.classroomId,
    required this.selectedPeriods,
  });

  @override
  ConsumerState<_ReservationBottomBar> createState() =>
      _ReservationBottomBarState();
}

class _ReservationBottomBarState extends ConsumerState<_ReservationBottomBar> {
  bool _isSubmitting = false;

  Future<void> _handleReservation() async {
    if (widget.selectedPeriods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('교시를 선택해주세요'),
          backgroundColor: TossColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(
        reservationScreenNotifierProvider(classroomId: widget.classroomId)
            .notifier,
      );

      await notifier.createReservation();

      // 홈 화면 오늘의 예약 자동 새로고침
      ref.invalidate(todayReservationsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getPeriodsText(widget.selectedPeriods)} 예약이 완료되었습니다',
            ),
            backgroundColor: TossColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: TossColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getPeriodsText(Set<int> periods) {
    if (periods.isEmpty) return '';
    final sorted = periods.toList()..sort();

    // 연속된 교시인지 확인
    bool isContinuous = true;
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i + 1] - sorted[i] != 1) {
        isContinuous = false;
        break;
      }
    }

    if (sorted.length == 1) {
      return '${sorted.first}교시';
    } else if (isContinuous) {
      return '${sorted.first}~${sorted.last}교시';
    } else {
      return sorted.map((p) => '${p}교시').join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(
      reservationScreenNotifierProvider(classroomId: widget.classroomId)
          .notifier,
    );

    return Container(
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
            if (widget.selectedPeriods.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      '선택: ${_getPeriodsText(widget.selectedPeriods)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TossColors.textMain,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: notifier.clearSelection,
                      child: const Text(
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
              onPressed: widget.selectedPeriods.isNotEmpty && !_isSubmitting
                  ? _handleReservation
                  : null,
              isLoading: _isSubmitting,
              isDisabled: widget.selectedPeriods.isEmpty,
              child: Text(
                widget.selectedPeriods.isEmpty ? '교시를 선택해주세요' : '예약하기',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 에러 뷰
class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: TossColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '예약 정보를 불러올 수 없습니다',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: TossColors.textSub,
              ),
            ),
            const SizedBox(height: 24),
            TossButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
