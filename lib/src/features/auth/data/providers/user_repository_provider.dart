import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uncany/src/core/providers/supabase_provider.dart';
import '../repositories/user_repository.dart';

/// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return UserRepository(supabase);
});
