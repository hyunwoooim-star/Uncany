import 'package:flutter/material.dart';

/// 토스 스타일 바운싱 버튼
///
/// 버튼을 눌렀을 때 살짝 축소되는 효과로
/// 실제 물체를 누르는 듯한 피드백 제공
class TossBouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  const TossBouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96, // 눌렀을 때 96% 크기로 축소
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<TossBouncingButton> createState() => _TossBouncingButtonState();
}

class _TossBouncingButtonState extends State<TossBouncingButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// TossBouncingButton을 적용한 카드 위젯
class TossBouncingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? color;
  final double borderRadius;

  const TossBouncingCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return TossBouncingButton(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
