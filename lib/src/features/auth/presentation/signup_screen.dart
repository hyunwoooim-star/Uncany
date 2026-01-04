import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';
import '../../../shared/widgets/toss_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _useReferralCode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기본 정보를 입력해주세요',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 32),

                // 이름
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    hintText: '김철수',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 학교명
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    labelText: '학교명',
                    hintText: '서울초등학교',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '학교명을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 교육청 이메일 (선택)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '교육청 이메일 (선택)',
                    hintText: 'user@sen.go.kr',
                    helperText: '빠른 인증을 원하시면 입력해주세요',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 32),

                // 가입 방법 선택
                TossCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '가입 방법 선택',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // 추천인 코드
                      CheckboxListTile(
                        value: _useReferralCode,
                        onChanged: (value) {
                          setState(() {
                            _useReferralCode = value ?? false;
                          });
                        },
                        title: const Text('추천인 코드 있음'),
                        subtitle: const Text('같은 학교 선생님의 초대 코드'),
                        contentPadding: EdgeInsets.zero,
                      ),

                      if (_useReferralCode) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _referralCodeController,
                          decoration: const InputDecoration(
                            labelText: '추천인 코드',
                            hintText: 'SEOUL-ABC123',
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      const Text(
                        '또는 재직증명서로 가입',
                        style: TextStyle(
                          color: TossColors.textSub,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 다음 버튼
                TossButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: 회원가입 로직
                    }
                  },
                  child: const Text('다음'),
                ),

                const SizedBox(height: 16),

                // 이용약관
                Center(
                  child: Text(
                    '회원가입 시 이용약관 및 개인정보처리방침에 동의합니다',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
