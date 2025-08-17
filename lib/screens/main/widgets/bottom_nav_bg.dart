import 'package:flutter/material.dart';

/// This is the [custom painter] for the [bottom navigation bar]
class BottomNavCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();

    path_0.moveTo(0, size.height);
    path_0.lineTo(0, size.height * 0.2522523);
    path_0.lineTo(size.width * 0.2983760, size.height * 0.2522523);
    path_0.cubicTo(
        size.width * 0.3843440,
        size.height * 0.2499189,
        size.width * 0.4182347,
        size.height * 0.1216216,
        size.width * 0.4402427,
        size.height * 0.07265766);
    path_0.cubicTo(size.width * 0.4624347, size.height * 0.02326126,
        size.width * 0.4827547, 0, size.width * 0.5001520, 0);
    path_0.cubicTo(
        size.width * 0.5175493,
        0,
        size.width * 0.5425387,
        size.height * 0.02859459,
        size.width * 0.5602667,
        size.height * 0.07265766);
    path_0.cubicTo(
        size.width * 0.5779947,
        size.height * 0.1167207,
        size.width * 0.6154987,
        size.height * 0.2522523,
        size.width * 0.7040000,
        size.height * 0.2522523);
    path_0.lineTo(size.width, size.height * 0.2522523);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(0, size.height);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Colors.white.withOpacity(1.0);
    // canvas.drawShadow(path_0, const Color(0xFF6AEEFF), 100, false);
    canvas.drawShadow(
        path_0.shift(const Offset(0, -4)), const Color(0xFF6AEEFF), 4.0, true);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
