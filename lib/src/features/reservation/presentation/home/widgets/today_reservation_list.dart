import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/reservation.dart';
import 'package:uncany/src/shared/theme/toss_colors.dart';
import 'package:uncany/src/shared/widgets/toss_card.dart';
import 'package:uncany/src/shared/widgets/toss_skeleton.dart';
import 'package:uncany/src/shared/widgets/responsive_layout.dart';
import 'package:uncany/src/shared/utils/room_type_utils.dart';

/// 나의 예약 섹션 위젯
class MyReservationsSection extends StatelessWidget {
  final AsyncValue<List<Reservation>> reservationsAsync;

  const MyReservationsSection({
    super.key,
    required this.reservationsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildSectionTitle(context, '나의 예약'),
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
        reservationsAsync.when(
          data: (reservations) {
            if (reservations.isEmpty) {
              return _EmptyMyReservations();
            }
            return _MyReservationsList(reservations: reservations);
          },
          loading: () => const ReservationsSkeletonLoading(),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: responsiveFontSize(context, base: 15),
          fontWeight: FontWeight.w600,
          color: TossColors.textSub,
        ),
      ),
    );
  }
}

/// 전체 예약 현황 섹션 (접기/펼치기)
class AllReservationsSection extends StatelessWidget {
  final AsyncValue<List<Reservation>> reservationsAsync;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AllReservationsSection({
    super.key,
    required this.reservationsAsync,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 헤더 + 펼치기/접기 버튼
        Row(
          children: [
            _buildSectionTitle(context, '오늘의 전체 예약 현황'),
            const SizedBox(width: 8),
            reservationsAsync.maybeWhen(
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
            _ExpandButton(
              isExpanded: isExpanded,
              onTap: onToggle,
            ),
          ],
        ),
        // 내용 (펼쳤을 때만 표시)
        if (isExpanded) ...[
          SizedBox(height: responsiveSpacing(context, base: 8)),
          reservationsAsync.when(
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
              return _AllReservationsList(reservations: reservations);
            },
            loading: () => const ReservationsSkeletonLoading(),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: responsiveFontSize(context, base: 15),
          fontWeight: FontWeight.w600,
          color: TossColors.textSub,
        ),
      ),
    );
  }
}

/// 펼치기/접기 버튼
class _ExpandButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandButton({
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isExpanded
          ? TossColors.primary.withOpacity(0.1)
          : TossColors.background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpanded ? '접기' : '펼치기',
                style: TextStyle(
                  fontSize: responsiveFontSize(context, base: 12),
                  fontWeight: FontWeight.w500,
                  color: isExpanded ? TossColors.primary : TossColors.textSub,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: isExpanded ? TossColors.primary : TossColors.textSub,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 나의 예약이 없을 때 표시
class _EmptyMyReservations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

/// 나의 예약 목록
class _MyReservationsList extends StatelessWidget {
  final List<Reservation> reservations;

  const _MyReservationsList({required this.reservations});

  @override
  Widget build(BuildContext context) {
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

  List<ReservationGroup> _groupMyReservations(List<Reservation> reservations) {
    final Map<String, ReservationGroup> groups = {};

    for (final r in reservations) {
      final key = r.classroomId;
      if (groups.containsKey(key)) {
        groups[key]!.addReservation(r);
      } else {
        groups[key] = ReservationGroup(r);
      }
    }

    final sorted = groups.values.toList()
      ..sort((a, b) => a.firstPeriod.compareTo(b.firstPeriod));
    return sorted;
  }
}

/// 전체 예약 목록
class _AllReservationsList extends StatelessWidget {
  final List<Reservation> reservations;

  const _AllReservationsList({required this.reservations});

  @override
  Widget build(BuildContext context) {
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

  List<ReservationGroup> _groupReservations(List<Reservation> reservations) {
    final Map<String, ReservationGroup> groups = {};

    for (final r in reservations) {
      final key = '${r.classroomId}_${r.teacherId}';
      if (groups.containsKey(key)) {
        groups[key]!.addReservation(r);
      } else {
        groups[key] = ReservationGroup(r);
      }
    }

    final sorted = groups.values.toList()
      ..sort((a, b) => a.firstPeriod.compareTo(b.firstPeriod));
    return sorted;
  }
}

/// 예약 목록 스켈레톤 로딩
class ReservationsSkeletonLoading extends StatelessWidget {
  const ReservationsSkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return TossCard(
      padding: responsiveCardPadding(context),
      child: Column(
        children: [
          TossSkeleton(
            width: double.infinity,
            height: 48,
            borderRadius: 8,
          ),
          const SizedBox(height: 16),
          _buildReservationItemSkeleton(context),
          const SizedBox(height: 12),
          _buildReservationItemSkeleton(context),
        ],
      ),
    );
  }

  Widget _buildReservationItemSkeleton(BuildContext context) {
    return Row(
      children: [
        TossSkeleton(
          width: responsiveValue(context, mobile: 64.0, desktop: 72.0),
          height: 48,
          borderRadius: 8,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TossSkeleton(width: 120, height: 16, borderRadius: 4),
              const SizedBox(height: 6),
              TossSkeleton(width: 80, height: 12, borderRadius: 4),
            ],
          ),
        ),
        TossSkeleton(width: 48, height: 24, borderRadius: 4),
      ],
    );
  }
}

/// 그룹화된 예약 정보
class ReservationGroup {
  final Reservation firstReservation;
  final Set<int> _allPeriods = {};

  ReservationGroup(this.firstReservation) {
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

  String get periodsDisplay {
    if (allPeriods.isEmpty) return '-';
    if (allPeriods.length == 1) return '${allPeriods.first}교시';

    final ranges = <String>[];
    int rangeStart = allPeriods.first;
    int rangeEnd = allPeriods.first;

    for (int i = 1; i < allPeriods.length; i++) {
      if (allPeriods[i] == rangeEnd + 1) {
        rangeEnd = allPeriods[i];
      } else {
        ranges.add(_formatRange(rangeStart, rangeEnd));
        rangeStart = allPeriods[i];
        rangeEnd = allPeriods[i];
      }
    }
    ranges.add(_formatRange(rangeStart, rangeEnd));

    return '${ranges.join(", ")}교시';
  }

  String _formatRange(int start, int end) {
    if (start == end) return '$start';
    return '$start~$end';
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

/// 그룹화된 예약 아이템 (전체 예약용 - 교사명 표시)
class _GroupedReservationItem extends StatelessWidget {
  final ReservationGroup group;

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
                      RoomTypeUtils.getIcon(group.classroomRoomType),
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
}

/// 나의 예약 아이템 (교사명 없이 교실만 표시)
class _MyReservationItem extends StatelessWidget {
  final ReservationGroup group;

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
                  RoomTypeUtils.getIcon(group.classroomRoomType),
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
}
