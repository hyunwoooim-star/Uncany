import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/referral_code.dart';
import '../data/providers/referral_code_repository_provider.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'widgets/create_referral_dialog.dart';

/// 내 추천인 코드 화면
class MyReferralCodesScreen extends ConsumerStatefulWidget {
  const MyReferralCodesScreen({super.key});

  @override
  ConsumerState<MyReferralCodesScreen> createState() =>
      _MyReferralCodesScreenState();
}

class _MyReferralCodesScreenState
    extends ConsumerState<MyReferralCodesScreen> {
  bool _isLoading = true;
  List<ReferralCode> _codes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(referralCodeRepositoryProvider);
      final codes = await repository.getMyReferralCodes();

      setState(() {
        _codes = codes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _createCode() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateReferralDialog(
        schoolName: currentUser.schoolName,
      ),
    );

    if (result != null && mounted) {
      try {
        final repository = ref.read(referralCodeRepositoryProvider);
        await repository.createReferralCode(
          schoolName: currentUser.schoolName,
          maxUses: result['maxUses'] as int,
          expiresInDays: result['expiresInDays'] as int,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('추천인 코드를 생성했습니다'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCodes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMessages.fromError(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleCodeStatus(ReferralCode code) async {
    try {
      final repository = ref.read(referralCodeRepositoryProvider);

      if (code.isActive) {
        await repository.deactivateCode(code.id);
      } else {
        await repository.reactivateCode(code.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              code.isActive ? '코드를 비활성화했습니다' : '코드를 활성화했습니다',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadCodes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.fromError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('코드가 복사되었습니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('내 추천인 코드'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      TossButton(
                        onPressed: _loadCodes,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _codes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.card_giftcard_outlined,
                              size: 80,
                              color: TossColors.textSub.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            '아직 생성한 추천인 코드가 없습니다',
                            style: TextStyle(
                              color: TossColors.textSub,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '추천인 코드를 생성하여\n같은 학교 동료를 초대하세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TossColors.textSub.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCodes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _codes.length,
                        itemBuilder: (context, index) {
                          final code = _codes[index];
                          return _CodeCard(
                            code: code,
                            onCopy: () => _copyCode(code.code),
                            onToggleStatus: () => _toggleCodeStatus(code),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCode,
        backgroundColor: TossColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('코드 생성'),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final ReferralCode code;
  final VoidCallback onCopy;
  final VoidCallback onToggleStatus;

  const _CodeCard({
    required this.code,
    required this.onCopy,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = code.expiresAt != null &&
        DateTime.now().isAfter(code.expiresAt!);
    final isAvailable = code.isAvailable;
    final daysLeft = code.expiresAt != null
        ? code.expiresAt!.difference(DateTime.now()).inDays
        : null;

    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 코드 + 복사 버튼
          Row(
            children: [
              Expanded(
                child: Text(
                  code.code,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: TossColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy),
                tooltip: '복사',
                color: TossColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 사용 현황
          Row(
            children: [
              _InfoChip(
                icon: Icons.people,
                label: '${code.currentUses} / ${code.maxUses} 사용',
                color: code.currentUses >= code.maxUses
                    ? Colors.red
                    : TossColors.textSub,
              ),
              const SizedBox(width: 8),
              if (daysLeft != null)
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: isExpired
                      ? '만료됨'
                      : daysLeft == 0
                          ? '오늘 만료'
                          : '$daysLeft일 남음',
                  color: isExpired || daysLeft <= 3
                      ? Colors.red
                      : TossColors.textSub,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 상태 배지
          Row(
            children: [
              Expanded(
                child: _StatusBadge(
                  isActive: code.isActive,
                  isAvailable: isAvailable,
                  isExpired: isExpired,
                ),
              ),
              // 활성화/비활성화 토글
              if (!isExpired)
                TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    code.isActive ? Icons.pause_circle : Icons.play_circle,
                    size: 16,
                  ),
                  label: Text(code.isActive ? '비활성화' : '활성화'),
                  style: TextButton.styleFrom(
                    foregroundColor: code.isActive
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isAvailable;
  final bool isExpired;

  const _StatusBadge({
    required this.isActive,
    required this.isAvailable,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    if (isExpired) {
      color = Colors.red;
      text = '만료됨';
      icon = Icons.event_busy;
    } else if (!isActive) {
      color = Colors.grey;
      text = '비활성';
      icon = Icons.pause_circle_outline;
    } else if (!isAvailable) {
      color = Colors.orange;
      text = '사용 불가';
      icon = Icons.warning;
    } else {
      color = Colors.green;
      text = '사용 가능';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
