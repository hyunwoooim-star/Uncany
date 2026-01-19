import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uncany/src/core/providers/supabase_provider.dart';
import '../repositories/classroom_repository.dart';
import '../repositories/classroom_comment_repository.dart';

/// ClassroomRepository Provider
final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ClassroomRepository(supabase);
});

/// ClassroomCommentRepository Provider
final classroomCommentRepositoryProvider = Provider<ClassroomCommentRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ClassroomCommentRepository(supabase);
});
