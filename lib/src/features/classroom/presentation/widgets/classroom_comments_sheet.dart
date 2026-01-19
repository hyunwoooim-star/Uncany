import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/classroom_comment.dart';
import '../../data/providers/classroom_repository_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';
import 'package:uncany/src/core/utils/error_messages.dart';

/// 교실 댓글 바텀 시트
///
/// 교실별 공개 게시판/댓글 기능
/// - 일반 댓글
/// - 문제 신고 (해결 표시 가능)
/// - 공지사항
class ClassroomCommentsSheet extends ConsumerStatefulWidget {
  final String classroomId;
  final String classroomName;
  final String? classroomCreatorId;

  const ClassroomCommentsSheet({
    super.key,
    required this.classroomId,
    required this.classroomName,
    this.classroomCreatorId,
  });

  @override
  ConsumerState<ClassroomCommentsSheet> createState() =>
      _ClassroomCommentsSheetState();
}

class _ClassroomCommentsSheetState extends ConsumerState<ClassroomCommentsSheet> {
  List<ClassroomComment> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;

  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  CommentType _selectedType = CommentType.general;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  bool get _isCreatorOrAdmin {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return false;
    return currentUserId == widget.classroomCreatorId;
    // TODO: 관리자 체크 추가
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(classroomCommentRepositoryProvider);
      final comments = await repo.getComments(widget.classroomId);

      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorMessages.fromError(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(classroomCommentRepositoryProvider);
      await repo.createComment(
        classroomId: widget.classroomId,
        content: content,
        type: _selectedType,
      );

      _commentController.clear();
      setState(() {
        _selectedType = CommentType.general;
        _isSubmitting = false;
      });

      await _loadComments();

      if (mounted) {
        TossSnackBar.success(
          context,
          message: _selectedType == CommentType.issue
              ? '문제가 신고되었습니다'
              : '댓글이 등록되었습니다',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        TossSnackBar.error(context, message: ErrorMessages.fromError(e));
      }
    }
  }

  Future<void> _deleteComment(ClassroomComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: TossColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(classroomCommentRepositoryProvider);
      await repo.deleteComment(comment.id);
      await _loadComments();

      if (mounted) {
        TossSnackBar.success(context, message: '댓글이 삭제되었습니다');
      }
    } catch (e) {
      if (mounted) {
        TossSnackBar.error(context, message: ErrorMessages.fromError(e));
      }
    }
  }

  Future<void> _resolveIssue(ClassroomComment comment) async {
    try {
      final repo = ref.read(classroomCommentRepositoryProvider);
      await repo.resolveIssue(comment.id);
      await _loadComments();

      if (mounted) {
        TossSnackBar.success(context, message: '문제가 해결 처리되었습니다');
      }
    } catch (e) {
      if (mounted) {
        TossSnackBar.error(context, message: ErrorMessages.fromError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TossColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 핸들바
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TossColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: TossColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.classroomName} 게시판',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TossColors.textMain,
                            ),
                          ),
                          Text(
                            '문의사항, 문제 신고 등을 남겨주세요',
                            style: TextStyle(
                              fontSize: 13,
                              color: TossColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 댓글 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _comments.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _comments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _CommentCard(
                                    comment: _comments[index],
                                    currentUserId: _currentUserId,
                                    isCreatorOrAdmin: _isCreatorOrAdmin,
                                    onDelete: () =>
                                        _deleteComment(_comments[index]),
                                    onResolve: () =>
                                        _resolveIssue(_comments[index]),
                                  );
                                },
                              ),
              ),

