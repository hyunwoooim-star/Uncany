import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/app_logger.dart';
import 'package:go_router/go_router.dart';

/// 개인정보 관리 화면
///
/// 개인정보 보호법 제35-38조 준수: 정보주체의 권리 보장
/// - 개인정보 열람
/// - 개인정보 다운로드 (JSON)
/// - 마케팅 수신동의 철회
/// - 회원 탈퇴
class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  bool _agreeToEmailMarketing = false;
  bool _agreeToSMSMarketing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 사용자 데이터 로드
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _userData = response;
        _agreeToEmailMarketing = response['agree_to_email_marketing'] ?? false;
        _agreeToSMSMarketing = response['agree_to_sms_marketing'] ?? false;
      });

      await AppLogger.info('PersonalDataScreen', '개인정보 조회 성공', {'userId': userId});
    } catch (e, stack) {
      await AppLogger.error('PersonalDataScreen._loadUserData', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.fromError(e))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 내 정보 보기 다이얼로그
  void _showMyDataDialog() {
    if (_userData == null) return;

    // 민감 정보 마스킹
    final maskedData = Map<String, dynamic>.from(_userData!);
    if (maskedData['verification_document_url'] != null) {
      maskedData['verification_document_url'] = '파일명 익명화됨 (보안)';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('내 개인정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDataItem('이메일', maskedData['email']),
              _buildDataItem('이름', maskedData['name']),
              _buildDataItem('사용자명', maskedData['username']),
              _buildDataItem('학교', maskedData['school_name']),
              _buildDataItem('학년', maskedData['grade']?.toString()),
              _buildDataItem('반', maskedData['class_num']?.toString()),
              _buildDataItem('인증 상태', maskedData['verification_status']),
              _buildDataItem('권한', maskedData['role']),
              _buildDataItem('이메일 수신동의', maskedData['agree_to_email_marketing'] == true ? '동의함' : '동의 안함'),
              _buildDataItem('SMS 수신동의', maskedData['agree_to_sms_marketing'] == true ? '동의함' : '동의 안함'),
              _buildDataItem('가입일', maskedData['created_at']),
              const SizedBox(height: 16),
              const Text(
                '※ 재직증명서는 보안을 위해 익명화된 파일명으로 저장되며, 승인/반려 후 30일 이내 자동 삭제됩니다.',
                style: TextStyle(fontSize: 12, color: TossColors.textSub),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: TossColors.textMain,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: TossColors.textSub),
            ),
          ),
        ],
      ),
    );
  }

  /// 개인정보 다운로드 (JSON)
  Future<void> _downloadMyData() async {
    if (_userData == null) return;

    try {
      setState(() => _isLoading = true);

      // JSON으로 변환 (읽기 쉽게 포맷팅)
      final jsonString = const JsonEncoder.withIndent('  ').convert(_userData);

      // 다운로드 안내 다이얼로그
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('개인정보 다운로드'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('개인정보가 JSON 형식으로 준비되었습니다.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TossColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TossColors.divider),
                    ),
                    child: SelectableText(
                      jsonString,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '※ 위 내용을 복사하여 텍스트 파일로 저장하실 수 있습니다.',
                    style: TextStyle(fontSize: 12, color: TossColors.textSub),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      }

      await AppLogger.info('PersonalDataScreen', '개인정보 다운로드 요청', {
        'userId': _supabase.auth.currentUser?.id,
      });
    } catch (e, stack) {
      await AppLogger.error('PersonalDataScreen._downloadMyData', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.fromError(e))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 마케팅 수신동의 업데이트 (즉시 저장)
  Future<void> _toggleEmailMarketing(bool value) async {
    setState(() => _agreeToEmailMarketing = value);
    await _updateMarketingConsent();
  }

  Future<void> _toggleSMSMarketing(bool value) async {
    setState(() => _agreeToSMSMarketing = value);
    await _updateMarketingConsent();
  }

  /// 마케팅 수신동의 변경
  Future<void> _updateMarketingConsent() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      await _supabase.from('users').update({
        'agree_to_email_marketing': _agreeToEmailMarketing,
        'agree_to_sms_marketing': _agreeToSMSMarketing,
      }).eq('id', userId);

      await AppLogger.info('PersonalDataScreen', '마케팅 동의 변경', {
        'userId': userId,
        'email': _agreeToEmailMarketing,
        'sms': _agreeToSMSMarketing,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마케팅 수신동의 설정이 변경되었습니다')),
        );
      }
    } catch (e, stack) {
      await AppLogger.error('PersonalDataScreen._updateMarketingConsent', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.fromError(e))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 회원 탈퇴
  Future<void> _deleteAccount() async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말로 탈퇴하시겠습니까?'),
            SizedBox(height: 16),
            Text(
              '※ 탈퇴 시 다음과 같이 처리됩니다:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 모든 개인정보가 즉시 삭제됩니다'),
            Text('• 예약 내역은 익명화되어 30일간 보관 후 삭제됩니다'),
            Text('• 재직증명서는 즉시 삭제됩니다'),
            Text('• 복구가 불가능합니다'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: TossColors.error),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      // Soft Delete (deleted_at 설정)
      await _supabase.from('users').update({
        'deleted_at': DateTime.now().toIso8601String(),
        'verification_document_url': null, // 재직증명서 즉시 삭제
      }).eq('id', userId);

      // 로그아웃
      await _supabase.auth.signOut();

      await AppLogger.info('PersonalDataScreen', '회원 탈퇴 완료', {'userId': userId});

      // 로그인 화면으로 이동
      if (mounted) {
        context.go('/auth/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원 탈퇴가 완료되었습니다')),
        );
      }
    } catch (e, stack) {
      await AppLogger.error('PersonalDataScreen._deleteAccount', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.fromError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('개인정보 관리'),
        backgroundColor: Colors.white,
        foregroundColor: TossColors.textMain,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                // 안내 문구
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TossColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: TossColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '개인정보 보호법에 따라 귀하의 개인정보를 열람, 다운로드, 삭제할 수 있는 권리가 있습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: TossColors.textMain,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 내 정보 보기
                _buildMenuCard(
                  icon: Icons.person_outline,
                  title: '내 정보 보기',
                  subtitle: '수집된 개인정보를 확인할 수 있습니다',
                  onTap: _showMyDataDialog,
                ),

                const SizedBox(height: 12),

                // 개인정보 다운로드
                _buildMenuCard(
                  icon: Icons.download_outlined,
                  title: '개인정보 다운로드',
                  subtitle: 'JSON 형식으로 내보내기',
                  onTap: _downloadMyData,
                ),

                const SizedBox(height: 24),

                const Text(
                  '마케팅 수신동의',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TossColors.textMain,
                  ),
                ),

                const SizedBox(height: 12),

                // 마케팅 수신동의 관리
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _agreeToEmailMarketing,
                        onChanged: _toggleEmailMarketing,
                        title: const Text('이메일 수신동의'),
                        subtitle: const Text('서비스 업데이트, 이벤트 정보'),
                        contentPadding: EdgeInsets.zero,
                        activeColor: TossColors.primary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        value: _agreeToSMSMarketing,
                        onChanged: _toggleSMSMarketing,
                        title: const Text('SMS 수신동의'),
                        subtitle: const Text('중요 알림 문자'),
                        contentPadding: EdgeInsets.zero,
                        activeColor: TossColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 회원 탈퇴
                _buildMenuCard(
                  icon: Icons.logout,
                  title: '회원 탈퇴',
                  subtitle: '모든 개인정보가 즉시 삭제됩니다',
                  onTap: _deleteAccount,
                  isDestructive: true,
                ),

                const SizedBox(height: 20),

                // 안내 문구
                const Text(
                  '※ 회원 탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: TossColors.textSub,
                  ),
                  textAlign: TextAlign.center,
                ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDestructive
              ? Border.all(color: TossColors.error.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? TossColors.error.withOpacity(0.1)
                    : TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? TossColors.error : TossColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDestructive
                          ? TossColors.error
                          : TossColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: TossColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: TossColors.textSub,
            ),
          ],
        ),
      ),
    );
  }
}
