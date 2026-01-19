import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/classroom_repository_provider.dart';
import '../domain/models/classroom.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';

/// 관리자 교실 관리 화면
///
/// 교실 목록 조회, 생성, 수정, 삭제, 활성화 관리
class AdminClassroomScreen extends ConsumerStatefulWidget {
  const AdminClassroomScreen({super.key});

  @override
  ConsumerState<AdminClassroomScreen> createState() =>
      _AdminClassroomScreenState();
}

class _AdminClassroomScreenState extends ConsumerState<AdminClassroomScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Classroom> _allClassrooms = [];
  List<Classroom> _filteredClassrooms = [];
  String? _errorMessage;

  // 통계
  int _totalCount = 0;
  int _activeCount = 0;
  int _inactiveCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClassrooms);
    _loadClassrooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(classroomRepositoryProvider);
      final classrooms = await repository.getClassrooms(activeOnly: false);

      setState(() {
        _allClassrooms = classrooms;
        _filteredClassrooms = classrooms;
        _isLoading = false;

        // 통계 계산
        _totalCount = classrooms.length;
        _activeCount = classrooms.where((c) => c.isActive).length;
        _inactiveCount = classrooms.where((c) => !c.isActive).length;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  void _filterClassrooms() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredClassrooms = _allClassrooms;
      } else {
        _filteredClassrooms = _allClassrooms.where((classroom) {
          return classroom.name.toLowerCase().contains(query) ||
              (classroom.location?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _createClassroom() async {
    final result = await context.push<bool>('/admin/classrooms/create');
    if (result == true && mounted) {
      _loadClassrooms();
    }
  }

  Future<void> _editClassroom(Classroom classroom) async {
    final result = await context.push<bool>(
      '/admin/classrooms/${classroom.id}/edit',
      extra: classroom,
    );
    if (result == true && mounted) {
      _loadClassrooms();
    }
  }

  Future<void> _toggleActiveStatus(Classroom classroom) async {
    try {
      final repository = ref.read(classroomRepositoryProvider);
      await repository.toggleActiveStatus(classroom.id);

      if (mounted) {
        TossSnackBar.warning(context, message: classroom.isActive ? '교실을 비활성화했습니다' : '교실을 활성화했습니다');
        _loadClassrooms();
      }
    } catch (e) {
      if (mounted) {
        TossSnackBar.error(context, message: ErrorMessages.fromError(e));
      }
    }
  }

  Future<void> _deleteClassroom(Classroom classroom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('교실 삭제'),
        content: Text(
          '${classroom.name}을(를) 삭제하시겠습니까?\n\n'
          '삭제된 교실은 예약할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(classroomRepositoryProvider);
        await repository.deleteClassroom(classroom.id);

        if (mounted) {
          TossSnackBar.warning(context, message: '교실을 삭제했습니다');
          _loadClassrooms();
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
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('교실 관리'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _createClassroom,
            icon: const Icon(Icons.add),
            tooltip: '교실 추가',
          ),
        ],
      ),
      body: Column(
        children: [
          // 통계 카드
          Container(
            color: TossColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: '전체',
                    count: _totalCount,
                    color: TossColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: '활성',
                    count: _activeCount,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    label: '비활성',
                    count: _inactiveCount,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '교실 이름 또는 위치 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: TossColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 교실 목록
          Expanded(
            child: _isLoading
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
                              onPressed: _loadClassrooms,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _filteredClassrooms.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.meeting_room_outlined,
                                    size: 64,
                                    color: TossColors.textSub.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? '등록된 교실이 없습니다'
                                      : '검색 결과가 없습니다',
                                  style: TextStyle(
                                      color: TossColors.textSub, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadClassrooms,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredClassrooms.length,
                              itemBuilder: (context, index) {
                                final classroom = _filteredClassrooms[index];
                                return _ClassroomCard(
                                  classroom: classroom,
                                  onEdit: () => _editClassroom(classroom),
                                  onToggleActive: () =>
                                      _toggleActiveStatus(classroom),
                                  onDelete: () => _deleteClassroom(classroom),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _ClassroomCard({
    required this.classroom,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasPassword = classroom.accessCodeHash != null;
    final hasNotice = classroom.noticeMessage != null;

    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 교실 이름 + 배지
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      classroom.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TossColors.textMain,
                      ),
                    ),
                    if (hasPassword) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: TossColors.textSub,
                      ),
                    ],
                    if (hasNotice) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.campaign,
                        size: 18,
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
              ),
              // 활성 상태 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (classroom.isActive ? Colors.green : Colors.grey)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  classroom.isActive ? '활성' : '비활성',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: classroom.isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 교실 정보
          Row(
            children: [
              if (classroom.capacity != null) ...[
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: TossColors.textSub,
                ),
                const SizedBox(width: 4),
                Text(
                  '${classroom.capacity}명',
                  style: TextStyle(
                    fontSize: 14,
                    color: TossColors.textSub,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (classroom.location != null) ...[
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: TossColors.textSub,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    classroom.location!,
                    style: TextStyle(
                      fontSize: 14,
                      color: TossColors.textSub,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // 액션 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('수정'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TossColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleActive,
                  icon: Icon(
                    classroom.isActive
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                  ),
                  label: Text(classroom.isActive ? '비활성화' : '활성화'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: '삭제',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
