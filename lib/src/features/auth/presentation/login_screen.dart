import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // 로고 & 타이틀
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
                  // TODO: 교육청 이메일 로그인
                },
                child: const Text('교육청 이메일로 로그인'),
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
          ),
        ),
      ),
    );
  }
}
