import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// 토스 스타일 로딩 스켈레톤
///
/// 데이터 로딩 중 뼈대를 보여주는 Shimmer 효과
class TossSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TossSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  /// 원형 스켈레톤 (아바타 등)
  const TossSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 1000; // 충분히 큰 값으로 원형 만듦

  /// 텍스트 라인 스켈레톤
  const TossSkeleton.text({
    super.key,
    this.width = double.infinity,
    this.height = 16,
  }) : borderRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// 카드 형태의 스켈레톤
class TossSkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const TossSkeletonCard({
    super.key,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// 리스트 아이템 스켈레톤 (아이콘 + 텍스트)
class TossSkeletonListItem extends StatelessWidget {
  final bool showTrailing;

  const TossSkeletonListItem({
    super.key,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // 아이콘/아바타
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // 트레일링
            if (showTrailing)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 여러 개의 리스트 아이템 스켈레톤
class TossSkeletonList extends StatelessWidget {
  final int itemCount;
  final bool showTrailing;

  const TossSkeletonList({
    super.key,
    this.itemCount = 5,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => TossSkeletonListItem(showTrailing: showTrailing),
      ),
    );
  }
}
