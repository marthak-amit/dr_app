import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Vector logo: gradient rounded square with a medical cross and a heartbeat line.
class MediQLogo extends StatelessWidget {
  const MediQLogo({super.key, this.size = 96, this.onDark = false});
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onDark ? const LinearGradient(colors: [Colors.white, Color(0xFFE2F2F3)], begin: Alignment.topLeft, end: Alignment.bottomRight) : AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .4), blurRadius: size * .3, offset: Offset(0, size * .1))],
      ),
      child: CustomPaint(painter: _LogoPainter(onDark ? AppColors.primary : Colors.white)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final cross = Paint()..color = color.withValues(alpha: .95);
    final arm = w * .17;
    final c = Offset(w / 2, w * .44);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: arm, height: w * .5), Radius.circular(arm / 2.5)), cross);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w * .5, height: arm), Radius.circular(arm / 2.5)), cross);
    final line = Paint()
      ..color = onLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final y = w * .72;
    final path = Path()
      ..moveTo(w * .16, y)
      ..lineTo(w * .36, y)
      ..lineTo(w * .43, y - w * .12)
      ..lineTo(w * .52, y + w * .1)
      ..lineTo(w * .59, y)
      ..lineTo(w * .84, y);
    canvas.drawPath(path, line);
  }

  Color get onLine => color == Colors.white ? const Color(0xFFFF6B4A) : const Color(0xFFFF6B4A);

  @override
  bool shouldRepaint(covariant _LogoPainter old) => old.color != color;
}
