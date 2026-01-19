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
import 'package:uncany/src/shared/widgets/toss_skeleton.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';
import 'package:uncany/src/shared/widgets/toss_snackbar.dart';

/// 홈 화면 (v0.3)
///
/// 나의 예약 중심 + 전체 예약 현황 접기/펼치기
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
          TossSnackBar.error(context, message: '로그아웃 실패: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final pendingCountAsync = ref.watch(_pendingCountProvider);
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
    User user,
    AsyncValue<int> pendingCountAsync,
    AsyncValue<List<Reservation>> myReservationsAsync,
    AsyncValue<List<Reservation>> allReservationsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayReservationsProvider);
        ref.invalidate(todayAllReservationsProvider);
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

              // 빠른 액션 버튼들 (교실 예약 + 종합 시간표)
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
                      icon: Icons.grid_view,
                      label: '종합 시간표',
                      color: Colors.orange,
                      onTap: () => context.push('/reservations/timetable'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing * 1.5),

              // 나의 예약 섹션
              _buildMyReservationsSection(
                context,
                myReservationsAsync,
              ),

              SizedBox(height: spacing * 1.5),

              // 전체 예약 현황 (접기/펼치기)
              _buildAllReservationsSection(
                context,
                allReservationsAsync,
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

  /// 나의 예약 섹션 (내 예약만)
  Widget _buildMyReservationsSection(
    BuildContext context,
    AsyncValue<List<Reservation>> myReservationsAsync,
  ) {
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildSectionTitle('나의 예약'),
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
        myReservationsAsync.when(
          data: (reservations) {
            if (reservations.isEmpty) {
              return _buildEmptyMyReservations(context);
            }
            return _buildMyReservationsList(context, reservations);
          },
          loading: () => _buildReservationsSkeletonLoading(context),
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

  /// 전체 예약 현황 섹션 (접기/펼치기)
  Widget _buildAllReservationsSection(
    BuildContext context,
    AsyncValue<List<Reservation>> allReservationsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 헤더 + 펼치기/접기 버튼
        Row(
          children: [
            _buildSectionTitle('오늘의 전체 예약 현황'),
            const SizedBox(width: 8),
            allReservationsAsync.maybeWhen(
              data: (reservations) => Text(
                '${reservations.length}건',
                style: TextStyle(
                  fontSize: responsiveFontSize(context, base: 13),
                  color: TossColors.textSub,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const Spacer(),
            // 명확한 펼치기/접기 버튼
            Material(
              color: _showAllReservations
                  ? TossColors.primary.withOpacity(0.1)
                  : TossColors.background,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showAllReservations = !_showAllReservations;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showAllReservations ? '접기' : '펼치기',
                        style: TextStyle(
                          fontSize: responsiveFontSize(context, base: 12),
                          fontWeight: FontWeight.w500,
                          color: _showAllReservations
                              ? TossColors.primary
                              : TossColors.textSub,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        _showAllReservations
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: _showAllReservations
                            ? TossColors.primary
                            : TossColors.textSub,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // 내용 (펼쳤을 때만 표시)
        if (_showAllReservations) ...[
          SizedBox(height: responsiveSpacing(context, base: 8)),
          allReservationsAsync.when(
            data: (reservations) {
              if (reservations.isEmpty) {
                return TossCard(
                  padding: responsiveCardPadding(context),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '오늘 예약이 없습니다',
                        style: TextStyle(
                          fontSize: responsiveFontSize(context, base: 14),
                          color: TossColors.textSub,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return _buildReservationsList(context, reservations);
            },
            loading: () => _buildReservationsSkeletonLoading(context),
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
      ],
    );
  }

  /// 나의 예약이 없을 때 표시
  Widget _buildEmptyMyReservations(BuildContext context) {
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
            '오늘 나의 예약이 없습니다',
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

  /// 나의 예약 목록 표시
  Widget _buildMyReservationsList(
    BuildContext context,
    List<Reservation> reservations,
  ) {
    // 같은 교실의 예약을 합산
    final grouped = _groupMyReservations(reservations);

    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        children: [
          // 예약 개수 요약
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: TossColors.primary,
                  size: responsiveIconSize(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '오늘 ${grouped.length}건 예약',
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

          // 그룹화된 예약 목록
          ...grouped.map((g) => _MyReservationItem(group: g)),
        ],
      ),
    );
  }

  /// 나의 예약 그룹화 (같은 교실만)
  List<_ReservationGroup> _groupMyReservations(List<Reservation> reservations) {
    final Map<String, _ReservationGroup> groups = {};

    for (final r in reservations) {
      final key = r.classroomId;
      if (groups.containsKey(key)) {
        groups[key]!.addReservation(r);
      } else {
        groups[key] = _ReservationGroup(r);
      }
    }

    // 첫 번째 예약의 시작 시간 기준으로 정렬
    final sorted = groups.values.toList()
      ..sort((a, b) => a.firstPeriod.compareTo(b.firstPeriod));
    return sorted;
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
                Expanded(
                  child: TossSkeletonCard(height: 64),
                ),
                SizedBox(width: spacing * 0.75),
                Expanded(
                  child: TossSkeletonCard(height: 64),
                ),
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
            _buildReservationsSkeletonLoading(context),
          ],
        );
      },
    );
  }

  /// 예약 목록 스켈레톤 로딩
  Widget _buildReservationsSkeletonLoading(BuildContext context) {
    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        children: [
          // 상단 요약 스켈레톤
          TossSkeleton(
            width: double.infinity,
            height: 48,
            borderRadius: 8,
          ),
          const SizedBox(height: 16),
          // 예약 아이템 스켈레톤 2개
          _buildReservationItemSkeleton(context),
          const SizedBox(height: 12),
          _buildReservationItemSkeleton(context),
        ],
      ),
    );
  }

  /// 예약 아이템 스켈레톤
  Widget _buildReservationItemSkeleton(BuildContext context) {
    return Row(
      children: [
        // 교시 표시 스켈레톤
        TossSkeleton(
          width: responsiveValue(context, mobile: 64.0, desktop: 72.0),
          height: 48,
          borderRadius: 8,
        ),
        const SizedBox(width: 12),
        // 교실 정보 스켈레톤
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TossSkeleton(
                width: 120,
                height: 16,
                borderRadius: 4,
              ),
              const SizedBox(height: 6),
              TossSkeleton(
                width: 80,
                height: 12,
                borderRadius: 4,
              ),
            ],
          ),
        ),
        // 상태 배지 스켈레톤
        TossSkeleton(
          width: 48,
          height: 24,
          borderRadius: 4,
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
    // 같은 교실 + 선생님의 예약을 합산
    final grouped = _groupReservations(reservations);

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
                    '오늘 ${grouped.length}건의 예약이 있습니다',
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

          // 그룹화된 예약 목록
          ...grouped.map((g) => _GroupedReservationItem(group: g)),
        ],
      ),
    );
  }

  /// 같은 교실 + 선생님의 예약을 그룹화
  List<_ReservationGroup> _groupReservations(List<Reservation> reservations) {
    final Map<String, _ReservationGroup> groups = {};

    for (final r in reservations) {
      final key = '${r.classroomId}_${r.teacherId}';
      if (groups.containsKey(key)) {
        groups[key]!.addReservation(r);
      } else {
        groups[key] = _ReservationGroup(r);
      }
    }

    // 첫 번째 예약의 시작 시간 기준으로 정렬
    final sorted = groups.values.toList()
      ..sort((a, b) => a.firstPeriod.compareTo(b.firstPeriod));
    return sorted;
  }
}

/// 그룹화된 예약 정보
class _ReservationGroup {
  final Reservation firstReservation;
  final Set<int> _allPeriods = {};

  _ReservationGroup(this.firstReservation) {
    _allPeriods.addAll(firstReservation.periods ?? []);
  }

  void addReservation(Reservation r) {
    _allPeriods.addAll(r.periods ?? []);
  }

  List<int> get allPeriods {
    final sorted = _allPeriods.toList()..sort();
    return sorted;
  }

  int get firstPeriod => allPeriods.isNotEmpty ? allPeriods.first : 0;

  /// 교시 표시 (연속 범위로 그룹화: "2~3, 6교시")
  String get periodsDisplay {
    if (allPeriods.isEmpty) return '-';
    if (allPeriods.length == 1) return '${allPeriods.first}교시';

    // 연속된 교시들을 범위로 그룹화
    final ranges = <String>[];
    int rangeStart = allPeriods.first;
    int rangeEnd = allPeriods.first;

    for (int i = 1; i < allPeriods.length; i++) {
      if (allPeriods[i] == rangeEnd + 1) {
        // 연속됨 - 범위 확장
        rangeEnd = allPeriods[i];
      } else {
        // 연속 끊김 - 이전 범위 저장 후 새 범위 시작
        ranges.add(_formatRange(rangeStart, rangeEnd));
        rangeStart = allPeriods[i];
        rangeEnd = allPeriods[i];
      }
    }
    // 마지막 범위 저장
    ranges.add(_formatRange(rangeStart, rangeEnd));

    return '${ranges.join(", ")}교시';
  }

  /// 범위 포맷 (단일: "1", 범위: "2~3")
  String _formatRange(int start, int end) {
    if (start == end) {
      return '$start';
    } else {
      return '$start~$end';
    }
  }

  String? get classroomName => firstReservation.classroomName;
  String? get classroomRoomType => firstReservation.classroomRoomType;
  String get teacherDisplayName => firstReservation.teacherDisplayName;
  String? get description => firstReservation.description;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(firstReservation.startTime) &&
        now.isBefore(firstReservation.endTime);
  }

  bool get isUpcoming => DateTime.now().isBefore(firstReservation.startTime);
}

/// 그룹화된 예약 아이템 위젯
class _GroupedReservationItem extends StatelessWidget {
  final _ReservationGroup group;

  const _GroupedReservationItem({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 교시 표시
          Container(
            width: responsiveValue(context, mobile: 72.0, desktop: 80.0),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              group.periodsDisplay,
              style: TextStyle(
                fontSize: responsiveFontSize(context, base: 12),
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // 교실 및 예약자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getRoomTypeIcon(group.classroomRoomType),
                      size: responsiveIconSize(context, base: 16),
                      color: TossColors.textSub,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        group.classroomName ?? '교실',
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
                const SizedBox(height: 2),
                // 예약자 정보 표시
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: responsiveIconSize(context, base: 14),
                      color: TossColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        group.teacherDisplayName,
                        style: TextStyle(
                          fontSize: responsiveFontSize(context, base: 12),
                          color: TossColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
    if (group.isOngoing) return Colors.green;
    if (group.isUpcoming) return TossColors.primary;
    return Colors.grey;
  }

  Widget _buildStatusBadge(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    if (group.isOngoing) {
      text = '진행중';
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (group.isUpcoming) {
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

/// 나의 예약 아이템 위젯 (교사명 없이 교실만 표시)
class _MyReservationItem extends StatelessWidget {
  final _ReservationGroup group;

  const _MyReservationItem({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 교시 표시
          Container(
            width: responsiveValue(context, mobile: 72.0, desktop: 80.0),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              group.periodsDisplay,
              style: TextStyle(
                fontSize: responsiveFontSize(context, base: 12),
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // 교실 정보만 (예약자 정보 생략)
          Expanded(
            child: Row(
              children: [
                Icon(
                  _getRoomTypeIcon(group.classroomRoomType),
                  size: responsiveIconSize(context, base: 18),
                  color: TossColors.textMain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.classroomName ?? '교실',
                    style: TextStyle(
                      fontSize: responsiveFontSize(context, base: 15),
                      fontWeight: FontWeight.w600,
                      color: TossColors.textMain,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
    if (group.isOngoing) return Colors.green;
    if (group.isUpcoming) return TossColors.success;
    return Colors.grey;
  }

  Widget _buildStatusBadge(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    if (group.isOngoing) {
      text = '진행중';
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (group.isUpcoming) {
      text = '예정';
      bgColor = TossColors.success.withOpacity(0.1);
      textColor = TossColors.success;
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

          // 교실 및 예약자 정보
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
                const SizedBox(height: 2),
                // 예약자 정보 표시
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: responsiveIconSize(context, base: 14),
                      color: TossColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reservation.teacherDisplayName,
                        style: TextStyle(
                          fontSize: responsiveFontSize(context, base: 12),
                          color: TossColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
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
                      fontSize: responsiveFontSize(context, base: 11),
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

// 오늘의 내 예약 목록 Provider (예약 생성 후 invalidate 용도로 public)
final todayReservationsProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getTodayMyReservations();
});

// 오늘의 전체 예약 목록 Provider (홈 화면에서 모든 예약 표시용)
final todayAllReservationsProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getTodayAllReservations();
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
