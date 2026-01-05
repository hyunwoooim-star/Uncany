import 'package:flutter/material.dart';

import '../theme/toss_colors.dart';
import 'toss_animations.dart';

/// 토스 스타일 버튼
///
/// 터치 시 눌리는 효과와 로딩 상태를 지원합니다.
class TossButton extends StatefulWidget {
  const TossButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isDisabled = false,
    this.enableTapAnimation = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isDisabled;
  final bool enableTapAnimation;

  @override
  State<TossButton> createState() => _TossButtonState();
}

class _TossButtonState extends State<TossButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TossDurations.fast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
    if (_isEnabled && widget.enableTapAnimation) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isEnabled && widget.enableTapAnimation) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableTapAnimation) {
      _controller.reverse();
    }
  }

  bool get _isEnabled =>
      widget.onPressed != null && !widget.isLoading && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isEnabled ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? TossColors.primary,
          foregroundColor: widget.foregroundColor ?? Colors.white,
          disabledBackgroundColor: TossColors.disabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: TossDurations.fast,
          child: widget.isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('content'),
                  child: widget.child,
                ),
        ),
      ),
    );

    if (!widget.enableTapAnimation || !_isEnabled) {
      return button;
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
        child: button,
      ),
    );
  }
}

/// 토스 스타일 텍스트 버튼
class TossTextButton extends StatefulWidget {
  const TossTextButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.color,
    this.enableTapAnimation = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final bool enableTapAnimation;

  @override
  State<TossTextButton> createState() => _TossTextButtonState();
}

class _TossTextButtonState extends State<TossTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TossDurations.fast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
    if (widget.onPressed != null && widget.enableTapAnimation) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && widget.enableTapAnimation) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableTapAnimation) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: widget.color ?? TossColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: widget.child,
    );

    if (!widget.enableTapAnimation || widget.onPressed == null) {
      return button;
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
        child: button,
      ),
    );
  }
}
