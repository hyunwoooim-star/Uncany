import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/models/user.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/data/providers/auth_repository_provider.dart';
import '../../auth/data/providers/user_repository_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(authRepositoryProvider);
        await repository.signOut();
        if (context.mounted) {
          context.go('/auth/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그아웃 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final pendingCountAsync = ref.watch(_pendingCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uncany'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
            tooltip: '프로필',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('사용자 정보 없음'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 인사
              Text(
                '안녕하세요, ${user.name} 선생님!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                '오늘은 어떤 교실을 예약하시겠어요?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // 관리자 메뉴 (admin만 표시)
              if (user.role == UserRole.admin) ...[
                Text(
                  '관리자 메뉴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TossColors.textSub,
                      ),
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  icon: Icons.how_to_reg,
                  title: '사용자 승인',
                  subtitle: pendingCountAsync.when(
                    data: (count) => count > 0 ? '$count명 대기 중' : '대기 중인 사용자 없음',
                    loading: () => '로딩 중...',
                    error: (_, __) => '대기 중인 사용자 확인',
                  ),
                  color: Colors.purple,
                  onTap: () => context.push('/admin/approvals'),
                  badge: pendingCountAsync.when(
                    data: (count) => count > 0 ? count : null,
                    loading: () => null,
                    error: (_, __) => null,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  icon: Icons.people,
                  title: '사용자 관리',
                  subtitle: '전체 사용자 조회 및 관리',
                  color: Colors.indigo,
                  onTap: () => context.push('/admin/users'),
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  icon: Icons.meeting_room,
                  title: '교실 관리',
                  subtitle: '교실 등록, 수정 및 삭제',
                  color: Colors.teal,
                  onTap: () => context.push('/admin/classrooms'),
                ),
                const SizedBox(height: 24),
                Text(
                  '일반 메뉴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TossColors.textSub,
                      ),
                ),
                const SizedBox(height: 12),
              ],

              // 빠른 예약
              _QuickActionCard(
                icon: Icons.calendar_today,
                title: '교실 예약',
                subtitle: '컴퓨터실, 과학실 등',
                color: TossColors.primary,
                onTap: () {
                  context.push('/classrooms');
                },
              ),

              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.list_alt,
                title: '내 예약 내역',
                subtitle: '예약 확인 및 관리',
                color: TossColors.success,
                onTap: () {
                  context.push('/reservations/my');
                },
              ),

              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.school,
                title: '교실 관리',
                subtitle: '교실 정보 및 공지',
                color: TossColors.warning,
                onTap: () {
                  // TODO: 교실 관리 화면
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('오류: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

// 승인 대기 중인 사용자 수 Provider
final _pendingCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getPendingCount();
});

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  if (badge != null && badge! > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badge! > 99 ? '99+' : badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: TossColors.textSub,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
