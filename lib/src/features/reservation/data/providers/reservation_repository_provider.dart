import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uncany/src/core/providers/supabase_provider.dart';
import '../repositories/reservation_repository.dart';

/// ReservationRepository Provider
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ReservationRepository(supabase);
});
