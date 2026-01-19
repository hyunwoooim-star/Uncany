import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom_comment.freezed.dart';
part 'classroom_comment.g.dart';

/// 교실 댓글 유형
enum CommentType {
  /// 일반 댓글 (질문, 의견)
  general,
  /// 문제 신고 (고장, 청소 불량 등)
  issue,
  /// 공지사항 (교실 등록자/관리자만)
  notice;

  String get code {
    switch (this) {
      case CommentType.general:
        return 'general';
      case CommentType.issue:
        return 'issue';
      case CommentType.notice:
        return 'notice';
    }
  }

  String get label {
    switch (this) {
      case CommentType.general:
        return '일반';
      case CommentType.issue:
        return '문제 신고';
      case CommentType.notice:
        return '공지';
    }
  }

  static CommentType fromCode(String? code) {
    switch (code) {
      case 'issue':
        return CommentType.issue;
      case 'notice':
        return CommentType.notice;
      default:
        return CommentType.general;
    }
  }
}

/// 교실 댓글 모델
///
/// 교실별 공개 게시판/댓글 기능
/// - 일반 댓글: 질문, 의견 공유
/// - 문제 신고: 고장, 청소 불량 등 (해결 표시 가능)
/// - 공지사항: 중요 안내 (교실 등록자/관리자)
@freezed
class ClassroomComment with _$ClassroomComment {
  const ClassroomComment._();

  const factory ClassroomComment({
    required String id,
    @JsonKey(name: 'classroom_id') required String classroomId,
    @JsonKey(name: 'user_id') required String userId,
    required String content,

    // 문제 해결 여부
    @JsonKey(name: 'is_resolved') @Default(false) bool isResolved,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'resolved_by') String? resolvedBy,

    // 댓글 유형
    @JsonKey(name: 'comment_type') @Default('general') String commentType,

    // 타임스탬프
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,

    // JOIN으로 가져오는 사용자 정보
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'user_grade') int? userGrade,
    @JsonKey(name: 'user_class_num') int? userClassNum,

    // 해결자 정보 (JOIN)
    @JsonKey(name: 'resolver_name') String? resolverName,
  }) = _ClassroomComment;

  factory ClassroomComment.fromJson(Map<String, dynamic> json) =>
      _$ClassroomCommentFromJson(json);

  /// 댓글 유형 enum
  CommentType get type => CommentType.fromCode(commentType);

  /// 작성자 표시명 (예: "3-2 김선생")
  String get userDisplayName {
    if (userName == null) return '알 수 없음';
    if (userGrade != null && userClassNum != null) {
      return '$userGrade-$userClassNum $userName';
    }
    if (userGrade != null) {
      return '$userGrade학년 $userName';
    }
    return userName!;
  }

  /// 문제 신고인지 확인
  bool get isIssue => commentType == 'issue';

  /// 공지사항인지 확인
  bool get isNotice => commentType == 'notice';

  /// 미해결 문제인지 확인
  bool get isUnresolvedIssue => isIssue && !isResolved;

  /// 상대 시간 표시 (예: "3분 전", "2시간 전")
  String get timeAgo {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';

    return '${createdAt!.month}월 ${createdAt!.day}일';
  }
}
