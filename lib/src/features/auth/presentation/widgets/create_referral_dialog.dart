import 'package:flutter/material.dart';

import '../../../../shared/theme/toss_colors.dart';
import '../../../../shared/widgets/toss_button.dart';

/// 추천인 코드 생성 다이얼로그
class CreateReferralDialog extends StatefulWidget {
  final String schoolName;

  const CreateReferralDialog({
    super.key,
    required this.schoolName,
  });

  @override
  State<CreateReferralDialog> createState() => _CreateReferralDialogState();
}

class _CreateReferralDialogState extends State<CreateReferralDialog> {
  int _maxUses = 5;
  int _expiresInDays = 30;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '추천인 코드 생성',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 8),

            // 학교명 표시
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school,
                    color: TossColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.schoolName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TossColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 최대 사용 횟수
            const Text(
              '최대 사용 횟수',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _maxUses.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_maxUses회',
                    onChanged: (value) {
                      setState(() {
                        _maxUses = value.toInt();
                      });
                    },
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: TossColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_maxUses회',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TossColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 유효 기간
            const Text(
              '유효 기간',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DurationChip(
                  label: '7일',
                  days: 7,
                  isSelected: _expiresInDays == 7,
                  onTap: () {
                    setState(() {
                      _expiresInDays = 7;
                    });
                  },
                ),
                _DurationChip(
                  label: '30일',
                  days: 30,
                  isSelected: _expiresInDays == 30,
                  onTap: () {
                    setState(() {
                      _expiresInDays = 30;
                    });
                  },
                ),
                _DurationChip(
                  label: '90일',
                  days: 90,
                  isSelected: _expiresInDays == 90,
                  onTap: () {
                    setState(() {
                      _expiresInDays = 90;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: TossColors.textSub.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '같은 학교 동료만 이 코드를 사용할 수 있습니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: TossColors.textSub.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TossColors.textSub,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TossButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'maxUses': _maxUses,
                        'expiresInDays': _expiresInDays,
                      });
                    },
                    child: const Text('생성'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final int days;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.days,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TossColors.primary
              : TossColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? TossColors.primary
                : TossColors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : TossColors.primary,
          ),
        ),
      ),
    );
  }
}
