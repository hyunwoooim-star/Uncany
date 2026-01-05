import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/user_repository_provider.dart';
import '../domain/models/user.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'widgets/document_viewer.dart';

/// 관리자 승인 대기 목록 화면
class AdminApprovalsScreen extends ConsumerStatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  ConsumerState<AdminApprovalsScreen> createState() =>
      _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends ConsumerState<AdminApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<User> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(userRepositoryProvider);

      // 현재 탭에 따라 필터링
      VerificationStatus? status;
      if (_tabController.index == 1) {
        status = VerificationStatus.pending;
      } else if (_tabController.index == 2) {
        status = VerificationStatus.approved;
      } else if (_tabController.index == 3) {
        status = VerificationStatus.rejected;
      }

      final users = await repository.getUsers(status: status);

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _approveUser(User user) async {
    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.approveUser(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} 선생님을 승인했습니다'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
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

  Future<void> _rejectUser(User user) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 반려'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.name} 선생님의 가입을 반려하시겠습니까?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: '반려 사유 (필수)',
                hintText: '예: 재직증명서가 불명확합니다',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('반려 사유를 입력해주세요')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('반려'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(userRepositoryProvider);
        await repository.rejectUser(user.id, reasonController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name} 선생님의 가입을 반려했습니다'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadUsers();
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

    reasonController.dispose();
  }

  void _viewDocument(User user) {
    if (user.verificationDocumentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재직증명서가 없습니다')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => DocumentViewer(
        documentUrl: user.verificationDocumentUrl!,
        userName: user.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('사용자 승인 관리'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: TossColors.primary,
          unselectedLabelColor: TossColors.textSub,
          indicatorColor: TossColors.primary,
          tabs: [
            Tab(text: '전체 (${_tabController.index == 0 ? _users.length : ''})'),
            const Tab(text: '대기 중'),
            const Tab(text: '승인됨'),
            const Tab(text: '반려됨'),
          ],
        ),
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
                        onPressed: _loadUsers,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64,
                              color: TossColors.textSub.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyMessage(),
                            style: TextStyle(
                                color: TossColors.textSub, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _UserCard(
                            user: user,
                            onApprove: () => _approveUser(user),
                            onReject: () => _rejectUser(user),
                            onViewDocument: () => _viewDocument(user),
                          );
                        },
                      ),
                    ),
    );
  }

  String _getEmptyMessage() {
    switch (_tabController.index) {
      case 1:
        return '승인 대기 중인 사용자가 없습니다';
      case 2:
        return '승인된 사용자가 없습니다';
      case 3:
        return '반려된 사용자가 없습니다';
      default:
        return '등록된 사용자가 없습니다';
    }
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDocument;

  const _UserCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
    required this.onViewDocument,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 이름 + 상태 배지
          Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TossColors.textMain,
                  ),
                ),
              ),
              _StatusBadge(status: user.verificationStatus),
            ],
          ),

          const SizedBox(height: 8),

          // 정보
          _InfoRow(icon: Icons.school, text: user.schoolName),
          if (user.email != null)
            _InfoRow(icon: Icons.email_outlined, text: user.email!),
          if (user.educationOffice != null)
            _InfoRow(
                icon: Icons.account_balance, text: user.educationOffice!),

          const SizedBox(height: 8),

          // 가입일
          Text(
            '가입일: ${_formatDate(user.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: TossColors.textSub,
            ),
          ),

          // 반려 사유 (있을 경우)
          if (user.rejectedReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '반려 사유: ${user.rejectedReason}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 액션 버튼들
          Row(
            children: [
              // 재직증명서 보기
              if (user.verificationDocumentUrl != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDocument,
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('재직증명서'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TossColors.primary,
                    ),
                  ),
                ),

              // 대기 중일 때만 승인/반려 버튼 표시
              if (user.verificationStatus == VerificationStatus.pending) ...[
                if (user.verificationDocumentUrl != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: TossButton(
                    onPressed: onApprove,
                    backgroundColor: Colors.green,
                    child: const Text('승인'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('반려'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TossColors.textSub),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: TossColors.textSub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VerificationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case VerificationStatus.pending:
        color = Colors.orange;
        text = '대기 중';
        break;
      case VerificationStatus.approved:
        color = Colors.green;
        text = '승인됨';
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        text = '반려됨';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
