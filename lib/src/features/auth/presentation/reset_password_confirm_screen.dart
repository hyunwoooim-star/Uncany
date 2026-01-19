import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_repository_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';

/// 비밀번호 재설정 확인 화면
///
/// 이메일 링크를 통해 접근하며, 새로운 비밀번호를 입력받습니다.
class ResetPasswordConfirmScreen extends ConsumerStatefulWidget {
  const ResetPasswordConfirmScreen({super.key});

  @override
  ConsumerState<ResetPasswordConfirmScreen> createState() =>
      _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState
    extends ConsumerState<ResetPasswordConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updatePassword(_passwordController.text);

      if (mounted) {
        // 성공 시 로그인 화면으로 이동
        context.go('/auth/login');
        // 성공 메시지 표시
        TossSnackBar.success(context, message: '비밀번호가 변경되었습니다');
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
                    Icons.lock_reset,
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
                          '새로운 비밀번호를 입력하세요.\n비밀번호는 6자 이상이어야 합니다.',
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
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '새 비밀번호',
                hintText: '6자 이상 입력',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                if (value == null || value.isEmpty) {
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

            // 비밀번호 확인
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호 재입력',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return ErrorMessages.requiredField;
                }
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다.';
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
