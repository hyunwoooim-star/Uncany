import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/providers/reservation_repository_provider.dart';
import '../domain/models/reservation.dart';
import '../../classroom/data/providers/classroom_repository_provider.dart';
import '../../classroom/domain/models/classroom.dart';
import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';
import '../../../shared/widgets/toss_card.dart';
import '../../../core/utils/error_messages.dart';

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
  completed('완료');

  final String label;
  const _ReservationFilter(this.label);
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Reservation> _allReservations = [];
  Map<String, Classroom> _classroomCache = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservationRepo = ref.read(reservationRepositoryProvider);
      final classroomRepo = ref.read(classroomRepositoryProvider);

      // 모든 예약 조회
      final reservations = await reservationRepo.getMyReservations();

      // 교실 정보 캐시
      final classroomIds =
          reservations.map((r) => r.classroomId).toSet();
      final classroomCache = <String, Classroom>{};

      for (final id in classroomIds) {
        final classroom = await classroomRepo.getClassroom(id);
        if (classroom != null) {
          classroomCache[id] = classroom;
        }
      }

      setState(() {
        _allReservations = reservations;
        _classroomCache = classroomCache;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  List<Reservation> _getFilteredReservations() {
    final filter = _ReservationFilter.values[_tabController.index];

    switch (filter) {
      case _ReservationFilter.all:
        return _allReservations;
      case _ReservationFilter.upcoming:
        return _allReservations
            .where((r) => r.isUpcoming || r.isOngoing)
            .toList();
      case _ReservationFilter.completed:
        return _allReservations.where((r) => r.isCompleted).toList();
    }
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('이 예약을 취소하시겠습니까?'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('예약이 취소되었습니다'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadReservations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMessages.fromError(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReservations = _getFilteredReservations();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      TossButton(
                        text: '다시 시도',
                        onPressed: _loadReservations,
                      ),
                    ],
                  ),
                )
              : filteredReservations.isEmpty
                  ? Center(
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
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReservations,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReservations.length,
                        itemBuilder: (context, index) {
                          final reservation = filteredReservations[index];
                          final classroom =
                              _classroomCache[reservation.classroomId];

                          return _ReservationCard(
                            reservation: reservation,
                            classroom: classroom,
                            onCancel: reservation.isUpcoming
                                ? () => _cancelReservation(reservation)
                                : null,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final Classroom? classroom;
  final VoidCallback? onCancel;

  const _ReservationCard({
    required this.reservation,
    required this.classroom,
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
                  classroom?.name ?? '알 수 없는 교실',
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

          const SizedBox(height: 12),

          // 날짜 및 시간
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

          // 취소 버튼 (예정된 예약만)
          if (onCancel != null) ...[
            const SizedBox(height: 12),
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
            ),
          ],
        ],
      ),
    );
  }
}
