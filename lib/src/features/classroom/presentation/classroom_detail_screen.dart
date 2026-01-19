import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/providers/classroom_repository_provider.dart';
import '../domain/models/classroom.dart';
import '../../reservation/data/providers/reservation_repository_provider.dart';
import '../../reservation/domain/models/reservation.dart';
import 'package:go_router/go_router.dart';
// v0.2: CreateReservationSheet 삭제됨
import '../../reservation/presentation/widgets/time_table_grid.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'widgets/access_code_dialog.dart';
import 'classroom_form_screen.dart';

/// 교실 상세 화면
///
/// 특정 교실의 예약 현황 조회 및 예약 생성
class ClassroomDetailScreen extends ConsumerStatefulWidget {
  final String classroomId;

  const ClassroomDetailScreen({
    super.key,
    required this.classroomId,
  });

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen> {
  Classroom? _classroom;
  List<Reservation> _reservations = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isLoadingReservations = false;
  String? _errorMessage;
  bool _isVerified = false; // 비밀번호 인증 여부
  bool _isGridView = true; // 그리드 뷰 / 리스트 뷰 전환

  @override
  void initState() {
    super.initState();
    _loadClassroom();
  }

  Future<void> _loadClassroom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(classroomRepositoryProvider);
      final classroom = await repository.getClassroom(widget.classroomId);

      if (classroom == null) {
        setState(() {
          _errorMessage = '교실을 찾을 수 없습니다';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _classroom = classroom;
        _isLoading = false;
      });

      // 비밀번호 보호 확인
      if (classroom.accessCodeHash != null && !_isVerified) {
        await _verifyAccess();
      } else {
        _loadReservations();
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAccess() async {
    if (_classroom == null) return;

    final verified = await showAccessCodeDialog(
      context,
      classroomId: widget.classroomId,
      classroomName: _classroom!.name,
    );

    if (verified) {
      setState(() {
        _isVerified = true;
      });
      _loadReservations();
    } else {
      // 인증 실패 시 뒤로 가기
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoadingReservations = true;
    });

    try {
      final repository = ref.read(reservationRepositoryProvider);
      final reservations = await repository.getReservationsByClassroom(
        widget.classroomId,
        date: _selectedDate,
      );

      setState(() {
        _reservations = reservations;
        _isLoadingReservations = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoadingReservations = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TossColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReservations();
    }
  }

  Future<void> _createReservation() async {
    final result = await context.push<bool>(
      "/reservations/${widget.classroomId}",
      extra: _classroom,
    );

    // 예약이 성공적으로 생성되면 목록 새로고침
    if (result == true) {
      _loadReservations();
    }
  }

  /// 교실 수정 화면으로 이동
  Future<void> _editClassroom() async {
    if (_classroom == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClassroomFormScreen(classroom: _classroom),
      ),
    );

    // 수정되면 교실 정보 다시 로드
    if (result == true && mounted) {
      _loadClassroom();
    }
  }

  /// 교실 삭제 확인 다이얼로그
  Future<void> _confirmDeleteClassroom() async {
    if (_classroom == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('교실 삭제'),
        content: Text('\'${_classroom!.name}\' 교실을 삭제하시겠습니까?\n\n삭제 후에도 기존 예약 내역은 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: TossColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteClassroom();
    }
  }

  /// 교실 삭제 실행
  Future<void> _deleteClassroom() async {
    try {
      final repository = ref.read(classroomRepositoryProvider);
      await repository.deleteClassroom(widget.classroomId);

      if (mounted) {
        TossSnackBar.success(context, message: '교실이 삭제되었습니다');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        TossSnackBar.error(context, message: ErrorMessages.fromError(e));
      }
    }
  }

  /// 생성자 정보 팝업
  void _showCreatorInfo() {
    if (_classroom == null || _classroom!.creatorName == null) return;

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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TossColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      _classroom!.creatorName![0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TossColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '교실 등록자',
                        style: TextStyle(
                          fontSize: 13,
                          color: TossColors.textSub,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _classroom!.creatorDisplayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TossColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: TossColors.textSub,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '교실 설정 변경이 필요하면 등록자에게 문의해주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: TossColors.textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: TossColors.background,
        appBar: AppBar(
          backgroundColor: TossColors.surface,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _classroom == null) {
      return Scaffold(
        backgroundColor: TossColors.background,
        appBar: AppBar(
          backgroundColor: TossColors.surface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? '교실을 불러올 수 없습니다',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: Text(_classroom!.name),
        backgroundColor: TossColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.view_week),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? '리스트 보기' : '그리드 보기',
          ),
          // 교실 관리 메뉴
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editClassroom();
                  break;
                case 'delete':
                  _confirmDeleteClassroom();
                  break;
              }
            },
            itemBuilder: (context) {
              final currentUserId = Supabase.instance.client.auth.currentUser?.id;
              final isCreator = _classroom?.createdBy == currentUserId;
              final currentUserAsync = ref.watch(currentUserProvider);
              final isAdmin = currentUserAsync.value?.role == 'admin';
              final canEdit = isCreator || isAdmin || _classroom?.createdBy == null;

              return [
                PopupMenuItem<String>(
                  value: 'edit',
                  enabled: canEdit,
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: canEdit ? TossColors.textMain : TossColors.textSub,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '교실 수정',
                        style: TextStyle(
                          color: canEdit ? TossColors.textMain : TossColors.textSub,
                        ),
                      ),
                      if (!canEdit) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.lock, size: 14, color: TossColors.textSub),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  enabled: canEdit,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: canEdit ? TossColors.error : TossColors.textSub,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '교실 삭제',
                        style: TextStyle(
                          color: canEdit ? TossColors.error : TossColors.textSub,
                        ),
                      ),
                      if (!canEdit) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.lock, size: 14, color: TossColors.textSub),
                      ],
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 교실 정보 카드
          Container(
            color: TossColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 교실 정보
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (_classroom!.capacity != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 18,
                            color: TossColors.textSub,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_classroom!.capacity}명',
                            style: TextStyle(
                              fontSize: 14,
                              color: TossColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    if (_classroom!.location != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: TossColors.textSub,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _classroom!.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: TossColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    // 생성자 정보
                    if (_classroom!.creatorName != null)
                      GestureDetector(
                        onTap: () => _showCreatorInfo(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 18,
                              color: TossColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '등록: ${_classroom!.creatorDisplayName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: TossColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // 공지사항
                if (_classroom!.noticeMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _classroom!.noticeMessage!,
                            style: TextStyle(
                              fontSize: 13,
                              color: TossColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 날짜 선택기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TossColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: TossColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy년 M월 d일 (E)', 'ko_KR')
                                .format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TossColors.textMain,
                            ),
                          ),
                          Text(
                            '날짜를 선택하세요',
                            style: TextStyle(
                              fontSize: 12,
                              color: TossColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: TossColors.textSub,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 예약 목록/그리드
          Expanded(
            child: _isLoadingReservations
                ? const Center(child: CircularProgressIndicator())
                : _reservations.isEmpty && !_isGridView
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 64,
                              color: TossColors.textSub.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '예약이 없습니다',
                              style: TextStyle(
                                color: TossColors.textSub,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '새 예약을 만들어보세요',
                              style: TextStyle(
                                color: TossColors.textSub,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? TimeTableGrid(
                            reservations: _reservations,
                            selectedDate: _selectedDate,
                            onTimeSlotTap: _createReservation,
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReservations,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _reservations.length,
                              itemBuilder: (context, index) {
                                final reservation = _reservations[index];
                                return _ReservationCard(
                                    reservation: reservation);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createReservation,
        backgroundColor: TossColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '예약하기',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(reservation.startTime);
    final endTime = timeFormat.format(reservation.endTime);

    // 상태별 색상
    Color statusColor;
    String statusText;
    if (reservation.isOngoing) {
      statusColor = Colors.green;
      statusText = '진행 중';
    } else if (reservation.isUpcoming) {
      statusColor = TossColors.primary;
      statusText = '예정';
    } else {
      statusColor = Colors.grey;
      statusText = '완료';
    }

    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 시간 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$startTime - $endTime',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 상태 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              // 기간 표시
              Text(
                '${reservation.durationInMinutes}분',
                style: TextStyle(
                  fontSize: 12,
                  color: TossColors.textSub,
                ),
              ),
            ],
          ),

          if (reservation.title != null) ...[
            const SizedBox(height: 12),
            Text(
              reservation.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),
          ],

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
        ],
      ),
    );
  }
}
