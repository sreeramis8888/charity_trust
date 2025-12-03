part of '../feature_tour_overlay.dart';

class TapGesturePainter extends CustomPainter {
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

    // Ripple circles
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      12,
      paint..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      18,
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(TapGesturePainter oldDelegate) => false;
}
