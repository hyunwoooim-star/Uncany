import 'package:flutter/material.dart';
import '../theme/toss_colors.dart';

/// 예약 상태 뱃지 위젯
///
/// home_screen.dart의 중복된 _buildStatusBadge를 공통 위젯으로 추출
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, text) = _getStatusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// 상태별 스타일 반환 (색상, 배경색, 텍스트)
  static (Color, Color, String) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case '확정':
        return (
          TossColors.success,
          TossColors.success.withOpacity(0.1),
          '확정',
        );
      case 'pending':
      case '대기':
        return (
          TossColors.warning,
          TossColors.warning.withOpacity(0.1),
          '대기',
        );
      case 'cancelled':
      case '취소':
        return (
          TossColors.error,
          TossColors.error.withOpacity(0.1),
          '취소',
        );
      case 'completed':
      case '완료':
        return (
          TossColors.textSub,
          TossColors.textSub.withOpacity(0.1),
          '완료',
        );
      case 'in_progress':
      case '진행중':
        return (
          TossColors.primary,
          TossColors.primary.withOpacity(0.1),
          '진행중',
        );
      case 'upcoming':
      case '예정':
        return (
          TossColors.success,
          TossColors.success.withOpacity(0.1),
          '예정',
        );
      default:
        return (
          TossColors.textSub,
          TossColors.textSub.withOpacity(0.1),
          status,
        );
    }
  }
}
