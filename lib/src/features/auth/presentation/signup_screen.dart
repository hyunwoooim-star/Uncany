import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/utils/image_compressor.dart';
import 'package:uncany/src/core/services/app_logger.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';

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

  // 약관 동의
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _agreeToAll = false;

  // 파일 업로드 관련
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _isCompressing = false;
  Uint8List? _compressedBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  void _toggleAgreeAll(bool? value) {
    setState(() {
      _agreeToAll = value ?? false;
      _agreeToTerms = _agreeToAll;
      _agreeToPrivacy = _agreeToAll;
    });
  }

  void _updateAgreeAll() {
    setState(() {
      _agreeToAll = _agreeToTerms && _agreeToPrivacy;
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        setState(() {
          _selectedFile = file;
          _errorMessage = null;
          _compressedBytes = null;
        });

        // 이미지인 경우 압축 진행
        if (ImageCompressor.isImage(file.extension) && file.bytes != null) {
          await _compressImage(file.bytes!);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '파일 선택 중 오류가 발생했습니다';
      });
    }
  }

  Future<void> _compressImage(Uint8List bytes) async {
    setState(() {
      _isCompressing = true;
    });

    try {
      final compressed = await ImageCompressor.compressToWebP(bytes);
      if (compressed != null) {
        setState(() {
          _compressedBytes = compressed;
        });
      }
    } catch (e) {
      // 압축 실패해도 원본 사용
    } finally {
      setState(() {
        _isCompressing = false;
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '''제1조 (목적)
이 약관은 Uncany(이하 "서비스")의 이용조건 및 절차, 회원과 서비스 제공자의 권리와 의무에 관한 사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "회원"이란 서비스에 접속하여 본 약관에 따라 서비스를 이용하는 교사를 말합니다.
2. "서비스"란 학교 내 공유 공간 예약 및 관리 기능을 의미합니다.

제3조 (서비스 이용)
1. 서비스는 교사 인증이 완료된 회원에게만 제공됩니다.
2. 회원은 서비스를 교육 목적으로만 사용해야 합니다.

제4조 (회원의 의무)
1. 회원은 정확한 정보를 제공해야 합니다.
2. 회원은 타인의 권리를 침해하는 행위를 해서는 안 됩니다.

제5조 (서비스 제공자의 의무)
1. 서비스 제공자는 안정적인 서비스 제공을 위해 노력합니다.
2. 서비스 제공자는 회원의 개인정보를 보호합니다.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '''1. 개인정보의 수집 및 이용 목적
- 회원 가입 및 관리
- 서비스 제공 및 운영
- 교사 인증

2. 수집하는 개인정보 항목
- 필수: 이름, 이메일, 학교명
- 선택: 재직증명서 (인증 목적)

3. 개인정보의 보유 및 이용 기간
- 회원 탈퇴 시까지
- 재직증명서: 인증 완료 후 30일 이내 삭제

4. 개인정보의 제3자 제공
- 원칙적으로 제3자에게 제공하지 않습니다.

5. 개인정보의 파기
- 보유 기간 경과 시 지체 없이 파기합니다.
- 전자적 파일: 복구 불가능한 방법으로 삭제
- 종이 문서: 분쇄 또는 소각

6. 개인정보 보호책임자
- 문의: privacy@uncany.app

7. 정보주체의 권리
- 개인정보 열람, 정정, 삭제, 처리정지 요구 가능

※ 본 방침은 개인정보보호법에 따라 작성되었습니다.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // 약관 동의 확인
    if (!_agreeToTerms || !_agreeToPrivacy) {
      setState(() {
        _errorMessage = '필수 약관에 동의해주세요';
      });
      return;
    }

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

        final Uint8List? fileBytes;
        final String fileExtension;

        if (_compressedBytes != null) {
          fileBytes = _compressedBytes;
          fileExtension = 'jpg';
        } else {
          fileBytes = _selectedFile!.bytes;
          fileExtension = _selectedFile!.extension ?? 'bin';
        }

        final fileName = '$userId/${ImageCompressor.generateAnonymousFileName(fileExtension)}';

        if (fileBytes != null) {
          await supabase.storage
              .from('verification-documents')
              .uploadBinary(fileName, fileBytes);

          documentUrl = await supabase.storage
              .from('verification-documents')
              .createSignedUrl(fileName, 3600);
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

        final referralResponse = await supabase
            .from('referral_codes')
            .select()
            .eq('code', code)
            .eq('is_active', true)
            .maybeSingle();

        if (referralResponse != null) {
          await supabase
              .from('referral_codes')
              .update({'current_uses': referralResponse['current_uses'] + 1})
              .eq('id', referralResponse['id'] as Object);

          await supabase.from('referral_usage').insert({
            'referral_code_id': referralResponse['id'],
            'used_by': userId,
          });
        }
      }

      if (mounted) {
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
    } on AuthException catch (e, stack) {
      AppLogger.error('SignupScreen.handleSignup', e, stack, {
        'email': _emailController.text.trim(),
        'school': _schoolController.text.trim(),
        'useReferralCode': _useReferralCode,
      });
      setState(() {
        _errorMessage = ErrorMessages.fromAuthError(e.message);
      });
    } catch (e, stack) {
      AppLogger.error('SignupScreen.handleSignup', e, stack, {
        'email': _emailController.text.trim(),
        'school': _schoolController.text.trim(),
        'useReferralCode': _useReferralCode,
      });
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
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

  @override
  Widget build(BuildContext context) {
    final canSignup = _agreeToTerms && _agreeToPrivacy && !_isCompressing;

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

                // 인증 방법 선택
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
                        onTap: _useReferralCode || _isCompressing ? null : _pickFile,
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
                              if (_isCompressing)
                                const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
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
                                _isCompressing
                                    ? '파일 처리 중...'
                                    : (_selectedFile != null
                                        ? _selectedFile!.name
                                        : '파일을 선택하세요'),
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
                                'PDF, JPG, PNG (최대 5MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TossColors.textSub.withOpacity(_useReferralCode ? 0.5 : 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 개인정보 보호 안내
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: TossColors.textSub),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '파일은 암호화되어 안전하게 저장되며, 인증 완료 후 삭제됩니다',
                              style: TextStyle(
                                fontSize: 11,
                                color: TossColors.textSub,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 약관 동의
                TossCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 전체 동의
                      InkWell(
                        onTap: () => _toggleAgreeAll(!_agreeToAll),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreeToAll,
                              onChanged: _toggleAgreeAll,
                              activeColor: TossColors.primary,
                            ),
                            Expanded(
                              child: Text(
                                '전체 동의',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 16),

                      // 이용약관 동의
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                              _updateAgreeAll();
                            },
                            activeColor: TossColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToTerms = !_agreeToTerms;
                                });
                                _updateAgreeAll();
                              },
                              child: Text(
                                '[필수] 이용약관 동의',
                                style: TextStyle(
                                  color: TossColors.textMain,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _showTermsDialog,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 30),
                            ),
                            child: Text(
                              '보기',
                              style: TextStyle(
                                color: TossColors.textSub,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 개인정보처리방침 동의
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToPrivacy,
                            onChanged: (value) {
                              setState(() {
                                _agreeToPrivacy = value ?? false;
                              });
                              _updateAgreeAll();
                            },
                            activeColor: TossColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToPrivacy = !_agreeToPrivacy;
                                });
                                _updateAgreeAll();
                              },
                              child: Text(
                                '[필수] 개인정보처리방침 동의',
                                style: TextStyle(
                                  color: TossColors.textMain,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _showPrivacyDialog,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 30),
                            ),
                            child: Text(
                              '보기',
                              style: TextStyle(
                                color: TossColors.textSub,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
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

                const SizedBox(height: 24),

                // 회원가입 버튼
                TossButton(
                  onPressed: canSignup ? _handleSignup : null,
                  isLoading: _isLoading,
                  isDisabled: !canSignup,
                  child: Text(_isUploading ? '업로드 중...' : '회원가입'),
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
