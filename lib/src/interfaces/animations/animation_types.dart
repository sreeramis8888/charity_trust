/// Enum defining all available animation types for the application
enum AnimationType {
  /// Fade in/out animation
  fadeIn,

  /// Slide from left to right
  slideInFromLeft,

  /// Slide from right to left
  slideInFromRight,

  /// Slide from top to bottom
  slideInFromTop,

  /// Slide from bottom to top
  slideInFromBottom,

  /// Scale up animation
  scaleUp,

  /// Scale down animation
  scaleDown,

  /// Bounce animation
  bounce,

  /// Elastic animation
  elastic,

  /// Rotate animation
  rotate,

  /// Combined fade and slide from left
  fadeSlideInFromLeft,

  /// Combined fade and slide from right
  fadeSlideInFromRight,

  /// Combined fade and slide from top
  fadeSlideInFromTop,

  /// Combined fade and slide from bottom
  fadeSlideInFromBottom,

  /// Combined fade and scale up
  fadeScaleUp,

  /// Pulse animation
  pulse,

  /// Shimmer animation
  shimmer,
}

/// Enum defining animation curve types
enum AnimationCurveType {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  easeInExpo,
  easeOutExpo,
  easeInCirc,
  easeOutCirc,
  easeInBack,
  easeOutBack,
  elasticIn,
  elasticOut,
  bounceIn,
  bounceOut,
}

/// Enum defining animation duration presets
enum AnimationDuration {
  fast(Duration(milliseconds: 300)),
  normal(Duration(milliseconds: 500)),
  slow(Duration(milliseconds: 800)),
  verySlow(Duration(milliseconds: 1200));

  final Duration value;
  const AnimationDuration(this.value);
}
