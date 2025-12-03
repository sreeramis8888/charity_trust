import 'package:flutter/material.dart';

enum GestureType {
  swipe,      // Hand swiping left/right
  tap,        // Finger tapping
  longPress,  // Long press gesture
  none,       // No gesture animation
}

class FeatureTourStep {
  final String id;
  final String title;
  final String description;
  final GlobalKey targetKey;
  final Alignment alignment;
  final EdgeInsets padding;
  final GestureType gestureType;

  FeatureTourStep({
    required this.id,
    required this.title,
    required this.description,
    required this.targetKey,
    this.alignment = Alignment.bottomCenter,
    this.padding = const EdgeInsets.all(8),
    this.gestureType = GestureType.none,
  });
}

class FeatureTour {
  final String id;
  final List<FeatureTourStep> steps;
  final bool showOnce;

  FeatureTour({
    required this.id,
    required this.steps,
    this.showOnce = true,
  });
}
