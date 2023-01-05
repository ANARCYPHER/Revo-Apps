import 'package:flutter/material.dart';

class CustomShape extends CustomPainter {
  final Color bgColor;
  final double a1, a2, b1, b2, c1, c2;
  CustomShape(
      this.bgColor, this.a1, this.a2, this.b1, this.b2, this.c1, this.c2);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(a1, a2);
    path.lineTo(b1, b2);
    path.lineTo(c1, c2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
