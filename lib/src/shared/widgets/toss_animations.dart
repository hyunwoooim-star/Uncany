import 'package:flutter/material.dart';

/// 토스 스타일 애니메이션 커브
///
/// 토스 앱에서 사용하는 부드러운 애니메이션 커브
class TossCurves {
  /// 기본 커브 (easeOutCubic)
  static const Curve standard = Curves.easeOutCubic;

  /// 빠른 애니메이션용 (easeOut)
  static const Curve fast = Curves.easeOut;

  /// 느린 애니메이션용 (easeInOutCubic)
  static const Curve slow = Curves.easeInOutCubic;

  /// 바운스 효과 (터치 피드백)
  static const Curve bounce = Curves.easeOutBack;

  /// 스프링 효과
  static const Curve spring = Curves.elasticOut;
}

/// 토스 스타일 애니메이션 시간
class TossDurations {
  /// 빠른 애니메이션 (버튼 터치 등)
  static const Duration fast = Duration(milliseconds: 150);

  /// 기본 애니메이션
  static const Duration standard = Duration(milliseconds: 250);

  /// 느린 애니메이션 (페이지 전환 등)
  static const Duration slow = Duration(milliseconds: 350);

  /// 매우 느린 애니메이션 (모달 등)
  static const Duration verySlow = Duration(milliseconds: 450);
}

/// 탭 시 눌리는 효과를 주는 래퍼 위젯
///
/// 버튼이나 카드에 터치 피드백을 추가합니다.
class TossTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final bool enabled;

  const TossTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.98,
    this.duration = TossDurations.fast,
    this.enabled = true,
  });

  @override
  State<TossTapScale> createState() => _TossTapScaleState();
}

class _TossTapScaleState extends State<TossTapScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TossCurves.standard,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled && widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// 페이드인 애니메이션 위젯
///
/// 위젯이 화면에 나타날 때 페이드인 효과를 줍니다.
class TossFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double initialOpacity;
  final Offset? initialOffset;

  const TossFadeIn({
    super.key,
    required this.child,
    this.duration = TossDurations.standard,
    this.delay = Duration.zero,
    this.curve = TossCurves.standard,
    this.initialOpacity = 0.0,
    this.initialOffset,
  });

  @override
  State<TossFadeIn> createState() => _TossFadeInState();
}

class _TossFadeInState extends State<TossFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.initialOpacity,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.initialOffset ?? Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Transform.translate(
          offset: _slideAnimation.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// 리스트 아이템 스태거드 페이드인
///
/// 리스트 아이템들이 순차적으로 나타나는 효과를 줍니다.
class TossStaggeredItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration itemDuration;
  final Duration staggerDelay;

  const TossStaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.itemDuration = TossDurations.standard,
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return TossFadeIn(
      duration: itemDuration,
      delay: staggerDelay * index,
      initialOffset: const Offset(0, 20),
      child: child,
    );
  }
}

/// 스켈레톤 로딩 위젯
///
/// 로딩 중일 때 shimmer 효과를 표시합니다.
class TossSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TossSkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<TossSkeletonLoader> createState() => _TossSkeletonLoaderState();
}

class _TossSkeletonLoaderState extends State<TossSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// 성공 체크마크 애니메이션
class TossSuccessCheck extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const TossSuccessCheck({
    super.key,
    this.size = 60,
    this.color = Colors.green,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<TossSuccessCheck> createState() => _TossSuccessCheckState();
}

class _TossSuccessCheckState extends State<TossSuccessCheck>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _circleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: TossCurves.standard),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: TossCurves.bounce),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 원
              Transform.scale(
                scale: _circleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.1),
                    border: Border.all(
                      color: widget.color,
                      width: 2,
                    ),
                  ),
                ),
              ),
              // 체크마크
              Transform.scale(
                scale: _checkAnimation.value,
                child: Icon(
                  Icons.check,
                  size: widget.size * 0.5,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 애니메이션 페이지 전환 (슬라이드 + 페이드)
class TossPageTransition extends PageRouteBuilder {
  final Widget page;

  TossPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: TossDurations.slow,
          reverseTransitionDuration: TossDurations.standard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.05, 0);
            const end = Offset.zero;
            const curve = TossCurves.standard;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        );
}

/// 펄스 애니메이션 (알림 배지 등에 사용)
class TossPulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const TossPulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<TossPulse> createState() => _TossPulseState();
}

class _TossPulseState extends State<TossPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}
