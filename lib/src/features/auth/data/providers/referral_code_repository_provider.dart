import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uncany/src/core/providers/supabase_provider.dart';
import '../repositories/referral_code_repository.dart';

/// ReferralCodeRepository Provider
final referralCodeRepositoryProvider = Provider<ReferralCodeRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ReferralCodeRepository(supabase);
});
