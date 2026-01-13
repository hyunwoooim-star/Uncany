import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_card.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../data/providers/auth_repository_provider.dart';

/// 승인 대기 안내 화면 (토스 스타일)
///
/// 회원가입 완료 후 관리자 승인을 기다리는 동안 표시되는 화면
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

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

  Future<void> _refreshStatus(BuildContext context, WidgetRef ref) async {
    // 사용자 정보 새로고침
    ref.invalidate(currentUserProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('승인 상태를 확인했습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('Uncany'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: ResponsiveContent(
        child: RefreshIndicator(
          onRefresh: () => _refreshStatus(context, ref),
          child: ListView(
            padding: responsivePadding(context),
            children: [
              const SizedBox(height: 40),

              // 메인 아이콘
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: TossColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 60,
                    color: TossColors.warning,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 제목
              Text(
                '승인 대기 중',
                style: TextStyle(
                  fontSize: responsiveValue(context, mobile: 24.0, desktop: 28.0),
                  fontWeight: FontWeight.bold,
                  color: TossColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 설명
              currentUserAsync.when(
                data: (user) => Text(
                  '${user?.name ?? '선생님'}의 가입 신청이\n관리자 검토 중입니다',
                  style: TextStyle(
                    fontSize: responsiveValue(context, mobile: 16.0, desktop: 18.0),
                    color: TossColors.textSub,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 40),

              // 안내 카드
              TossCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TossColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: TossColors.info,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '승인 절차 안내',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TossColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      number: '1',
                      text: '제출하신 재직 증명 서류를 확인합니다',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      number: '2',
                      text: '보통 1~2 영업일 내에 승인됩니다',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      number: '3',
                      text: '승인 완료 시 이메일로 안내드립니다',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 새로고침 안내
              TossCard(
                onTap: () => _refreshStatus(context, ref),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TossColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: TossColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '승인 상태 확인',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: TossColors.textMain,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '탭하거나 아래로 당겨서 확인하세요',
                            style: TextStyle(
                              fontSize: 13,
                              color: TossColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: TossColors.textSub,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 문의 안내
              Center(
                child: Text(
                  '문의사항이 있으시면 관리자에게 연락해주세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: TossColors.textSub,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: TossColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: TossColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: TossColors.textSub,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
