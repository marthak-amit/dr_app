import 'package:flutter/material.dart';
import 'package:mediq/core/widgets/widgets.dart';

/// Stylised "map snapshot" painted with CustomPaint (offline, no tiles).
class MapSnapshot extends StatelessWidget {
  const MapSnapshot({super.key, this.height = 140, this.seed = 1});
  final double height;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _MapPainter(dark: p.isDark, pin: p.accent, seed: seed)),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.dark, required this.pin, required this.seed});
  final bool dark;
  final Color pin;
  final int seed;

  @override
  void paint(Canvas canvas, Size s) {
    final base = dark ? const Color(0xFF16262D) : const Color(0xFFEAF1F3);
    final road = dark ? const Color(0xFF263A43) : Colors.white;
    final park = dark ? const Color(0xFF173A2E) : const Color(0xFFD3EBDD);
    final water = dark ? const Color(0xFF173247) : const Color(0xFFCFE6F5);
    canvas.drawRect(Offset.zero & s, Paint()..color = base);

    // water + parks
    canvas.drawOval(Rect.fromLTWH(s.width * .62, -s.height * .25, s.width * .5, s.height * .7), Paint()..color = water);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .06, s.height * .58, s.width * .26, s.height * .32), const Radius.circular(18)), Paint()..color = park);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .5, s.height * .66, s.width * .2, s.height * .22), const Radius.circular(14)), Paint()..color = park);

    // blocks (subtle) + roads
    final roadP = Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    roadP.strokeWidth = 9;
    for (final y in [.22, .52, .84]) {
      canvas.drawLine(Offset(0, s.height * y), Offset(s.width, s.height * (y + (seed.isEven ? .04 : -.03))), roadP);
    }
    for (final x in [.18, .42, .66, .88]) {
      canvas.drawLine(Offset(s.width * x, 0), Offset(s.width * (x + .05), s.height), roadP);
    }
    roadP.strokeWidth = 14;
    canvas.drawLine(Offset(0, s.height * .95), Offset(s.width, s.height * .1), roadP);

    // pin
    final c = Offset(s.width * .5, s.height * .46);
    canvas.drawCircle(c, 26, Paint()..color = pin.withValues(alpha: .15));
    canvas.drawCircle(c, 16, Paint()..color = pin.withValues(alpha: .25));
    final path = Path()
      ..moveTo(c.dx, c.dy + 20)
      ..cubicTo(c.dx - 18, c.dy - 2, c.dx - 14, c.dy - 22, c.dx, c.dy - 22)
      ..cubicTo(c.dx + 14, c.dy - 22, c.dx + 18, c.dy - 2, c.dx, c.dy + 20)
      ..close();
    canvas.drawShadow(path, Colors.black54, 4, true);
    canvas.drawPath(path, Paint()..color = pin);
    canvas.drawCircle(Offset(c.dx, c.dy - 6), 5.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.dark != dark || old.pin != pin;
}
