import 'package:flutter/material.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';

/// 에러 바텀시트 타입
enum ErrorBottomSheetType {
  /// 예약 충돌 에러
  reservationConflict,

  /// 일반 에러
  general,

  /// 네트워크 에러
  network,
}

/// 토스 스타일 에러 바텀시트
///
/// 에러 발생 시 빨간 토스트 대신 부드러운 바텀시트로 안내
class ErrorBottomSheet extends StatelessWidget {
  final ErrorBottomSheetType type;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  const ErrorBottomSheet({
    super.key,
    this.type = ErrorBottomSheetType.general,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onClose,
  });

  /// 예약 충돌 에러 바텀시트 표시
  static Future<void> showReservationConflict(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ErrorBottomSheet(
        type: ErrorBottomSheetType.reservationConflict,
        title: '예약할 수 없어요',
        message: message,
        actionLabel: '다시 선택하기',
        onAction: () {
          Navigator.pop(context);
          onRetry?.call();
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  /// 일반 에러 바텀시트 표시
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ErrorBottomSheet(
        type: ErrorBottomSheetType.general,
        title: title,
        message: message,
        actionLabel: actionLabel ?? '확인',
        onAction: () {
          Navigator.pop(context);
          onAction?.call();
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  /// 네트워크 에러 바텀시트 표시
  static Future<void> showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ErrorBottomSheet(
        type: ErrorBottomSheetType.network,
        title: '연결할 수 없어요',
        message: '네트워크 연결을 확인하고 다시 시도해주세요.',
        actionLabel: '다시 시도',
        onAction: () {
          Navigator.pop(context);
          onRetry?.call();
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // 아이콘
              _buildIcon(),
              const SizedBox(height: 20),

              // 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TossColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 메시지
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: TossColors.textSub,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // 액션 버튼
              if (actionLabel != null)
                TossButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),

              const SizedBox(height: 12),

              // 닫기 버튼
              TextButton(
                onPressed: onClose ?? () => Navigator.pop(context),
                child: Text(
                  '닫기',
                  style: TextStyle(
                    fontSize: 15,
                    color: TossColors.textSub,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;
    Color bgColor;

    switch (type) {
      case ErrorBottomSheetType.reservationConflict:
        icon = Icons.event_busy;
        color = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        break;
      case ErrorBottomSheetType.network:
        icon = Icons.wifi_off;
        color = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.1);
        break;
      case ErrorBottomSheetType.general:
      default:
        icon = Icons.error_outline;
        color = TossColors.error;
        bgColor = TossColors.error.withOpacity(0.1);
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 36,
        color: color,
      ),
    );
  }
}
