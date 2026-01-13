import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_repository_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 비밀번호 재설정 완료 화면 (이메일 링크 클릭 후)
///
/// 사용자가 이메일의 재설정 링크를 클릭하면 이 화면이 표시되며,
/// 새로운 비밀번호를 입력받습니다.
class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updatePassword(_newPasswordController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 성공적으로 변경되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('새 비밀번호 설정'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 안내
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: TossColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '새 비밀번호 설정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TossColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '안전한 비밀번호를 설정하세요.\n6자 이상, 영문/숫자/특수문자 조합을 권장합니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: TossColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 새 비밀번호 입력
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: '새 비밀번호',
                hintText: '6자 이상 입력하세요',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return ErrorMessages.requiredField;
                }
                if (value.length < 6) {
                  return ErrorMessages.invalidPassword;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // 비밀번호 확인 입력
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력하세요',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscureConfirm,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return ErrorMessages.requiredField;
                }
                if (value != _newPasswordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _updatePassword(),
            ),

            const SizedBox(height: 24),

            // 에러 메시지
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_errorMessage != null) const SizedBox(height: 16),

            // 변경 버튼
            TossButton(
              onPressed: _updatePassword,
              isLoading: _isLoading,
              child: const Text('비밀번호 변경'),
            ),

            const SizedBox(height: 8),

            // 취소 버튼
            OutlinedButton(
              onPressed: _isLoading ? null : () => context.go('/auth/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TossColors.textSub,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('취소'),
            ),
          ],
        ),
      ),
    );
  }
}
