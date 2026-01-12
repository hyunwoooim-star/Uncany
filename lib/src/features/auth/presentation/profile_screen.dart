import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/user.dart';
import '../data/providers/auth_repository_provider.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 프로필 화면 (v0.2)
///
/// 학년/반 정보 표시, "OOO 선생님 (N학년 N반)" 형식
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
            SnackBar(
              content: Text(ErrorMessages.fromError(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '계정을 삭제하시겠습니까?\n\n'
          '삭제된 계정은 복구할 수 없으며,\n'
          '모든 데이터가 영구적으로 삭제됩니다.',
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

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(authRepositoryProvider);
        await repository.deleteAccount();
        if (context.mounted) {
          context.go('/auth/login');
        }
      } catch (e) {
        if (context.mounted) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 프로필 헤더
              TossCard(
                child: Column(
                  children: [
                    // 아바타 (이니셜)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: TossColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(user.name),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: TossColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 이름 + 선생님
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: TossColors.textMain,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 학교명 + 학년/반
                    Text(
                      user.schoolName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: TossColors.textMain,
                      ),
                    ),

                    if (user.gradeClassDisplay != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.gradeClassDisplay!,
                        style: TextStyle(
                          fontSize: 14,
                          color: TossColors.textSub,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // 인증 배지
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _VerificationBadge(status: user.verificationStatus),
                        const SizedBox(width: 8),
                        _RoleBadge(role: user.role),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 정보 섹션
              const Text(
                '개인 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TossColors.textMain,
                ),
              ),

              const SizedBox(height: 12),

              TossCard(
                child: Column(
                  children: [
                    // 아이디
                    if (user.username != null) ...[
                      _InfoRow(
                        icon: Icons.alternate_email,
                        label: '아이디',
                        value: user.username!,
                      ),
                      const Divider(height: 24),
                    ],
                    // 이메일
                    if (user.email != null) ...[
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: '이메일',
                        value: user.email!,
                      ),
                      const Divider(height: 24),
                    ],
                    // 학년/반
                    if (user.grade != null && user.classNum != null) ...[
                      _InfoRow(
                        icon: Icons.groups_outlined,
                        label: '담당',
                        value: '${user.grade}학년 ${user.classNum}반',
                      ),
                      const Divider(height: 24),
                    ],
                    // 가입일
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: '가입일',
                      value: _formatDate(user.createdAt),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 액션 섹션
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TossColors.textMain,
                ),
              ),

              const SizedBox(height: 12),

              TossButton(
                onPressed: () => context.push('/profile/edit'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('프로필 수정'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () => context.push('/profile/reset-password'),
                icon: const Icon(Icons.lock_outline),
                label: const Text('비밀번호 변경'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TossColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () => context.push('/profile/referral-codes'),
                icon: const Icon(Icons.card_giftcard),
                label: const Text('내 추천인 코드'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TossColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () => _logout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TossColors.textSub,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),

              // 약관 및 정책
              const Text(
                '약관 및 정책',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TossColors.textMain,
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () => context.push('/settings/terms'),
                icon: const Icon(Icons.article_outlined),
                label: const Text('이용약관'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TossColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () => context.push('/settings/privacy'),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('개인정보처리방침'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TossColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () => context.push('/settings/business-info'),
                icon: const Icon(Icons.business_outlined),
                label: const Text('사업자 정보'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TossColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),

              // 위험 구역
              const Text(
                '위험 구역',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () => _deleteAccount(context, ref),
                icon: const Icon(Icons.delete_forever),
                label: const Text('계정 삭제'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TossColors.textSub),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: TossColors.textSub,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: TossColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final VerificationStatus status;

  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case VerificationStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        text = '승인 대기';
        break;
      case VerificationStatus.approved:
        color = Colors.green;
        icon = Icons.verified;
        text = '인증됨';
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        text = '반려됨';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin
            ? TossColors.primary.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 14,
            color: isAdmin ? TossColors.primary : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? '관리자' : '교사',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAdmin ? TossColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
