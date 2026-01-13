import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 아이디 찾기 화면
class FindUsernameScreen extends ConsumerStatefulWidget {
  const FindUsernameScreen({super.key});

  @override
  ConsumerState<FindUsernameScreen> createState() => _FindUsernameScreenState();
}

class _FindUsernameScreenState extends ConsumerState<FindUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _found = false;
  String? _foundUsername;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _findUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _found = false;
      _foundUsername = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final email = _emailController.text.trim();

      // RPC 함수로 이메일 기반 username 조회 (RLS 우회)
      final username = await supabase.rpc(
        'get_username_by_email',
        params: {'email_input': email},
      );

      if (username == null || (username as String).isEmpty) {
        setState(() {
          _errorMessage = '해당 이메일로 등록된 계정이 없습니다';
        });
      } else {
        setState(() {
          _found = true;
          _foundUsername = username;
        });
      }
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
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
        title: const Text('아이디 찾기'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: _found ? _buildSuccessView() : _buildFormView(),
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
                  Icons.search,
                  color: TossColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아이디 찾기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TossColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '가입 시 사용한 이메일 주소를 입력하시면\n아이디를 알려드립니다.',
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
            onFieldSubmitted: (_) => _findUsername(),
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

          // 찾기 버튼
          TossButton(
            onPressed: _findUsername,
            isLoading: _isLoading,
            child: const Text('아이디 찾기'),
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
              '아이디를 찾았습니다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),

            const SizedBox(height: 24),

            // 아이디 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TossColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '아이디',
                    style: TextStyle(
                      fontSize: 14,
                      color: TossColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _foundUsername ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: TossColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // 로그인 버튼
            TossButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('로그인 화면으로'),
            ),

            const SizedBox(height: 12),

            // 비밀번호 찾기
            TextButton(
              onPressed: () => context.push('/auth/reset-password'),
              child: const Text('비밀번호도 잊으셨나요?'),
            ),
          ],
        ),
      ),
    );
  }
}
