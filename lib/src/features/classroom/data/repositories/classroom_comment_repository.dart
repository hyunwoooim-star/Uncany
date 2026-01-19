import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/classroom_comment.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/core/services/app_logger.dart';

/// 교실 댓글 Repository
///
/// 교실별 공개 게시판/댓글 CRUD
class ClassroomCommentRepository {
  final SupabaseClient _supabase;

  ClassroomCommentRepository(this._supabase);

  /// 교실 댓글 목록 조회
  ///
  /// [classroomId]: 교실 ID
  /// [includeDeleted]: 삭제된 댓글 포함 여부
  /// [limit]: 조회 개수 제한
  Future<List<ClassroomComment>> getComments(
    String classroomId, {
    bool includeDeleted = false,
    int? limit,
  }) async {
    try {
      // 사용자 정보를 JOIN으로 가져옴
      var queryBuilder = _supabase.from('classroom_comments').select('''
        *,
        user:users!classroom_comments_user_id_fkey (
          name,
          grade,
          class_num
        ),
        resolver:users!classroom_comments_resolved_by_fkey (
          name
        )
      ''').eq('classroom_id', classroomId);

      if (!includeDeleted) {
        queryBuilder = queryBuilder.isFilter('deleted_at', null);
      }

      // 공지 → 미해결 문제 → 최신순
      var query = queryBuilder
          .order('comment_type', ascending: true) // notice가 먼저
          .order('is_resolved', ascending: true) // 미해결이 먼저
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List).map((json) {
        final data = Map<String, dynamic>.from(json as Map<String, dynamic>);

        // user 정보를 플랫하게 변환
        final user = data['user'] as Map<String, dynamic>?;
        if (user != null) {
          data['user_name'] = user['name'];
          data['user_grade'] = user['grade'];
          data['user_class_num'] = user['class_num'];
        }
        data.remove('user');

        // resolver 정보를 플랫하게 변환
        final resolver = data['resolver'] as Map<String, dynamic>?;
        if (resolver != null) {
          data['resolver_name'] = resolver['name'];
        }
        data.remove('resolver');

        return ClassroomComment.fromJson(data);
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 댓글 작성
  Future<ClassroomComment> createComment({
    required String classroomId,
    required String content,
    CommentType type = CommentType.general,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception(ErrorMessages.authRequired);
      }

      final data = {
        'classroom_id': classroomId,
        'user_id': userId,
        'content': content,
        'comment_type': type.code,
      };

      final response = await _supabase
          .from('classroom_comments')
          .insert(data)
          .select('''
            *,
            user:users!classroom_comments_user_id_fkey (
              name,
              grade,
              class_num
            )
          ''')
          .single();

      final result = Map<String, dynamic>.from(response);
      final user = result['user'] as Map<String, dynamic>?;
      if (user != null) {
        result['user_name'] = user['name'];
        result['user_grade'] = user['grade'];
        result['user_class_num'] = user['class_num'];
      }
      result.remove('user');

      return ClassroomComment.fromJson(result);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 댓글 수정
  Future<void> updateComment(String commentId, String content) async {
    try {
      await _supabase
          .from('classroom_comments')
          .update({'content': content})
          .eq('id', commentId);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 댓글 삭제 (Soft Delete)
  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.from('classroom_comments').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', commentId);
    } on PostgrestException catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 문제 해결 처리
  Future<void> resolveIssue(String commentId) async {
    try {
      final result = await _supabase.rpc(
        'resolve_classroom_issue',
        params: {'p_comment_id': commentId},
      );

      if (result != true) {
        throw Exception('문제 해결 처리에 실패했습니다');
      }
    } on PostgrestException catch (e) {
      // RPC 함수가 없으면 직접 업데이트 시도
      AppLogger.warning('ClassroomComment', 'resolve_classroom_issue RPC 실패: ${e.message}');
      await _resolveIssueDirect(commentId);
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 직접 문제 해결 처리 (RPC 실패 시 대체)
  Future<void> _resolveIssueDirect(String commentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('classroom_comments').update({
        'is_resolved': true,
        'resolved_at': DateTime.now().toIso8601String(),
        'resolved_by': userId,
      }).eq('id', commentId);
    } catch (e) {
      throw Exception(ErrorMessages.fromError(e));
    }
  }

  /// 미해결 문제 개수 조회
  Future<int> getUnresolvedCount(String classroomId) async {
    try {
      final result = await _supabase.rpc(
        'get_classroom_unresolved_count',
        params: {'p_classroom_id': classroomId},
      );
      return result as int? ?? 0;
    } on PostgrestException catch (e) {
      // RPC 함수가 없으면 직접 카운트
      AppLogger.warning('ClassroomComment', 'get_classroom_unresolved_count RPC 실패: ${e.message}');
      return await _getUnresolvedCountDirect(classroomId);
    } catch (e) {
      return 0;
    }
  }

  /// 직접 미해결 문제 카운트 (RPC 실패 시 대체)
  Future<int> _getUnresolvedCountDirect(String classroomId) async {
    try {
      final result = await _supabase
          .from('classroom_comments')
          .select('id')
          .eq('classroom_id', classroomId)
          .eq('comment_type', 'issue')
          .eq('is_resolved', false)
          .isFilter('deleted_at', null);

      return (result as List).length;
    } catch (e) {
      return 0;
    }
  }
}
