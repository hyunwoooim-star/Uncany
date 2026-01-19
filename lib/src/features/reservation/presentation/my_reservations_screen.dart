import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/providers/reservation_repository_provider.dart';
import '../domain/models/reservation.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';
import 'home/home_screen.dart' show todayReservationsProvider, todayAllReservationsProvider;

/// 내 예약 Provider (classroom JOIN 포함)
final myReservationsProvider = FutureProvider.autoDispose<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getMyReservations();
});

/// 내 예약 내역 화면
///
/// 사용자의 모든 예약 조회 및 관리
class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() =>
      _MyReservationsScreenState();
}

enum _ReservationFilter {
  all('전체'),
  upcoming('예정'),
  completed('이전예약');

  final String label;
  const _ReservationFilter(this.label);
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Reservation> _getFilteredReservations(List<Reservation> allReservations) {
    final filter = _ReservationFilter.values[_tabController.index];

    switch (filter) {
      case _ReservationFilter.all:
        return allReservations;
      case _ReservationFilter.upcoming:
        return allReservations
            .where((r) => r.isUpcoming || r.isOngoing)
            .toList();
      case _ReservationFilter.completed:
        return allReservations.where((r) => r.isCompleted).toList();
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    // 취소 가능 여부 재확인
    if (!reservation.isCancellable) {
      if (mounted) {
        TossSnackBar.error(context, message: reservation.cancellationDisabledReason ?? '취소할 수 없습니다');
      }
      return;
    }

    // 남은 시간 표시
    final minutesLeft = reservation.minutesUntilCancellationDeadline;
    final timeWarning = minutesLeft < 30
        ? '\n\n⚠️ 취소 마감까지 $minutesLeft분 남았습니다.'
        : '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: Text('이 예약을 취소하시겠습니까?$timeWarning'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('취소하기'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(reservationRepositoryProvider);
        await repository.cancelReservation(reservation.id);

        if (mounted) {
          TossSnackBar.warning(context, message: '예약이 취소되었습니다');
          // 모든 예약 관련 Provider 무효화 (동기화)
          ref.invalidate(myReservationsProvider);
          ref.invalidate(todayReservationsProvider);
          ref.invalidate(todayAllReservationsProvider);
        }
      } catch (e) {
        if (mounted) {
          TossSnackBar.error(context, message: ErrorMessages.fromError(e));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(myReservationsProvider);

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('내 예약'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: TossColors.primary,
          unselectedLabelColor: TossColors.textSub,
          indicatorColor: TossColors.primary,
          tabs: _ReservationFilter.values
              .map((filter) => Tab(text: filter.label))
              .toList(),
        ),
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                ErrorMessages.fromError(error),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TossButton(
                onPressed: () => ref.invalidate(myReservationsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (allReservations) {
          final filteredReservations = _getFilteredReservations(allReservations);

          if (filteredReservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: TossColors.textSub.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _tabController.index == 0
                        ? '예약 내역이 없습니다'
                        : _tabController.index == 1
                            ? '예정된 예약이 없습니다'
                            : '완료된 예약이 없습니다',
                    style: TextStyle(
                      color: TossColors.textSub,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myReservationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReservations.length,
              itemBuilder: (context, index) {
                final reservation = filteredReservations[index];

                return _ReservationCard(
                  reservation: reservation,
                  onCancel: reservation.isCancellable
                      ? () => _cancelReservation(reservation)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;

  const _ReservationCard({
    required this.reservation,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final timeFormat = DateFormat('HH:mm');

    // 상태별 색상
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (reservation.isOngoing) {
      statusColor = Colors.green;
      statusText = '진행 중';
      statusIcon = Icons.play_circle_outline;
    } else if (reservation.isUpcoming) {
      statusColor = TossColors.primary;
      statusText = '예정';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.grey;
      statusText = '완료';
      statusIcon = Icons.check_circle_outline;
    }

    // 교실명 (JOIN 데이터 사용)
    final classroomName = reservation.classroomName ?? '알 수 없는 교실';

    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 교실명 + 상태
          Row(
            children: [
              Expanded(
                child: Text(
                  classroomName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TossColors.textMain,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 교실 위치 표시
          if (reservation.classroomLocation != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: TossColors.textSub),
                const SizedBox(width: 4),
                Text(
                  reservation.classroomLocation!,
                  style: TextStyle(fontSize: 13, color: TossColors.textSub),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // 날짜 및 교시/시간
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: TossColors.textSub,
              ),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(reservation.startTime),
                style: TextStyle(
                  fontSize: 14,
                  color: TossColors.textSub,
                ),
              ),
              const SizedBox(width: 16),
              // 교시 정보가 있으면 교시로 표시, 없으면 시간으로 표시
              if (reservation.periodsDisplay != null) ...[
                Icon(
                  Icons.grid_view,
                  size: 16,
                  color: TossColors.textSub,
                ),
                const SizedBox(width: 4),
                Text(
                  reservation.periodsDisplay!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TossColors.textMain,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: TossColors.textSub,
                ),
                const SizedBox(width: 4),
                Text(
                  '${timeFormat.format(reservation.startTime)} - ${timeFormat.format(reservation.endTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: TossColors.textSub,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${reservation.durationInMinutes}분)',
                  style: TextStyle(
                    fontSize: 12,
                    color: TossColors.textSub,
                  ),
                ),
              ],
            ],
          ),

          // 제목
          if (reservation.title != null) ...[
            const SizedBox(height: 12),
            Text(
              reservation.title!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: TossColors.textMain,
              ),
            ),
          ],

          // 설명
          if (reservation.description != null) ...[
            const SizedBox(height: 8),
            Text(
              reservation.description!,
              style: TextStyle(
                fontSize: 14,
                color: TossColors.textSub,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // 취소 버튼 또는 취소 불가 안내
          if (reservation.isUpcoming || reservation.isOngoing) ...[
            const SizedBox(height: 12),
            if (onCancel != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('예약 취소'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  ),
                ),
              )
            else if (reservation.cancellationDisabledReason != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservation.cancellationDisabledReason!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
