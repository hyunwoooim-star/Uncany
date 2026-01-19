import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/providers/user_repository_provider.dart';
import '../domain/models/user.dart' as app_user;
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_button.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';

/// 관리자 사용자 관리 화면
///
/// 모든 사용자 목록 조회, 역할 변경, 계정 비활성화
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<app_user.User> _allUsers = [];
  List<app_user.User> _filteredUsers = [];
  String? _errorMessage;

  // 통계
  int _totalCount = 0;
  int _approvedCount = 0;
  int _pendingCount = 0;
  int _rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(userRepositoryProvider);
      final users = await repository.getUsers(); // 전체 조회

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;

        // 통계 계산
        _totalCount = users.length;
        _approvedCount = users
            .where((u) => u.verificationStatus == app_user.VerificationStatus.approved)
            .length;
        _pendingCount = users
            .where((u) => u.verificationStatus == app_user.VerificationStatus.pending)
            .length;
        _rejectedCount = users
            .where((u) => u.verificationStatus == app_user.VerificationStatus.rejected)
            .length;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.fromError(e);
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.schoolName.toLowerCase().contains(query) ||
              (user.email?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  /// 임시 비밀번호 생성 (8자리 영숫자)
  String _generateTempPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// 비밀번호 초기화
  Future<void> _resetPassword(app_user.User user) async {
    final tempPassword = _generateTempPassword();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 초기화'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.name} 선생님의 비밀번호를 초기화하시겠습니까?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TossColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '임시 비밀번호:',
                    style: TextStyle(fontSize: 12, color: TossColors.textSub),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    tempPassword,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: TossColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ 이 비밀번호를 사용자에게 전달해 주세요.',
              style: TextStyle(fontSize: 12, color: TossColors.textSub),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.rpc('admin_reset_user_password', params: {
          'target_user_id': user.id,
          'new_password': tempPassword,
        });

        if (mounted) {
          // 비밀번호 복사 다이얼로그
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('비밀번호 초기화 완료'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user.name} 선생님의 비밀번호가 초기화되었습니다.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            tempPassword,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: tempPassword));
                            TossSnackBar.success(context, message: '비밀번호가 복사되었습니다');
                          },
                          tooltip: '복사',
                        ),
                      ],
                    ),
                  ),
                ],
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
      } catch (e) {
        if (mounted) {
          TossSnackBar.error(context, message: ErrorMessages.fromError(e));
        }
      }
    }
  }

  Future<void> _changeUserRole(app_user.User user) async {
    final newRole = user.role == app_user.UserRole.teacher
        ? app_user.UserRole.admin
        : app_user.UserRole.teacher;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('역할 변경'),
        content: Text(
          '${user.name} 선생님을 ${newRole == app_user.UserRole.admin ? '관리자' : '일반 교사'}로 변경하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('변경'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(userRepositoryProvider);
        await repository.updateUserRole(user.id, newRole);

        if (mounted) {
          TossSnackBar.success(context, message: '역할을 ${newRole.name}으로 변경했습니다');
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          TossSnackBar.error(context, message: ErrorMessages.fromError(e));
        }
      }
    }
  }

  Future<void> _deleteUser(app_user.User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 비활성화'),
        content: Text(
          '${user.name} 선생님의 계정을 비활성화하시겠습니까?\n\n'
          '비활성화된 계정은 로그인할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('비활성화'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(userRepositoryProvider);
        await repository.deleteUser(user.id);

        if (mounted) {
          TossSnackBar.warning(context, message: '계정을 비활성화했습니다');
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          TossSnackBar.error(context, message: ErrorMessages.fromError(e));
        }
      }
    }
  }

  Future<void> _hardDeleteUser(app_user.User user) async {
    // 첫 번째 확인
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 완전 삭제'),
        content: Text(
          '${user.name} 선생님의 계정을 완전히 삭제하시겠습니까?\n\n'
          '⚠️ 이 작업은 되돌릴 수 없습니다.\n'
          '모든 예약 기록과 데이터가 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('다음'),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !mounted) return;

    // 두 번째 확인 (더블 체크)
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정말로 삭제하시겠습니까?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '삭제할 계정: ${user.name} 선생님',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('이메일: ${user.email ?? "없음"}'),
            Text('학교: ${user.schoolName}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 작업은 복구할 수 없습니다!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('완전 삭제'),
          ),
        ],
      ),
    );

    if (secondConfirm == true && mounted) {
      try {
        final repository = ref.read(userRepositoryProvider);
        await repository.hardDeleteUser(user.id);

        if (mounted) {
          TossSnackBar.warning(context, message: '계정을 완전히 삭제했습니다');
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          TossSnackBar.error(context, message: ErrorMessages.fromError(e));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('사용자 관리'),
        backgroundColor: TossColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 통계 카드
          Container(
            color: TossColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _StatCard(label: '전체', count: _totalCount)),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _StatCard(label: '승인됨', count: _approvedCount, color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatCard(
                        label: '대기 중', count: _pendingCount, color: Colors.orange)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatCard(
                        label: '반려됨', count: _rejectedCount, color: Colors.red)),
              ],
            ),
          ),

          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '이름, 학교, 이메일로 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: TossColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 사용자 목록
          Expanded(
            child: _isLoading
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
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline,
                                    size: 64,
                                    color: TossColors.textSub.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? '등록된 사용자가 없습니다'
                                      : '검색 결과가 없습니다',
                                  style: TextStyle(
                                      color: TossColors.textSub,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return _UserCard(
                                  user: user,
                                  onChangeRole: () => _changeUserRole(user),
                                  onResetPassword: () => _resetPassword(user),
                                  onDelete: () => _deleteUser(user),
                                  onHardDelete: () => _hardDeleteUser(user),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: (color ?? TossColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color ?? TossColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (color ?? TossColors.primary).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final app_user.User user;
  final VoidCallback onChangeRole;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;
  final VoidCallback onHardDelete;

  const _UserCard({
    required this.user,
    required this.onChangeRole,
    required this.onResetPassword,
    required this.onDelete,
    required this.onHardDelete,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 + 역할 배지
          Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TossColors.textMain,
                  ),
                ),
              ),
              _RoleBadge(role: user.role),
              const SizedBox(width: 8),
              _StatusBadge(status: user.verificationStatus),
            ],
          ),

          const SizedBox(height: 8),

          // 정보
          Text(
            user.schoolName,
            style: const TextStyle(
              fontSize: 14,
              color: TossColors.textSub,
            ),
          ),
          if (user.email != null)
            Text(
              user.email!,
              style: const TextStyle(
                fontSize: 12,
                color: TossColors.textSub,
              ),
            ),

          const SizedBox(height: 12),

          // 액션 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChangeRole,
                  icon: Icon(
                    user.role == app_user.UserRole.admin
                        ? Icons.person
                        : Icons.admin_panel_settings,
                    size: 16,
                  ),
                  label: Text(
                    user.role == app_user.UserRole.admin
                        ? '일반 교사로 변경'
                        : '관리자로 변경',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TossColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onResetPassword,
                icon: const Icon(Icons.lock_reset),
                color: TossColors.primary,
                tooltip: '비밀번호 초기화',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.block),
                color: Colors.orange,
                tooltip: '계정 비활성화',
              ),
              IconButton(
                onPressed: onHardDelete,
                icon: const Icon(Icons.delete_forever),
                color: Colors.red,
                tooltip: '완전 삭제',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final app_user.UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == app_user.UserRole.admin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? TossColors.primary.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 12,
            color: isAdmin ? TossColors.primary : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? '관리자' : '교사',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAdmin ? TossColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final app_user.VerificationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case app_user.VerificationStatus.pending:
        color = Colors.orange;
        text = '대기 중';
        break;
      case app_user.VerificationStatus.approved:
        color = Colors.green;
        text = '승인됨';
        break;
      case app_user.VerificationStatus.rejected:
        color = Colors.red;
        text = '반려됨';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
