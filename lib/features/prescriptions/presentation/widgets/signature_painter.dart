import 'package:flutter/material.dart';

/// Hand-drawn style squiggle used as the doctor's "signature".
class SignaturePainter extends CustomPainter {
  SignaturePainter(this.color, {this.seed = 0});
  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final j = (seed % 5) * .02;
    final path = Path()
      ..moveTo(w * .04, h * .7)
      ..cubicTo(w * (.1 + j), h * .1, w * .18, h * .95, w * .26, h * .4)
      ..cubicTo(w * .3, h * .1, w * .34, h * .9, w * .4, h * .55)
      ..cubicTo(w * .45, h * .25, w * .5, h * .85, w * .56, h * .5)
      ..cubicTo(w * .62, h * .2, w * .66, h * .8, w * .72, h * .45)
      ..cubicTo(w * .78, h * .15, w * .84, h * .75, w * .96, h * .3);
    final under = Path()
      ..moveTo(w * .1, h * .88)
      ..quadraticBezierTo(w * .5, h * 1.0, w * .9, h * .8);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
    canvas.drawPath(under, paint..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(covariant SignaturePainter old) => old.color != color;
}
