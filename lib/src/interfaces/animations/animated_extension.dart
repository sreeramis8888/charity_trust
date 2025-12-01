import 'package:flutter/material.dart';
import 'animation_types.dart';
import 'animated_widget_wrapper.dart';

/// Extension on Widget to simplify animation wrapping
extension AnimatedExtension on Widget {
  /// Wrap widget with animation
  Widget animate({
    required AnimationType animationType,
    AnimationDuration duration = AnimationDuration.normal,
    AnimationCurveType curveType = AnimationCurveType.easeOut,
    int delayMilliseconds = 0,
    VoidCallback? onAnimationComplete,
  }) {
    return AnimatedWidgetWrapper(
      animationType: animationType,
      duration: duration,
      curveType: curveType,
      delayMilliseconds: delayMilliseconds,
      onAnimationComplete: onAnimationComplete,
      child: this,
    );
  }

  /// Shorthand for fade in animation
  Widget fadeIn({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.fadeIn,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );

  /// Shorthand for slide from left animation
  Widget slideInFromLeft({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.slideInFromLeft,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );

  /// Shorthand for slide from bottom animation
  Widget slideInFromBottom({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.slideInFromBottom,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );

  /// Shorthand for scale up animation
  Widget scaleUp({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.scaleUp,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );

  /// Shorthand for fade and scale up animation
  Widget fadeScaleUp({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.fadeScaleUp,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );

  /// Shorthand for fade and slide from left animation
  Widget fadeSlideInFromLeft({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.fadeSlideInFromLeft,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );

  /// Shorthand for fade and slide from bottom animation
  Widget fadeSlideInFromBottom({
    AnimationDuration duration = AnimationDuration.normal,
    int delayMilliseconds = 0,
  }) =>
      animate(
        animationType: AnimationType.fadeSlideInFromBottom,
        duration: duration,
        delayMilliseconds: delayMilliseconds,
      );
}
