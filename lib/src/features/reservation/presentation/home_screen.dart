import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/domain/models/user.dart';
import '../../auth/data/providers/auth_repository_provider.dart';
import '../../auth/data/providers/user_repository_provider.dart';
import '../data/providers/reservation_repository_provider.dart';
import '../domain/models/reservation.dart';
import 'package:uncany/src/core/providers/auth_provider.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';

/// 홈 화면 (v0.2)
///
/// 오늘의 예약 요약, 빠른 메뉴
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그아웃 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final pendingCountAsync = ref.watch(_pendingCountProvider);
    final todayReservationsAsync = ref.watch(_todayReservationsProvider);

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
              ref,
              user,
              pendingCountAsync,
              todayReservationsAsync,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('오류: $error'),
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
    WidgetRef ref,
    User user,
    AsyncValue<int> pendingCountAsync,
    AsyncValue<List<Reservation>> todayReservationsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_todayReservationsProvider);
        ref.invalidate(_pendingCountProvider);
      },
      child: ResponsiveBuilder(
        builder: (context, deviceType) {
          final padding = responsivePadding(context);
          final spacing = responsiveSpacing(context);

          return ListView(
            padding: padding,
            children: [
              // 인사말 카드
              _buildGreetingCard(context, user),

              SizedBox(height: spacing * 1.25),

              // 빠른 액션 버튼들 (2열 그리드)
              Row(
                children: [
                  Expanded(
                    child: _CompactActionButton(
                      icon: Icons.calendar_today,
                      label: '교실 예약',
                      color: TossColors.primary,
                      onTap: () => context.push('/classrooms'),
                    ),
                  ),
                  SizedBox(width: spacing * 0.75),
                  Expanded(
                    child: _CompactActionButton(
                      icon: Icons.list_alt,
                      label: '내 예약',
                      color: TossColors.success,
                      onTap: () => context.push('/reservations/my'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing * 1.5),

              // 오늘의 예약 섹션
              _buildTodayReservationsSection(
                context,
                todayReservationsAsync,
              ),

              // 관리자 메뉴
              if (user.role == UserRole.admin) ...[
                SizedBox(height: spacing * 1.5),
                _buildSectionTitle('관리자'),
                SizedBox(height: spacing * 0.75),
                Row(
                  children: [
                    Expanded(
                      child: _CompactActionButton(
                        icon: Icons.how_to_reg,
                        label: '사용자 승인',
                        color: Colors.purple,
                        onTap: () => context.push('/admin/approvals'),
                        badge: pendingCountAsync.when(
                          data: (count) => count > 0 ? count : null,
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing * 0.75),
                    Expanded(
                      child: _CompactActionButton(
                        icon: Icons.people,
                        label: '사용자 관리',
                        color: Colors.indigo,
                        onTap: () => context.push('/admin/users'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing * 0.75),
                _CompactActionButton(
                  icon: Icons.meeting_room,
                  label: '교실 관리',
                  color: Colors.teal,
                  onTap: () => context.push('/admin/classrooms'),
                ),
              ],

              SizedBox(height: spacing * 2),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, User user) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                height: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                decoration: BoxDecoration(
                  color: TossColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: TossColors.primary,
                  size: responsiveIconSize(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: responsiveFontSize(context, base: 14),
                        color: TossColors.textSub,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.name} 선생님',
                      style: TextStyle(
                        fontSize: responsiveFontSize(context, base: 20),
                        fontWeight: FontWeight.bold,
                        color: TossColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user.gradeClassDisplay != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TossColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.gradeClassDisplay!,
                style: TextStyle(
                  fontSize: responsiveFontSize(context, base: 13),
                  color: TossColors.textSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 6) return '새벽이에요';
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후예요';
    return '좋은 저녁이에요';
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: responsiveFontSize(context, base: 15),
            fontWeight: FontWeight.w600,
            color: TossColors.textSub,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayReservationsSection(
    BuildContext context,
    AsyncValue<List<Reservation>> todayReservationsAsync,
  ) {
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('오늘의 예약'),
            const Spacer(),
            Text(
              dateFormat.format(today),
              style: TextStyle(
                fontSize: responsiveFontSize(context, base: 13),
                color: TossColors.textSub,
              ),
            ),
          ],
        ),
        SizedBox(height: responsiveSpacing(context, base: 12)),
        todayReservationsAsync.when(
          data: (reservations) {
            if (reservations.isEmpty) {
              return _buildEmptyReservations(context);
            }
            return _buildReservationsList(context, reservations);
          },
          loading: () => TossCard(
            padding: responsiveCardPadding(context),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '예약 정보 로딩 중...',
                    style: TextStyle(
                      fontSize: responsiveFontSize(context, base: 14),
                      color: TossColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (_, __) => TossCard(
            padding: responsiveCardPadding(context),
            child: Center(
              child: Text(
                '예약 정보를 불러올 수 없습니다',
                style: TextStyle(
                  fontSize: responsiveFontSize(context, base: 14),
                  color: TossColors.textSub,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReservations(BuildContext context) {
    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: responsiveIconSize(context, base: 48),
            color: TossColors.textSub.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            '오늘 예정된 예약이 없습니다',
            style: TextStyle(
              fontSize: responsiveFontSize(context, base: 15),
              color: TossColors.textSub,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push('/classrooms'),
            icon: const Icon(Icons.add),
            label: const Text('교실 예약하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TossColors.primary,
              side: BorderSide(color: TossColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(
    BuildContext context,
    List<Reservation> reservations,
  ) {
    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        children: [
          // 예약 개수 요약
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: TossColors.primary,
                  size: responsiveIconSize(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '오늘 ${reservations.length}건의 예약이 있습니다',
                    style: TextStyle(
                      fontSize: responsiveFontSize(context, base: 14),
                      fontWeight: FontWeight.w600,
                      color: TossColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/reservations/my'),
                  child: Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: responsiveFontSize(context, base: 13),
                      color: TossColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 예약 목록
          ...reservations.map((r) => _TodayReservationItem(reservation: r)),
        ],
      ),
    );
  }
}

/// 오늘의 예약 아이템 위젯
class _TodayReservationItem extends StatelessWidget {
  final Reservation reservation;

  const _TodayReservationItem({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 교시 표시
          Container(
            width: responsiveValue(context, mobile: 64.0, desktop: 72.0),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  reservation.periodsDisplay ?? '-',
                  style: TextStyle(
                    fontSize: responsiveFontSize(context, base: 13),
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 교실 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getRoomTypeIcon(reservation.classroomRoomType),
                      size: responsiveIconSize(context, base: 16),
                      color: TossColors.textSub,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reservation.classroomName ?? '교실',
                        style: TextStyle(
                          fontSize: responsiveFontSize(context, base: 14),
                          fontWeight: FontWeight.w600,
                          color: TossColors.textMain,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (reservation.description != null &&
                    reservation.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    reservation.description!,
                    style: TextStyle(
                      fontSize: responsiveFontSize(context, base: 12),
                      color: TossColors.textSub,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 상태 표시
          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (reservation.isOngoing) return Colors.green;
    if (reservation.isUpcoming) return TossColors.primary;
    return Colors.grey;
  }

  Widget _buildStatusBadge(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    if (reservation.isOngoing) {
      text = '진행중';
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (reservation.isUpcoming) {
      text = '예정';
      bgColor = TossColors.primary.withOpacity(0.1);
      textColor = TossColors.primary;
    } else {
      text = '완료';
      bgColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: responsiveFontSize(context, base: 11),
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  IconData _getRoomTypeIcon(String? roomType) {
    switch (roomType) {
      case 'computer':
        return Icons.computer;
      case 'music':
        return Icons.music_note;
      case 'science':
        return Icons.science;
      case 'art':
        return Icons.palette;
      case 'library':
        return Icons.menu_book;
      case 'gym':
        return Icons.sports_basketball;
      case 'auditorium':
        return Icons.theater_comedy;
      case 'special':
        return Icons.star;
      default:
        return Icons.meeting_room;
    }
  }
}

// 승인 대기 중인 사용자 수 Provider
final _pendingCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getPendingCount();
});

// 오늘의 내 예약 목록 Provider
final _todayReservationsProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getTodayMyReservations();
});

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return TossCard(
      onTap: onTap,
      padding: responsiveCardPadding(context),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                height: responsiveValue(context, mobile: 48.0, desktop: 56.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: responsiveIconSize(context),
                ),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsiveFontSize(context, base: 15),
                    fontWeight: FontWeight.w600,
                    color: TossColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: responsiveFontSize(context, base: 13),
                    color: TossColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: responsiveIconSize(context, base: 20),
            color: TossColors.textSub,
          ),
        ],
      ),
    );
  }
}

/// 컴팩트 액션 버튼 (2열 그리드용)
class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return TossCard(
      onTap: onTap,
      padding: responsiveCardPadding(context),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: responsiveValue(context, mobile: 40.0, desktop: 48.0),
                height: responsiveValue(context, mobile: 40.0, desktop: 48.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: responsiveIconSize(context, base: 20),
                ),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsiveFontSize(context, base: 14),
                fontWeight: FontWeight.w600,
                color: TossColors.textMain,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: TossColors.textSub,
          ),
        ],
      ),
    );
  }
}
