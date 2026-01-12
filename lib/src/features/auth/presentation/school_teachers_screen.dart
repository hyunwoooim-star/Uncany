import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user.dart';
import '../data/providers/user_repository_provider.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 우리 학교 선생님 목록 화면
///
/// 같은 학교에 재직 중인 선생님들의 목록을 보여주는 화면
/// 타 학교 선생님 가입 방지 및 우리 학교 선생님 확인용
class SchoolTeachersScreen extends ConsumerStatefulWidget {
  const SchoolTeachersScreen({super.key});

  @override
  ConsumerState<SchoolTeachersScreen> createState() =>
      _SchoolTeachersScreenState();
}

class _SchoolTeachersScreenState extends ConsumerState<SchoolTeachersScreen> {
  bool _isLoading = true;
  List<User> _teachers = [];
  String? _errorMessage;
  String? _schoolName;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 현재 사용자 정보 가져오기
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null || currentUser.schoolId == null) {
        throw Exception('학교 정보를 찾을 수 없습니다');
      }

      _schoolName = currentUser.schoolName;

      // 같은 학교 선생님 목록 조회
      final repository = ref.read(userRepositoryProvider);
      final teachers = await repository.getUsers(
        activeOnly: true,
        schoolId: currentUser.schoolId,
        status: VerificationStatus.approved, // 승인된 선생님만
      );

      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('우리 학교 선생님'),
        backgroundColor: TossColors.surface,
        elevation: 0,
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
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTeachers,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTeachers,
                  child: Column(
                    children: [
                      // 학교 정보 헤더
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: TossColors.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: TossColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: TossColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _schoolName ?? '우리 학교',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: TossColors.textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '총 ${_teachers.length}명',
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 안내 메시지
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TossColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: TossColors.info.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: TossColors.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '같은 학교 선생님들만 표시됩니다',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TossColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 선생님 목록
                      Expanded(
                        child: _teachers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 80,
                                      color:
                                          TossColors.textSub.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '아직 승인된 선생님이 없습니다',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: TossColors.textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                itemCount: _teachers.length,
                                itemBuilder: (context, index) {
                                  final teacher = _teachers[index];
                                  return _TeacherCard(teacher: teacher);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

/// 선생님 카드 위젯
class _TeacherCard extends StatelessWidget {
  final User teacher;

  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TossColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                teacher.name.isNotEmpty ? teacher.name[0] : '?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TossColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 선생님 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher.name} 선생님',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TossColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                if (teacher.gradeClassDisplay != null)
                  Text(
                    teacher.gradeClassDisplay!,
                    style: TextStyle(
                      fontSize: 13,
                      color: TossColors.textSub,
                    ),
                  ),
              ],
            ),
          ),

          // 역할 배지
          if (teacher.role == UserRole.admin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '관리자',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
