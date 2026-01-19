import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uncany/src/core/providers/supabase_provider.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/toss_skeleton.dart';
import '../domain/models/user.dart';

/// 우리 학교 교사 목록 Provider
final schoolMembersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final supabase = ref.watch(supabaseProvider);

  // RLS가 자동으로 같은 학교 사용자만 반환
  final response = await supabase
      .from('users')
      .select()
      .eq('verification_status', 'approved')
      .isFilter('deleted_at', null)
      .order('grade', ascending: true)
      .order('class_num', ascending: true)
      .order('name', ascending: true);

  return (response as List)
      .map((json) => User.fromJson(json as Map<String, dynamic>))
      .toList();
});

/// 우리 학교 교사 목록 화면
class SchoolMembersScreen extends ConsumerWidget {
  const SchoolMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(schoolMembersProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: Text(currentUser?.schoolName ?? '우리 학교 교사'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: membersAsync.when(
        data: (members) => _buildMembersList(context, members, currentUser),
        loading: () => _buildLoadingSkeleton(),
        error: (error, _) => _buildError(context, ref, error),
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<User> members, User? currentUser) {
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: TossColors.textSub.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 가입한 교사가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: TossColors.textSub,
              ),
            ),
          ],
        ),
      );
    }

    // 학년별로 그룹화
    final grouped = <int?, List<User>>{};
    for (final member in members) {
      grouped.putIfAbsent(member.grade, () => []).add(member);
    }

    final sortedGrades = grouped.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 총 인원 표시
        TossCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: TossColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.schoolName ?? '우리 학교',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TossColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총 ${members.length}명의 선생님',
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
        ),

        const SizedBox(height: 24),

        // 학년별 교사 목록
        ...sortedGrades.map((grade) {
          final gradeMembers = grouped[grade]!;
          final gradeLabel = grade != null ? '$grade학년' : '학년 미지정';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      gradeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TossColors.textSub,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TossColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${gradeMembers.length}명',
                        style: TextStyle(
                          fontSize: 12,
                          color: TossColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TossCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: gradeMembers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    final isMe = member.id == currentUser?.id;

                    return Column(
                      children: [
                        if (index > 0)
                          Divider(height: 1, color: TossColors.divider),
                        _MemberTile(member: member, isMe: isMe),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TossSkeletonCard(height: 80),
        const SizedBox(height: 24),
        TossSkeleton(width: 60, height: 16, borderRadius: 4),
        const SizedBox(height: 8),
        TossSkeletonCard(height: 180),
        const SizedBox(height: 16),
        TossSkeleton(width: 60, height: 16, borderRadius: 4),
        const SizedBox(height: 8),
        TossSkeletonCard(height: 120),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TossColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '목록을 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: TossColors.textSub,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.invalidate(schoolMembersProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

/// 교사 목록 아이템
class _MemberTile extends StatelessWidget {
  final User member;
  final bool isMe;

  const _MemberTile({
    required this.member,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe
                  ? TossColors.primary.withOpacity(0.1)
                  : TossColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0] : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMe ? TossColors.primary : TossColors.textSub,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 이름 + 반
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                        color: TossColors.textMain,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: TossColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '나',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (member.classNum != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${member.classNum}반',
                    style: TextStyle(
                      fontSize: 13,
                      color: TossColors.textSub,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
