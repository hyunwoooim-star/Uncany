import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../repositories/auth_repository.dart';

/// AuthRepository Provider
///
/// Supabase 클라이언트를 주입받아 AuthRepository 인스턴스 생성
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthRepository(supabase);
});
