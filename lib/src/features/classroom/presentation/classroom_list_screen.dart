import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/providers/classroom_repository_provider.dart';
import '../domain/models/classroom.dart';
import 'package:uncany/src/features/reservation/data/providers/reservation_repository_provider.dart';
import 'package:uncany/src/features/reservation/domain/models/reservation.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/month_calendar.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 교실 예약 메인 화면 (리디자인)
///
/// 참고: 수업 예약 앱 디자인 - 교실 선택, 월간 캘린더, 예약 목록
class ClassroomListScreen extends ConsumerStatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  ConsumerState<ClassroomListScreen> createState() =>
      _ClassroomListScreenState();
}

class _ClassroomListScreenState extends ConsumerState<ClassroomListScreen> {
  bool _isLoading = true;
  List<Classroom> _classrooms = [];
  Classroom? _selectedClassroom;
  DateTime _selectedDate = DateTime.now();
  List<Reservation> _reservations = [];
  bool _isLoadingReservations = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(classroomRepositoryProvider);
      final classrooms = await repository.getClassrooms(activeOnly: true);

      setState(() {
        _classrooms = classrooms;
        if (classrooms.isNotEmpty) {
          _selectedClassroom = classrooms.first;
        }
        _isLoading = false;
      });

      if (_selectedClassroom != null) {
        _loadReservations();
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReservations() async {
    if (_selectedClassroom == null) return;

    setState(() {
      _isLoadingReservations = true;
    });

    try {
      final repository = ref.read(reservationRepositoryProvider);
      final reservations = await repository.getReservationsByClassroom(
        _selectedClassroom!.id,
        date: _selectedDate,
      );

      setState(() {
        _reservations = reservations;
        _isLoadingReservations = false;
      });
    } catch (e) {
      setState(() {
        _reservations = [];
        _isLoadingReservations = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadReservations();
  }

  void _showClassroomSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TossColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ClassroomSelectorSheet(
        classrooms: _classrooms,
        selectedClassroom: _selectedClassroom,
        onSelected: (classroom) {
          setState(() {
            _selectedClassroom = classroom;
          });
          Navigator.pop(context);
          _loadReservations();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('수업 예약'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildContent(),
      floatingActionButton: _selectedClassroom != null
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/classrooms/${_selectedClassroom!.id}');
              },
              backgroundColor: TossColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '예약하기',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadClassrooms,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadClassrooms();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassroomSelector(),
            const Divider(height: 1, color: TossColors.divider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MonthCalendar(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
              ),
            ),
            const Divider(height: 1, color: TossColors.divider),
            _buildReservationHeader(),
            _buildReservationList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildClassroomSelector() {
    return InkWell(
      onTap: _classrooms.length > 1 ? _showClassroomSelector : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.meeting_room,
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
                    _selectedClassroom?.name ?? '교실을 선택하세요',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TossColors.textMain,
                    ),
                  ),
                  if (_selectedClassroom?.location != null)
                    Text(
                      _selectedClassroom!.location!,
                      style: TextStyle(
                        fontSize: 13,
                        color: TossColors.textSub,
                      ),
                    ),
                ],
              ),
            ),
            if (_classrooms.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: TossColors.divider),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '변경',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: TossColors.textSub,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationHeader() {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            dateFormat.format(_selectedDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TossColors.textMain,
            ),
          ),
          const SizedBox(width: 8),
          if (_isLoadingReservations)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              '${_reservations.length}건',
              style: TextStyle(
                fontSize: 14,
                color: TossColors.textSub,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReservationList() {
    if (_isLoadingReservations) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reservations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: TossColors.textSub.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                '예약이 없습니다',
                style: TextStyle(
                  fontSize: 15,
                  color: TossColors.textSub,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '아래 버튼으로 새 예약을 추가하세요',
                style: TextStyle(
                  fontSize: 13,
                  color: TossColors.textSub.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _reservations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return _ReservationCard(reservation: reservation);
      },
    );
  }
}

/// 교실 선택 바텀시트
class _ClassroomSelectorSheet extends StatelessWidget {
  final List<Classroom> classrooms;
  final Classroom? selectedClassroom;
  final ValueChanged<Classroom> onSelected;

  const _ClassroomSelectorSheet({
    required this.classrooms,
    required this.selectedClassroom,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '교실 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TossColors.textMain,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                final classroom = classrooms[index];
                final isSelected = classroom.id == selectedClassroom?.id;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TossColors.primary.withOpacity(0.1)
                          : TossColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.meeting_room,
                      color: isSelected ? TossColors.primary : TossColors.textSub,
                    ),
                  ),
                  title: Text(
                    classroom.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: TossColors.textMain,
                    ),
                  ),
                  subtitle: classroom.location != null
                      ? Text(
                          classroom.location!,
                          style: TextStyle(color: TossColors.textSub),
                        )
                      : null,
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: TossColors.primary)
                      : null,
                  onTap: () => onSelected(classroom),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 예약 카드 위젯
class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startStr = timeFormat.format(reservation.startTime);
    final endStr = timeFormat.format(reservation.endTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TossColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TossColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  startStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TossColors.primary,
                  ),
                ),
                Text(
                  '~',
                  style: TextStyle(
                    fontSize: 12,
                    color: TossColors.textSub,
                  ),
                ),
                Text(
                  endStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TossColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.title ?? '예약',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TossColors.textMain,
                  ),
                ),
                if (reservation.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    reservation.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: TossColors.textSub,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    if (reservation.isOngoing) {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
      text = '진행중';
    } else if (reservation.isUpcoming) {
      bgColor = TossColors.primary.withOpacity(0.1);
      textColor = TossColors.primary;
      text = '예정';
    } else {
      bgColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
      text = '완료';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
