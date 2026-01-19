import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';

/// 홈 화면 빠른 액션 그리드 (교실 예약, 종합 시간표, 우리 학교 교사)
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = responsiveSpacing(context);

    return Column(
      children: [
        // 교실 예약 + 종합 시간표
        Row(
          children: [
            Expanded(
              child: CompactActionButton(
                icon: Icons.calendar_today,
                label: '교실 예약',
                color: TossColors.primary,
                onTap: () => context.push('/classrooms'),
              ),
            ),
            SizedBox(width: spacing * 0.75),
            Expanded(
              child: CompactActionButton(
                icon: Icons.grid_view,
                label: '종합 시간표',
                color: Colors.orange,
                onTap: () => context.push('/reservations/timetable'),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing * 0.75),
        // 우리 학교 교사
        CompactActionButton(
          icon: Icons.people_outline,
          label: '우리 학교 교사',
          color: Colors.teal,
          onTap: () => context.push('/school/members'),
        ),
      ],
    );
  }
}

/// 컴팩트 액션 버튼 (2열 그리드용)
class CompactActionButton extends StatelessWidget {
  const CompactActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return TossCard(
      onTap: onTap,
      padding: responsiveCardPadding(context),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: responsiveValue(context, mobile: 40.0, desktop: 48.0),
                height: responsiveValue(context, mobile: 40.0, desktop: 48.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: responsiveIconSize(context, base: 20),
                ),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsiveFontSize(context, base: 14),
                fontWeight: FontWeight.w600,
                color: TossColors.textMain,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: TossColors.textSub,
          ),
        ],
      ),
    );
  }
}
