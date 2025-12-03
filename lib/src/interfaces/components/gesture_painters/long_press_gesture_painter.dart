part of '../feature_tour_overlay.dart';

class LongPressGesturePainter extends CustomPainter {
  final double progress;

  LongPressGesturePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Finger
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), 6, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), 6, paint);

    // Finger stem
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.36),
      Offset(size.width * 0.5, size.height * 0.7),
      paint,
    );

    // Palm
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.75), 8, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.75), 8, paint);

    // Expanding ripple circles for long press
    final maxRadius = 25.0;
    final currentRadius = (progress % 1.0) * maxRadius;
    final opacity = 1.0 - (progress % 1.0);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      currentRadius,
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(opacity * 0.8),
    );
  }

  @override
  bool shouldRepaint(LongPressGesturePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
