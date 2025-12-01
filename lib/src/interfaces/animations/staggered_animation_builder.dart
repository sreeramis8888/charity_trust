import 'package:flutter/material.dart';
import 'animation_types.dart';
import 'animated_widget_wrapper.dart';

/// Builder for creating staggered animations across multiple children
class StaggeredAnimationBuilder extends StatelessWidget {
  final List<Widget> children;
  final AnimationType animationType;
  final AnimationDuration duration;
  final AnimationCurveType curveType;
  final int staggerDelayMilliseconds;
  final Axis direction;

  const StaggeredAnimationBuilder({
    required this.children,
    this.animationType = AnimationType.fadeSlideInFromBottom,
    this.duration = AnimationDuration.normal,
    this.curveType = AnimationCurveType.easeOut,
    this.staggerDelayMilliseconds = 100,
    this.direction = Axis.vertical,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (direction) {
      Axis.vertical => Column(
          children: List.generate(
            children.length,
            (index) => AnimatedWidgetWrapper(
              animationType: animationType,
              duration: duration,
              curveType: curveType,
              delayMilliseconds: index * staggerDelayMilliseconds,
              child: children[index],
            ),
          ),
        ),
      Axis.horizontal => Row(
          children: List.generate(
            children.length,
            (index) => Expanded(
              child: AnimatedWidgetWrapper(
                animationType: animationType,
                duration: duration,
                curveType: curveType,
                delayMilliseconds: index * staggerDelayMilliseconds,
                child: children[index],
              ),
            ),
          ),
        ),
    };
  }
}
