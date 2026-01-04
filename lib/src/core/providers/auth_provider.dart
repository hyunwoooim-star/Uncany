import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/models/user.dart' as app_user;
import 'supabase_provider.dart';

/// 현재 인증 세션 Provider
final authSessionProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session);
});

/// 현재 로그인한 사용자 Provider
final currentUserProvider = FutureProvider<app_user.User?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) return null;

  final supabase = ref.watch(supabaseProvider);

  // users 테이블에서 사용자 정보 조회
  final response = await supabase
      .from('users')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();

  if (response == null) return null;

  return app_user.User.fromJson(response);
});

/// 사용자가 로그인했는지 확인
final isAuthenticatedProvider = Provider<bool>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);
  return sessionAsync.maybeWhen(
    data: (session) => session != null,
    orElse: () => false,
  );
});
