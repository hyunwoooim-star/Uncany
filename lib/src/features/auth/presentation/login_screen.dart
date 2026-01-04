import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/error_messages.dart';
import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showLoginForm = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/home');
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromAuthError(e.message);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _showLoginForm ? _buildLoginForm() : _buildWelcome(),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),

        // 로고 아이콘
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TossColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.school,
            size: 48,
            color: TossColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // 타이틀
        Text(
          'Uncany에\n오신 것을 환영합니다',
          style: Theme.of(context).textTheme.headlineLarge,
        ),

        const SizedBox(height: 12),

        Text(
          '학교 리소스 예약을 쉽고 편하게',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const Spacer(),

        // 로그인 버튼들
        TossButton(
          onPressed: () {
            setState(() {
              _showLoginForm = true;
            });
          },
          child: const Text('이메일로 로그인'),
        ),

        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () => context.push('/auth/signup'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: TossColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const SizedBox(
            width: double.infinity,
            child: Text(
              '회원가입',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TossColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () {
              setState(() {
                _showLoginForm = false;
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.arrow_back),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(height: 24),

          Text(
            '로그인',
            style: Theme.of(context).textTheme.headlineLarge,
          ),

          const SizedBox(height: 8),

          Text(
            '가입하신 이메일과 비밀번호를 입력해주세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          // 이메일
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!value.contains('@')) {
                return '유효한 이메일을 입력해주세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 비밀번호
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),

          // 에러 메시지
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: TossColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: TossColors.error, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 로그인 버튼
          TossButton(
            onPressed: _handleLogin,
            isLoading: _isLoading,
            child: const Text('로그인'),
          ),

          const SizedBox(height: 16),

          // 회원가입 링크
          Center(
            child: TextButton(
              onPressed: () => context.push('/auth/signup'),
              child: const Text(
                '계정이 없으신가요? 회원가입',
                style: TextStyle(color: TossColors.primary),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
