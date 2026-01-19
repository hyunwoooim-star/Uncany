import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';
import 'quick_action_grid.dart';

/// 관리자 메뉴 섹션
class AdminMenuSection extends StatelessWidget {
  final AsyncValue<int> pendingCountAsync;

  const AdminMenuSection({
    super.key,
    required this.pendingCountAsync,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = responsiveSpacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '관리자'),
        SizedBox(height: spacing * 0.75),
        Row(
          children: [
            Expanded(
              child: CompactActionButton(
                icon: Icons.how_to_reg,
                label: '사용자 승인',
                color: Colors.purple,
                onTap: () => context.push('/admin/approvals'),
                badge: pendingCountAsync.when(
                  data: (count) => count > 0 ? count : null,
                  loading: () => null,
                  error: (_, __) => null,
                ),
              ),
            ),
            SizedBox(width: spacing * 0.75),
            Expanded(
              child: CompactActionButton(
                icon: Icons.people,
                label: '사용자 관리',
                color: Colors.indigo,
                onTap: () => context.push('/admin/users'),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing * 0.75),
        CompactActionButton(
          icon: Icons.meeting_room,
          label: '교실 관리',
          color: Colors.teal,
          onTap: () => context.push('/admin/classrooms'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: responsiveFontSize(context, base: 15),
          fontWeight: FontWeight.w600,
          color: TossColors.textSub,
        ),
      ),
    );
  }
}
