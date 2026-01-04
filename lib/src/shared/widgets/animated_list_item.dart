import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 애니메이션이 적용된 리스트 아이템
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration? delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? (index * 50).ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut);
  }
}

/// Staggered 리스트 애니메이션
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;

  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => AnimatedListItem(
          index: index,
          delay: itemDelay * index,
          child: children[index],
        ),
      ),
    );
  }
}

/// 카드 등장 애니메이션
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final Duration? delay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay ?? 0.ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
  }
}

/// 성공 체크 애니메이션
class SuccessCheckAnimation extends StatelessWidget {
  final double size;

  const SuccessCheckAnimation({
    super.key,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check_circle,
      size: size,
      color: Colors.green,
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shake(hz: 2, duration: 200.ms);
  }
}

/// 로딩 페이드 애니메이션
class FadeInLoading extends StatelessWidget {
  final Widget child;

  const FadeInLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(duration: 800.ms)
        .fadeOut(duration: 800.ms);
  }
}
