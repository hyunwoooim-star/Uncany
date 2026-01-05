import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uncany/src/core/providers/supabase_provider.dart';
import '../repositories/school_repository.dart';

/// SchoolRepository Provider
final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SchoolRepository(supabase);
});