              // 입력창
              _buildInputArea(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: TossColors.textSub.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 댓글이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: TossColors.textSub,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 댓글을 남겨보세요',
            style: TextStyle(
              fontSize: 14,
              color: TossColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: TossColors.error),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '오류가 발생했습니다',
            style: TextStyle(color: TossColors.textSub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadComments,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: TossColors.surface,
        border: Border(
          top: BorderSide(color: TossColors.divider),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 댓글 유형 선택
          Row(
            children: [
              _TypeChip(
                label: '일반',
                icon: Icons.chat_bubble_outline,
                isSelected: _selectedType == CommentType.general,
                onTap: () => setState(() => _selectedType = CommentType.general),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '문제 신고',
                icon: Icons.report_problem_outlined,
                isSelected: _selectedType == CommentType.issue,
                color: Colors.orange,
                onTap: () => setState(() => _selectedType = CommentType.issue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 입력 필드
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _selectedType == CommentType.issue
                        ? '어떤 문제가 있나요? (예: 에어컨 고장)'
                        : '댓글을 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: TossColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: TossColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 유형 선택 칩
class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? TossColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.1) : TossColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : TossColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? chipColor : TossColors.textSub,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? chipColor : TossColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 댓글 카드
class _CommentCard extends StatelessWidget {
  final ClassroomComment comment;
  final String? currentUserId;
  final bool isCreatorOrAdmin;
  final VoidCallback onDelete;
  final VoidCallback onResolve;

  const _CommentCard({
    required this.comment,
    required this.currentUserId,
    required this.isCreatorOrAdmin,
    required this.onDelete,
    required this.onResolve,
  });

  bool get _isMyComment => comment.userId == currentUserId;
  bool get _canDelete => _isMyComment || isCreatorOrAdmin;
  bool get _canResolve =>
      comment.isUnresolvedIssue && isCreatorOrAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: comment.isIssue || comment.isNotice ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              // 유형 배지
              if (comment.isIssue || comment.isNotice)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(),
                        size: 12,
                        color: _getTypeColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment.type.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(),
                        ),
                      ),
                    ],
                  ),
                ),

              // 해결됨 배지
              if (comment.isResolved)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '해결됨',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              // 작성자
              Expanded(
                child: Text(
                  comment.userDisplayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isMyComment ? TossColors.primary : TossColors.textMain,
                  ),
                ),
              ),

              // 시간
              Text(
                comment.timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: TossColors.textSub,
                ),
              ),

              // 메뉴
              if (_canDelete || _canResolve)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                    if (value == 'resolve') onResolve();
                  },
                  itemBuilder: (_) => [
                    if (_canResolve)
                      const PopupMenuItem(
                        value: 'resolve',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text('해결 완료'),
                          ],
                        ),
                      ),
                    if (_canDelete)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: TossColors.error),
                            const SizedBox(width: 8),
                            Text(
                              '삭제',
                              style: TextStyle(color: TossColors.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 10),

          // 내용
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: TossColors.textMain,
              height: 1.4,
              decoration: comment.isResolved
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: TossColors.textSub,
            ),
          ),

          // 해결자 정보
          if (comment.isResolved && comment.resolverName != null) ...[
            const SizedBox(height: 8),
            Text(
              '✓ ${comment.resolverName} 선생님이 해결함',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (comment.isResolved) return Colors.green.withOpacity(0.03);
    if (comment.isIssue) return Colors.orange.withOpacity(0.05);
    if (comment.isNotice) return TossColors.primary.withOpacity(0.05);
    return TossColors.surface;
  }

  Color _getBorderColor() {
    if (comment.isResolved) return Colors.green.withOpacity(0.3);
    if (comment.isIssue) return Colors.orange.withOpacity(0.3);
    if (comment.isNotice) return TossColors.primary.withOpacity(0.3);
    return TossColors.divider;
  }

  Color _getTypeColor() {
    if (comment.isIssue) return Colors.orange.shade700;
    if (comment.isNotice) return TossColors.primary;
    return TossColors.textSub;
  }

  IconData _getTypeIcon() {
    if (comment.isIssue) return Icons.report_problem;
    if (comment.isNotice) return Icons.campaign;
    return Icons.chat_bubble;
  }
}

/// 교실 댓글 시트 표시 함수
Future<void> showClassroomCommentsSheet(
  BuildContext context, {
  required String classroomId,
  required String classroomName,
  String? classroomCreatorId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ClassroomCommentsSheet(
      classroomId: classroomId,
      classroomName: classroomName,
      classroomCreatorId: classroomCreatorId,
    ),
  );
}
