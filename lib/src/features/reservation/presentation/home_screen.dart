import 'package:flutter/material.dart';

import '../../../shared/theme/toss_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uncany'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: 프로필 화면
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 인사
          Text(
            '안녕하세요!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            '오늘은 어떤 교실을 예약하시겠어요?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // 빠른 예약
          _QuickActionCard(
            icon: Icons.calendar_today,
            title: '교실 예약',
            subtitle: '컴퓨터실, 과학실 등',
            color: TossColors.primary,
            onTap: () {
              // TODO: 예약 화면
            },
          ),

          const SizedBox(height: 12),

          _QuickActionCard(
            icon: Icons.list_alt,
            title: '내 예약 내역',
            subtitle: '예약 확인 및 관리',
            color: TossColors.success,
            onTap: () {
              // TODO: 예약 내역 화면
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
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

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
