import 'package:flutter/material.dart';
import 'animation_types.dart';

/// Utility class for animation-related operations
class AnimationUtils {
  /// Get Curve from AnimationCurveType enum
  static Curve getCurve(AnimationCurveType curveType) {
    return switch (curveType) {
      AnimationCurveType.linear => Curves.linear,
      AnimationCurveType.easeIn => Curves.easeIn,
      AnimationCurveType.easeOut => Curves.easeOut,
      AnimationCurveType.easeInOut => Curves.easeInOut,
      AnimationCurveType.easeInExpo => Curves.easeInExpo,
      AnimationCurveType.easeOutExpo => Curves.easeOutExpo,
      AnimationCurveType.easeInCirc => Curves.easeInCirc,
      AnimationCurveType.easeOutCirc => Curves.easeOutCirc,
      AnimationCurveType.easeInBack => Curves.easeInBack,
      AnimationCurveType.easeOutBack => Curves.easeOutBack,
      AnimationCurveType.elasticIn => Curves.elasticIn,
      AnimationCurveType.elasticOut => Curves.elasticOut,
      AnimationCurveType.bounceIn => Curves.bounceIn,
      AnimationCurveType.bounceOut => Curves.bounceOut,
    };
  }

  /// Get default duration for animation type
  static Duration getDefaultDuration(AnimationType type) {
    return switch (type) {
      AnimationType.fadeIn ||
      AnimationType.pulse ||
      AnimationType.shimmer =>
        AnimationDuration.normal.value,
      AnimationType.slideInFromLeft ||
      AnimationType.slideInFromRight ||
      AnimationType.slideInFromTop ||
      AnimationType.slideInFromBottom =>
        AnimationDuration.normal.value,
      AnimationType.scaleUp || AnimationType.scaleDown => AnimationDuration.fast.value,
      AnimationType.bounce || AnimationType.elastic => AnimationDuration.slow.value,
      AnimationType.rotate => AnimationDuration.normal.value,
      AnimationType.fadeSlideInFromLeft ||
      AnimationType.fadeSlideInFromRight ||
      AnimationType.fadeSlideInFromTop ||
      AnimationType.fadeSlideInFromBottom =>
        AnimationDuration.normal.value,
      AnimationType.fadeScaleUp => AnimationDuration.normal.value,
    };
  }

  /// Get default curve for animation type
  static AnimationCurveType getDefaultCurve(AnimationType type) {
    return switch (type) {
      AnimationType.fadeIn => AnimationCurveType.easeIn,
      AnimationType.slideInFromLeft ||
      AnimationType.slideInFromRight ||
      AnimationType.slideInFromTop ||
      AnimationType.slideInFromBottom =>
        AnimationCurveType.easeOut,
      AnimationType.scaleUp => AnimationCurveType.easeOutBack,
      AnimationType.scaleDown => AnimationCurveType.easeInBack,
      AnimationType.bounce => AnimationCurveType.bounceOut,
      AnimationType.elastic => AnimationCurveType.elasticOut,
      AnimationType.rotate => AnimationCurveType.easeInOut,
      AnimationType.fadeSlideInFromLeft ||
      AnimationType.fadeSlideInFromRight ||
      AnimationType.fadeSlideInFromTop ||
      AnimationType.fadeSlideInFromBottom =>
        AnimationCurveType.easeOut,
      AnimationType.fadeScaleUp => AnimationCurveType.easeOutBack,
      AnimationType.pulse => AnimationCurveType.easeInOut,
      AnimationType.shimmer => AnimationCurveType.linear,
    };
  }
}
