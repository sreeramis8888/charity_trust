import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/feature_tours/feature_tour_model.dart';
import 'package:charity_trust/src/data/feature_tours/feature_tour_provider.dart';

part 'gesture_painters/swipe_gesture_painter.dart';
part 'gesture_painters/tap_gesture_painter.dart';
part 'gesture_painters/long_press_gesture_painter.dart';

class FeatureTourOverlay extends ConsumerStatefulWidget {
  final FeatureTour tour;
  final VoidCallback? onComplete;

  const FeatureTourOverlay({
    Key? key,
    required this.tour,
    this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<FeatureTourOverlay> createState() => _FeatureTourOverlayState();
}

class _FeatureTourOverlayState extends ConsumerState<FeatureTourOverlay>
    with TickerProviderStateMixin {
  late int _currentStep;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _gestureController;

  @override
  void initState() {
    super.initState();
    _currentStep = 0;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _gestureController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _gestureController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.tour.steps.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() => _currentStep++);
        _fadeController.forward();
      });
    } else {
      _completeTour();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _fadeController.reverse().then((_) {
        setState(() => _currentStep--);
        _fadeController.forward();
      });
    }
  }

  void _completeTour() {
    ref
        .read(completedFeatureToursProvider.notifier)
        .markTourAsCompleted(widget.tour.id);
    widget.onComplete?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.tour.steps[_currentStep];
    final targetBox =
        step.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetBox == null) {
      return const SizedBox.shrink();
    }

    final targetSize = targetBox.size;
    final targetOffset = targetBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        GestureDetector(
          onTap: _nextStep,
          child: Container(
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        // Animated spotlight/glow effect
        Positioned(
          left: targetOffset.dx - step.padding.left,
          top: targetOffset.dy - step.padding.top,
          width: targetSize.width + step.padding.horizontal,
          height: targetSize.height + step.padding.vertical,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.05).animate(
              CurvedAnimation(
                  parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Gesture animation (if applicable)
        if (step.gestureType != GestureType.none)
          Positioned(
            left: targetOffset.dx + targetSize.width / 2 - 30,
            top: targetOffset.dy + targetSize.height / 2 - 30,
            child: _buildGestureAnimation(step.gestureType),
          ),
        // Info card with enhanced styling
        Positioned(
          left: 16,
          right: 16,
          bottom: 32,
          child: FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kStrokeColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kSecondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            widget.tour.steps.length,
                            (index) => Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentStep
                                    ? kPrimaryColor
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (_currentStep > 0)
                              TextButton(
                                onPressed: _previousStep,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(color: kSecondaryTextColor),
                                ),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _currentStep == widget.tour.steps.length - 1
                                    ? 'Got it!'
                                    : 'Next',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGestureAnimation(GestureType gestureType) {
    return AnimatedBuilder(
      animation: _gestureController,
      builder: (context, child) {
        final progress = _gestureController.value;

        switch (gestureType) {
          case GestureType.swipe:
            return _buildSwipeGesture(progress);
          case GestureType.tap:
            return _buildTapGesture(progress);
          case GestureType.longPress:
            return _buildLongPressGesture(progress);
          case GestureType.none:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSwipeGesture(double progress) {
    final xOffset = progress < 0.5
        ? (progress * 2) * 60
        : ((1 - progress) * 2) * 60;

    return Transform.translate(
      offset: Offset(xOffset - 30, 0),
      child: Opacity(
        opacity: (1 - (progress - 0.7).abs() * 3).clamp(0, 1),
        child: CustomPaint(
          painter: SwipeGesturePainter(),
          size: const Size(60, 60),
        ),
      ),
    );
  }

  Widget _buildTapGesture(double progress) {
    final scale = 1.0 + (sin(progress * 3.14159 * 2) * 0.2);
    final opacity = (1 - (progress - 0.7).abs() * 3).clamp(0, 1);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.toDouble(),
        child: CustomPaint(
          painter: TapGesturePainter(),
          size: const Size(50, 50),
        ),
      ),
    );
  }

  Widget _buildLongPressGesture(double progress) {
    final opacity = (1 - (progress - 0.7).abs() * 3).clamp(0, 1);

    return Opacity(
      opacity: opacity.toDouble(),
      child: CustomPaint(
        painter: LongPressGesturePainter(progress: progress),
        size: const Size(60, 60),
      ),
    );
  }
}
