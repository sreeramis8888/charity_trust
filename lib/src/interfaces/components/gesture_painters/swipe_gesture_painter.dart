part of '../feature_tour_overlay.dart';

class SwipeGesturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Palm
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.5), 8, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.5), 8, paint);

    // Fingers
    final fingerPositions = [
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.65, size.height * 0.15),
    ];

    for (var pos in fingerPositions) {
      canvas.drawLine(Offset(size.width * 0.4, size.height * 0.5), pos, paint);
      canvas.drawCircle(pos, 3, fillPaint);
      canvas.drawCircle(pos, 3, paint);
    }

    // Arrow indicating direction
    final arrowStart = Offset(size.width * 0.7, size.height * 0.5);
    final arrowEnd = Offset(size.width * 1.0, size.height * 0.5);
    canvas.drawLine(arrowStart, arrowEnd, paint);

    // Arrow head
    const arrowSize = 6.0;
    canvas.drawLine(
      arrowEnd,
      Offset(arrowEnd.dx - arrowSize, arrowEnd.dy - arrowSize),
      paint,
    );
    canvas.drawLine(
      arrowEnd,
      Offset(arrowEnd.dx - arrowSize, arrowEnd.dy + arrowSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(SwipeGesturePainter oldDelegate) => false;
}
