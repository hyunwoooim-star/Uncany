import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/login_preferences_service.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';

/// 로그인 화면 (v0.3)
///
/// 아이디 + 비밀번호 로그인 방식
/// 아이디 저장 / 자동 로그인 기능 추가
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showLoginForm = false;
  String? _errorMessage;

  // 로그인 설정
  bool _rememberUsername = false;
  bool _autoLogin = false;
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 저장된 설정 로드
  Future<void> _loadPreferences() async {
    try {
      final rememberUsername = await LoginPreferencesService.getRememberUsername();
      final savedUsername = await LoginPreferencesService.getSavedUsername();
      final autoLogin = await LoginPreferencesService.getAutoLogin();

      if (mounted) {
        setState(() {
          _rememberUsername = rememberUsername;
          _autoLogin = autoLogin;
          _isLoadingPreferences = false;

          if (savedUsername != null && savedUsername.isNotEmpty) {
            _usernameController.text = savedUsername;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPreferences = false;
        });
      }
    }
  }

  /// 설정 저장
  Future<void> _savePreferences() async {
    await LoginPreferencesService.setRememberUsername(_rememberUsername);
    await LoginPreferencesService.setAutoLogin(_autoLogin);

    if (_rememberUsername) {
      await LoginPreferencesService.saveUsername(_usernameController.text.trim());
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final username = _usernameController.text.trim();

      // 입력값이 이메일 형식인지 확인
      String? email;

      if (username.contains('@')) {
        // 이메일로 직접 입력된 경우
        email = username;
      } else {
        // 아이디로 입력된 경우 → 이메일 조회
        final userResponse = await supabase
            .from('users')
            .select('email')
            .eq('username', username)
            .maybeSingle();

        if (userResponse == null) {
          setState(() {
            _errorMessage = '존재하지 않는 아이디입니다';
            _isLoading = false;
          });
          return;
        }

        email = userResponse['email'] as String?;
      }

      if (email == null || email.isEmpty) {
        setState(() {
          _errorMessage = '계정 정보를 찾을 수 없습니다';
          _isLoading = false;
        });
        return;
      }

      // Supabase Auth로 로그인
      await supabase.auth.signInWithPassword(
        email: email,
        password: _passwordController.text,
      );

      // 로그인 성공 시 설정 저장
      await _savePreferences();

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
          '학교 교실 예약을 쉽고 편하게',
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
          child: const Text('로그인'),
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
            '아이디와 비밀번호를 입력해주세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          // 아이디 (또는 이메일)
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '아이디',
              hintText: '아이디 또는 이메일',
              prefixIcon: Icon(Icons.person_outline),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '아이디를 입력해주세요';
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

          const SizedBox(height: 12),

          // 아이디 저장 / 자동 로그인 체크박스
          if (!_isLoadingPreferences) ...[
            Row(
              children: [
                // 아이디 저장
                InkWell(
                  onTap: () {
                    setState(() {
                      _rememberUsername = !_rememberUsername;
                      // 아이디 저장 해제 시 자동 로그인도 해제
                      if (!_rememberUsername) {
                        _autoLogin = false;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberUsername,
                          onChanged: (value) {
                            setState(() {
                              _rememberUsername = value ?? false;
                              if (!_rememberUsername) {
                                _autoLogin = false;
                              }
                            });
                          },
                          activeColor: TossColors.primary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '아이디 저장',
                        style: TextStyle(
                          fontSize: 14,
                          color: TossColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 자동 로그인
                InkWell(
                  onTap: () {
                    setState(() {
                      _autoLogin = !_autoLogin;
                      // 자동 로그인 활성화 시 아이디 저장도 활성화
                      if (_autoLogin) {
                        _rememberUsername = true;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _autoLogin,
                          onChanged: (value) {
                            setState(() {
                              _autoLogin = value ?? false;
                              if (_autoLogin) {
                                _rememberUsername = true;
                              }
                            });
                          },
                          activeColor: TossColors.primary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '자동 로그인',
                        style: TextStyle(
                          fontSize: 14,
                          color: TossColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

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

          // 아이디/비밀번호 찾기
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.push('/auth/find-username'),
                child: Text(
                  '아이디 찾기',
                  style: TextStyle(color: TossColors.textSub),
                ),
              ),
              Text(
                '|',
                style: TextStyle(color: TossColors.textSub.withOpacity(0.5)),
              ),
              TextButton(
                onPressed: () => context.push('/auth/reset-password'),
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(color: TossColors.textSub),
                ),
              ),
            ],
          ),

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
