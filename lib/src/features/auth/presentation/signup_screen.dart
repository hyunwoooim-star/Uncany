import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/theme/toss_colors.dart';
import '../../../shared/widgets/toss_button.dart';
import '../../../shared/widgets/toss_card.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _useReferralCode = false;
  bool _isLoading = false;
  String? _errorMessage;

  // 파일 업로드 관련
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '파일 선택 중 오류가 발생했습니다: $e';
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // 추천인 코드가 없으면 증명서 필수
    if (!_useReferralCode && _selectedFile == null) {
      setState(() {
        _errorMessage = '재직증명서를 업로드해주세요';
      });
      return;
    }

    // 추천인 코드 사용 시 코드 입력 확인
    if (_useReferralCode && _referralCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = '추천인 코드를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Supabase Auth로 회원가입
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'name': _nameController.text.trim(),
          'school_name': _schoolController.text.trim(),
        },
      );

      if (authResponse.user == null) {
        throw Exception('회원가입에 실패했습니다');
      }

      final userId = authResponse.user!.id;
      String? documentUrl;

      // 2. 증명서 업로드 (추천인 코드 미사용 시)
      if (!_useReferralCode && _selectedFile != null) {
        setState(() {
          _isUploading = true;
        });

        final fileBytes = _selectedFile!.bytes;
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.${_selectedFile!.extension}';

        if (fileBytes != null) {
          await supabase.storage
              .from('verification-documents')
              .uploadBinary(fileName, fileBytes);

          documentUrl = supabase.storage
              .from('verification-documents')
              .getPublicUrl(fileName);
        }
      }

      // 3. users 테이블에 사용자 정보 저장
      await supabase.from('users').insert({
        'id': userId,
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'school_name': _schoolController.text.trim(),
        'verification_status': _useReferralCode ? 'approved' : 'pending',
        'verification_document_url': documentUrl,
      });

      // 4. 추천인 코드 사용 시 처리
      if (_useReferralCode) {
        final code = _referralCodeController.text.trim().toUpperCase();

        // 추천인 코드 확인
        final referralResponse = await supabase
            .from('referral_codes')
            .select()
            .eq('code', code)
            .eq('is_active', true)
            .maybeSingle();

        if (referralResponse != null) {
          // 사용 횟수 증가
          await supabase
              .from('referral_codes')
              .update({'current_uses': referralResponse['current_uses'] + 1})
              .eq('id', referralResponse['id']);

          // 사용 이력 기록
          await supabase.from('referral_usage').insert({
            'referral_code_id': referralResponse['id'],
            'used_by': userId,
          });
        }
      }

      if (mounted) {
        // 성공 메시지 표시 후 홈으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _useReferralCode
                  ? '회원가입이 완료되었습니다!'
                  : '회원가입이 완료되었습니다. 관리자 승인 후 이용 가능합니다.',
            ),
            backgroundColor: TossColors.primary,
          ),
        );

        context.go('/home');
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.message);
      });
    } catch (e) {
      setState(() {
        _errorMessage = '회원가입 중 오류가 발생했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(String message) {
    if (message.contains('already registered')) {
      return '이미 가입된 이메일입니다';
    }
    if (message.contains('invalid email')) {
      return '유효하지 않은 이메일 형식입니다';
    }
    if (message.contains('weak password')) {
      return '비밀번호가 너무 약합니다 (6자 이상)';
    }
    return message;
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
                    prefixIcon: Icon(Icons.person_outline),
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
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '학교명을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                    hintText: '6자 이상',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // 가입 방법 선택
                TossCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '인증 방법 선택',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // 추천인 코드 체크박스
                      CheckboxListTile(
                        value: _useReferralCode,
                        onChanged: (value) {
                          setState(() {
                            _useReferralCode = value ?? false;
                            _errorMessage = null;
                          });
                        },
                        title: const Text('추천인 코드로 가입'),
                        subtitle: const Text('같은 학교 선생님의 초대 코드'),
                        contentPadding: EdgeInsets.zero,
                        activeColor: TossColors.primary,
                      ),

                      if (_useReferralCode) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _referralCodeController,
                          decoration: const InputDecoration(
                            labelText: '추천인 코드',
                            hintText: 'SEOUL-ABC123',
                            prefixIcon: Icon(Icons.card_giftcard),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],

                      const Divider(height: 32),

                      // 재직증명서 업로드
                      Text(
                        '또는 재직증명서 업로드',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: _useReferralCode ? TossColors.textSub : TossColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: _useReferralCode ? null : _pickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _useReferralCode
                                  ? TossColors.disabled
                                  : (_selectedFile != null ? TossColors.primary : TossColors.textSub.withOpacity(0.3)),
                              width: _selectedFile != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _useReferralCode
                                ? TossColors.disabled.withOpacity(0.1)
                                : TossColors.surface,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFile != null
                                    ? Icons.check_circle
                                    : Icons.cloud_upload_outlined,
                                size: 40,
                                color: _useReferralCode
                                    ? TossColors.disabled
                                    : (_selectedFile != null ? TossColors.primary : TossColors.textSub),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFile != null
                                    ? _selectedFile!.name
                                    : '파일을 선택하세요',
                                style: TextStyle(
                                  color: _useReferralCode
                                      ? TossColors.disabled
                                      : (_selectedFile != null ? TossColors.primary : TossColors.textSub),
                                  fontWeight: _selectedFile != null ? FontWeight.w600 : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF, JPG, PNG 파일 지원',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TossColors.textSub.withOpacity(_useReferralCode ? 0.5 : 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

                const SizedBox(height: 32),

                // 회원가입 버튼
                TossButton(
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                  child: Text(_isUploading ? '업로드 중...' : '회원가입'),
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
