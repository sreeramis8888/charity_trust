import 'package:flutter/material.dart';
import 'animation_types.dart';
import 'animation_utils.dart';

/// A reusable animated widget wrapper that applies animations to any child widget
class AnimatedWidgetWrapper extends StatefulWidget {
  final Widget child;
  final AnimationType animationType;
  final AnimationDuration duration;
  final AnimationCurveType curveType;
  final int delayMilliseconds;
  final bool autoStart;
  final VoidCallback? onAnimationComplete;

  const AnimatedWidgetWrapper({
    required this.child,
    this.animationType = AnimationType.fadeIn,
    this.duration = AnimationDuration.normal,
    this.curveType = AnimationCurveType.easeOut,
    this.delayMilliseconds = 0,
    this.autoStart = true,
    this.onAnimationComplete,
    super.key,
  });

  @override
  State<AnimatedWidgetWrapper> createState() => _AnimatedWidgetWrapperState();
}

class _AnimatedWidgetWrapperState extends State<AnimatedWidgetWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration.value,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationUtils.getCurve(widget.curveType),
      ),
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onAnimationComplete?.call();
        });
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
      animation: _animation,
      builder: (context, child) {
        return _buildAnimatedWidget(_animation.value);
      },
      child: widget.child,
    );
  }

  Widget _buildAnimatedWidget(double animationValue) {
    final child = widget.child;

    return switch (widget.animationType) {
      AnimationType.fadeIn => Opacity(
          opacity: animationValue,
          child: child,
        ),
      AnimationType.slideInFromLeft => Transform.translate(
          offset: Offset((1 - animationValue) * -100, 0),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.slideInFromRight => Transform.translate(
          offset: Offset((1 - animationValue) * 100, 0),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.slideInFromTop => Transform.translate(
          offset: Offset(0, (1 - animationValue) * -100),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.slideInFromBottom => Transform.translate(
          offset: Offset(0, (1 - animationValue) * 100),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.scaleUp => Transform.scale(
          scale: 0.8 + (animationValue * 0.2),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.scaleDown => Transform.scale(
          scale: 1.2 - (animationValue * 0.2),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.bounce => Transform.translate(
          offset: Offset(0, _calculateBounceOffset(animationValue)),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.elastic => Transform.scale(
          scale: 0.5 + (animationValue * 0.5),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.rotate => Transform.rotate(
          angle: animationValue * 6.28,
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.fadeSlideInFromLeft => Transform.translate(
          offset: Offset((1 - animationValue) * -50, 0),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.fadeSlideInFromRight => Transform.translate(
          offset: Offset((1 - animationValue) * 50, 0),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.fadeSlideInFromTop => Transform.translate(
          offset: Offset(0, (1 - animationValue) * -50),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.fadeSlideInFromBottom => Transform.translate(
          offset: Offset(0, (1 - animationValue) * 50),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.fadeScaleUp => Transform.scale(
          scale: 0.9 + (animationValue * 0.1),
          child: Opacity(opacity: animationValue, child: child),
        ),
      AnimationType.pulse => Opacity(
          opacity: 0.5 + (animationValue * 0.5),
          child: child,
        ),
      AnimationType.shimmer => ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 - animationValue * 2, 0),
              end: Alignment(1 + animationValue * 2, 0),
              colors: const [
                Colors.transparent,
                Colors.white30,
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          child: child,
        ),
    };
  }

  double _calculateBounceOffset(double value) {
    if (value < 0.5) {
      return (value * 2) * -50;
    } else {
      return ((1 - value) * 2) * -50;
    }
  }
}
