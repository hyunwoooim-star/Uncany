import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/classroom_repository.dart';
import '../data/providers/classroom_repository_provider.dart';
import '../domain/models/classroom.dart';
import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';
import '../../../shared/widgets/toss_card.dart';
import '../../../core/utils/error_messages.dart';

/// 교실 목록 화면
///
/// 예약 가능한 교실 목록 조회, 검색, 선택
class ClassroomListScreen extends ConsumerStatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  ConsumerState<ClassroomListScreen> createState() =>
      _ClassroomListScreenState();
}

class _ClassroomListScreenState extends ConsumerState<ClassroomListScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Classroom> _allClassrooms = [];
  List<Classroom> _filteredClassrooms = [];
  String? _errorMessage;

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
      final classrooms = await repository.getClassrooms(activeOnly: true);

      setState(() {
        _allClassrooms = classrooms;
        _filteredClassrooms = classrooms;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('교실 예약'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
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
                              text: '다시 시도',
                              onPressed: _loadClassrooms,
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
                                  onTap: () {
                                    context.push('/classrooms/${classroom.id}');
                                  },
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

class _ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback onTap;

  const _ClassroomCard({
    required this.classroom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPassword = classroom.accessCodeHash != null;
    final hasNotice = classroom.noticeMessage != null;

    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 교실 이름 + 배지들
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
                  ],
                ),
              ),
              if (hasNotice)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.campaign,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '공지',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
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

          // 공지사항 (있는 경우)
          if (hasNotice) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.campaign,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      classroom.noticeMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: TossColors.textMain,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
