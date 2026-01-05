import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/auth_repository_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 비밀번호 재설정 화면
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(_emailController.text.trim());

      setState(() {
        _emailSent = true;
      });
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
        title: const Text('비밀번호 재설정'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: _emailSent ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return Form(
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
                  Icons.mail_outline,
                  color: TossColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '비밀번호 재설정 링크 발송',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TossColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '가입 시 사용한 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
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

          // 이메일 입력
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'example@sen.go.kr',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return ErrorMessages.requiredField;
              }
              if (!value.contains('@')) {
                return ErrorMessages.invalidEmail;
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetEmail(),
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

          // 발송 버튼
          TossButton(
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
            child: const Text('재설정 링크 보내기'),
          ),

          const SizedBox(height: 8),

          // 취소 버튼
          OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: TossColors.textSub,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 성공 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 32),

            // 제목
            const Text(
              '이메일을 확인하세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 16),

            // 설명
            Text(
              '${_emailController.text}\n주소로 비밀번호 재설정 링크를 보냈습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: TossColors.textSub,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '이메일을 확인하고 링크를 클릭하여\n새로운 비밀번호를 설정하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: TossColors.textSub.withOpacity(0.8),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 48),

            // 돌아가기 버튼
            TossButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('로그인 화면으로'),
            ),

            const SizedBox(height: 12),

            // 이메일 다시 보내기
            TextButton(
              onPressed: () {
                setState(() {
                  _emailSent = false;
                  _errorMessage = null;
                });
              },
              child: const Text('다시 보내기'),
            ),
          ],
        ),
      ),
    );
  }
}
