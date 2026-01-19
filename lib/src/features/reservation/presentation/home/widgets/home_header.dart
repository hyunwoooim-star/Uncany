import 'package:flutter/material.dart';

import '../../../../auth/domain/models/user.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';

/// 홈 화면 상단 인사말 카드
class HomeHeader extends StatelessWidget {
  final User user;

  const HomeHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                height: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                decoration: BoxDecoration(
                  color: TossColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: TossColors.primary,
                  size: responsiveIconSize(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: responsiveFontSize(context, base: 14),
                        color: TossColors.textSub,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.name} 선생님',
                      style: TextStyle(
                        fontSize: responsiveFontSize(context, base: 20),
                        fontWeight: FontWeight.bold,
                        color: TossColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user.gradeClassDisplay != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TossColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.gradeClassDisplay!,
                style: TextStyle(
                  fontSize: responsiveFontSize(context, base: 13),
                  color: TossColors.textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 6) return '새벽이에요';
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후예요';
    return '좋은 저녁이에요';
  }
}
