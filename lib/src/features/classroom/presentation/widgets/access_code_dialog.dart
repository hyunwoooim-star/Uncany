import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/classroom_repository_provider.dart';
import '../../../../shared/theme/toss_colors.dart';
import '../../../../core/utils/error_messages.dart';

/// 교실 비밀번호 입력 다이얼로그
///
/// 비밀번호로 보호된 교실 접근 시 사용
class AccessCodeDialog extends ConsumerStatefulWidget {
  final String classroomId;
  final String classroomName;

  const AccessCodeDialog({
    super.key,
    required this.classroomId,
    required this.classroomName,
  });

  @override
  ConsumerState<AccessCodeDialog> createState() => _AccessCodeDialogState();
}

class _AccessCodeDialogState extends ConsumerState<AccessCodeDialog> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _errorMessage = '비밀번호를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(classroomRepositoryProvider);
      final isValid = await repository.verifyAccessCode(
        widget.classroomId,
        code,
      );

      if (mounted) {
        if (isValid) {
          // 성공: true 반환
          Navigator.pop(context, true);
        } else {
          // 실패: 에러 메시지 표시
          setState(() {
            _errorMessage = '비밀번호가 일치하지 않습니다';
            _isVerifying = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorMessages.fromError(e);
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: TossColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '비밀번호 입력',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.classroomName}은(는) 비밀번호로 보호되어 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: TossColors.textSub,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '비밀번호를 입력하세요',
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: TossColors.background,
            ),
            onSubmitted: (_) => _verifyCode(),
            enabled: !_isVerifying,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: TossColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: TossColors.primary.withOpacity(0.5),
          ),
          child: _isVerifying
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('확인'),
        ),
      ],
    );
  }
}

/// 비밀번호 다이얼로그 표시 헬퍼 함수
///
/// Returns: true if verified, false if cancelled or failed
Future<bool> showAccessCodeDialog(
  BuildContext context, {
  required String classroomId,
  required String classroomName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AccessCodeDialog(
      classroomId: classroomId,
      classroomName: classroomName,
    ),
  );

  return result ?? false;
}
