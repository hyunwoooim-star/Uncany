import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/models/user.dart';
import '../../../auth/data/providers/auth_repository_provider.dart';
import '../../../auth/data/providers/user_repository_provider.dart';
import '../../data/providers/reservation_repository_provider.dart';
import '../../domain/models/reservation.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/core/utils/error_messages.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/toss_skeleton.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';

import 'widgets/home_header.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/admin_menu_section.dart';
import 'widgets/today_reservation_list.dart';

/// 홈 화면 (v0.4 리팩토링)
///
/// God Object 해체: 위젯 분리 + 조립 역할만 담당
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showAllReservations = false;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(authRepositoryProvider);
        await repository.signOut();
        if (context.mounted) {
          context.go('/auth/login');
        }
      } catch (e) {
        if (context.mounted) {
          TossSnackBar.error(context, message: ErrorMessages.fromError(e));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final pendingCountAsync = ref.watch(pendingCountProvider);
    final myReservationsAsync = ref.watch(todayReservationsProvider);
    final allReservationsAsync = ref.watch(todayAllReservationsProvider);

    return Scaffold(
      backgroundColor: TossColors.background,
      appBar: AppBar(
        title: const Text('Uncany'),
        backgroundColor: TossColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: '프로필',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: ResponsiveContent(
        child: currentUserAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('사용자 정보 없음'));
            }
            return _buildMainContent(
              context,
              user,
              pendingCountAsync,
              myReservationsAsync,
              allReservationsAsync,
            );
          },
          loading: () => _buildHomeSkeletonLoading(context),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('오류: ${ErrorMessages.fromError(error)}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentUserProvider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    User user,
    AsyncValue<int> pendingCountAsync,
    AsyncValue<List<Reservation>> myReservationsAsync,
    AsyncValue<List<Reservation>> allReservationsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayReservationsProvider);
        ref.invalidate(todayAllReservationsProvider);
        ref.invalidate(pendingCountProvider);
      },
      child: ResponsiveBuilder(
        builder: (context, deviceType) {
          final padding = responsivePadding(context);
          final spacing = responsiveSpacing(context);

          return ListView(
            padding: padding,
            children: [
              // 인사말 카드
              HomeHeader(user: user),

              SizedBox(height: spacing * 1.25),

              // 빠른 액션 버튼들
              const QuickActionGrid(),

              SizedBox(height: spacing * 1.5),

              // 나의 예약 섹션
              MyReservationsSection(
                reservationsAsync: myReservationsAsync,
              ),

              SizedBox(height: spacing * 1.5),

              // 전체 예약 현황 (접기/펼치기)
              AllReservationsSection(
                reservationsAsync: allReservationsAsync,
                isExpanded: _showAllReservations,
                onToggle: () {
                  setState(() {
                    _showAllReservations = !_showAllReservations;
                  });
                },
              ),

              // 관리자 메뉴
              if (user.role == UserRole.admin) ...[
                SizedBox(height: spacing * 1.5),
                AdminMenuSection(pendingCountAsync: pendingCountAsync),
              ],

              SizedBox(height: spacing * 2),
            ],
          );
        },
      ),
    );
  }

  /// 전체 홈 화면 스켈레톤 로딩
  Widget _buildHomeSkeletonLoading(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final padding = responsivePadding(context);
        final spacing = responsiveSpacing(context);

        return ListView(
          padding: padding,
          children: [
            // 인사말 카드 스켈레톤
            TossCard(
              padding: responsiveCardPadding(context),
              child: Row(
                children: [
                  TossSkeleton(
                    width: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                    height: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TossSkeleton(width: 80, height: 14, borderRadius: 4),
                        const SizedBox(height: 8),
                        TossSkeleton(width: 120, height: 20, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing * 1.25),

            // 빠른 액션 버튼 스켈레톤
            Row(
              children: [
                Expanded(child: TossSkeletonCard(height: 64)),
                SizedBox(width: spacing * 0.75),
                Expanded(child: TossSkeletonCard(height: 64)),
              ],
            ),

            SizedBox(height: spacing * 1.5),

            // 오늘의 예약 섹션 스켈레톤
            Row(
              children: [
                TossSkeleton(width: 80, height: 15, borderRadius: 4),
                const Spacer(),
                TossSkeleton(width: 100, height: 13, borderRadius: 4),
              ],
            ),
            SizedBox(height: spacing * 0.75),
            const ReservationsSkeletonLoading(),
          ],
        );
      },
    );
  }
}

// ============================================================================
// Providers
// ============================================================================

/// 승인 대기 중인 사용자 수 Provider
final pendingCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getPendingCount();
});

/// 오늘의 내 예약 목록 Provider
final todayReservationsProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getTodayMyReservations();
});

/// 오늘의 전체 예약 목록 Provider
final todayAllReservationsProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getTodayAllReservations();
});
