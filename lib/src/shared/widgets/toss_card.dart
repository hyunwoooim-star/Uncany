import 'package:flutter/material.dart';

import '../theme/toss_colors.dart';
import 'toss_animations.dart';

/// 토스 스타일 카드
///
/// 터치 시 눌리는 효과와 부드러운 애니메이션을 제공합니다.
class TossCard extends StatefulWidget {
  const TossCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding,
    this.margin,
    this.enableTapAnimation = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableTapAnimation;

  @override
  State<TossCard> createState() => _TossCardState();
}

class _TossCardState extends State<TossCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TossDurations.fast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
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
    if (widget.onTap != null && widget.enableTapAnimation) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.enableTapAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableTapAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: TossColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossColors.textMain.withOpacity(_isPressed ? 0.08 : 0.05),
            blurRadius: _isPressed ? 6 : 10,
            offset: Offset(0, _isPressed ? 1 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: TossColors.primary.withOpacity(0.1),
          highlightColor: TossColors.primary.withOpacity(0.05),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap == null || !widget.enableTapAnimation) {
      return card;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: card,
      ),
    );
  }
}
