import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/repositories/providers.dart';

// A rendered "paper" is intentionally white in both themes (it mimics a printed document).
const _ink = Color(0xFF16313A);
const _inkSoft = Color(0xFF6B8089);
const _line = Color(0xFFE3EAEE);

class _Row {
  const _Row(this.test, this.result, this.unit, this.range, {this.flag});
  final String test, result, unit, range;
  final String? flag; // H / L
}

List<_Row> _rowsFor(String title) {
  final t = title.toLowerCase();
  if (t.contains('lipid')) {
    return const [
      _Row('Total Cholesterol', '212', 'mg/dL', '< 200', flag: 'H'),
      _Row('LDL Cholesterol', '134', 'mg/dL', '< 100', flag: 'H'),
      _Row('HDL Cholesterol', '46', 'mg/dL', '> 40'),
      _Row('Triglycerides', '148', 'mg/dL', '< 150'),
      _Row('VLDL', '30', 'mg/dL', '< 30'),
    ];
  }
  if (t.contains('hba1c') || t.contains('sugar')) {
    return const [
      _Row('HbA1c', '6.1', '%', '4.0 – 5.6', flag: 'H'),
      _Row('Fasting Glucose', '108', 'mg/dL', '70 – 99', flag: 'H'),
      _Row('Post-prandial Glucose', '138', 'mg/dL', '< 140'),
      _Row('Avg. Glucose (eAG)', '128', 'mg/dL', '—'),
    ];
  }
  if (t.contains('thyroid')) {
    return const [
      _Row('T3 (Total)', '112', 'ng/dL', '80 – 200'),
      _Row('T4 (Total)', '8.4', 'µg/dL', '5.1 – 14.1'),
      _Row('TSH', '5.2', 'µIU/mL', '0.4 – 4.2', flag: 'H'),
    ];
  }
  return const [
    _Row('Hemoglobin', '13.8', 'g/dL', '13.0 – 17.0'),
    _Row('RBC Count', '4.9', 'mil/µL', '4.5 – 5.5'),
    _Row('WBC Count', '11.8', '10³/µL', '4.0 – 11.0', flag: 'H'),
    _Row('Platelets', '262', '10³/µL', '150 – 410'),
    _Row('Hematocrit', '41.2', '%', '40 – 50'),
    _Row('MCV', '84', 'fL', '83 – 101'),
    _Row('Neutrophils', '58', '%', '40 – 80'),
    _Row('Lymphocytes', '19', '%', '20 – 40', flag: 'L'),
  ];
}

TextStyle _t(double s, {FontWeight w = FontWeight.w500, Color c = _ink}) => TextStyle(fontFamily: AppTypography.fontFamily, fontSize: s, fontWeight: w, color: c, height: 1.35);

/// Paper-like preview of a lab report / prescription page.
class RecordPaper extends StatelessWidget {
  const RecordPaper({super.key, required this.record});
  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    final isRx = record.kind == RecordKind.prescription;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .14), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _letterhead(),
        const SizedBox(height: 14),
        _patientBlock(),
        const SizedBox(height: 16),
        Text(isRx ? 'PRESCRIPTION' : record.title.toUpperCase(), style: _t(13, w: FontWeight.w800, c: AppColors.primary)),
        const SizedBox(height: 8),
        if (isRx) ..._rx() else ..._table(),
        const SizedBox(height: 22),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text('Generated electronically. Results should be interpreted by a qualified physician.', style: _t(9, c: _inkSoft))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Transform.rotate(angle: -.08, child: Text(isRx ? 'Dr. ${record.source.replaceFirst('Dr. ', '')}' : 'Dr. S. Parikh', style: const TextStyle(fontFamily: 'cursive', fontStyle: FontStyle.italic, fontSize: 20, color: AppColors.primaryDark, fontWeight: FontWeight.w600))),
            Container(width: 110, height: 1, color: _ink),
            Text(isRx ? 'Consulting physician' : 'Pathologist, MD', style: _t(9, c: _inkSoft)),
          ]),
        ]),
      ]),
    );
  }

  Widget _letterhead() => Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.add_rounded, color: Colors.white, size: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.source, style: _t(14, w: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('NABL accredited · via ${AppConfig.appName}', style: _t(9, c: _inkSoft)),
        ])),
        Text(fmtDateShort(record.date), style: _t(10, w: FontWeight.w700, c: _inkSoft)),
      ]);

  Widget _patientBlock() {
    Widget kv(String k, String v) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: _t(9, c: _inkSoft)), Text(v, style: _t(11, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)]));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF2F7F9), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Row(children: [kv('Patient', 'Amit Marthak'), kv('Age / Sex', '32 Y / Male')]),
        const SizedBox(height: 8),
        Row(children: [kv('Sample ID', 'MQ-${record.id.hashCode.abs() % 900000 + 100000}'), kv('Reported', fmtDateShort(record.date))]),
      ]),
    );
  }

  List<Widget> _table() {
    final rows = _rowsFor(record.title);
    Widget cell(String s, {int flex = 1, TextStyle? st, TextAlign a = TextAlign.left}) => Expanded(flex: flex, child: Text(s, style: st ?? _t(10.5), textAlign: a, maxLines: 1, overflow: TextOverflow.ellipsis));
    return [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(6)),
        child: Row(children: [
          cell('TEST', flex: 5, st: _t(9, w: FontWeight.w800, c: AppColors.primaryDark)),
          cell('RESULT', flex: 3, st: _t(9, w: FontWeight.w800, c: AppColors.primaryDark), a: TextAlign.right),
          cell('RANGE', flex: 4, st: _t(9, w: FontWeight.w800, c: AppColors.primaryDark), a: TextAlign.right),
        ]),
      ),
      for (final r in rows)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            color: r.flag != null ? AppColors.danger.withValues(alpha: .07) : null,
            border: const Border(bottom: BorderSide(color: _line)),
          ),
          child: Row(children: [
            cell(r.test, flex: 5, st: _t(10.5, w: FontWeight.w600)),
            Expanded(
              flex: 3,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Flexible(child: Text(r.result, style: _t(11, w: FontWeight.w800, c: r.flag != null ? AppColors.danger : _ink), maxLines: 1)),
                if (r.flag != null) Padding(padding: const EdgeInsets.only(left: 3), child: Text(r.flag!, style: _t(9, w: FontWeight.w800, c: AppColors.danger))),
              ]),
            ),
            Expanded(flex: 4, child: Text('${r.range} ${r.unit}', style: _t(9.5, c: _inkSoft), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      const SizedBox(height: 10),
      Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: .8), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('Out of reference range', style: _t(9, c: _inkSoft)),
      ]),
    ];
  }

  List<Widget> _rx() {
    const meds = [
      ('Paracetamol 650 mg', '1-1-1 · 5 days · After food'),
      ('Cetirizine 10 mg', '0-0-1 · 5 days · At bedtime'),
      ('ORS Sachet', '1-0-1 · 3 days · In 1L water'),
    ];
    return [
      Text('℞', style: _t(34, w: FontWeight.w800, c: AppColors.primary)),
      for (var i = 0; i < meds.length; i++)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _line))),
          child: Row(children: [
            Container(width: 22, height: 22, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), shape: BoxShape.circle), child: Text('${i + 1}', style: _t(10, w: FontWeight.w800, c: AppColors.primaryDark))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meds[i].$1, style: _t(12, w: FontWeight.w700)), Text(meds[i].$2, style: _t(10, c: _inkSoft))])),
          ]),
        ),
      const SizedBox(height: 10),
      Text('Advice: Plenty of fluids and rest. Review if fever persists beyond 3 days.', style: _t(10, c: _inkSoft)),
    ];
  }
}

/// Painter for a pseudo radiograph (chest or knee).
class XRayPainter extends CustomPainter {
  XRayPainter({required this.knee});
  final bool knee;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..shader = const RadialGradient(colors: [Color(0xFF2A2F33), Color(0xFF07090A)], radius: .85).createShader(Offset.zero & size));
    final soft = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    if (knee) {
      _knee(canvas, w, h, soft);
    } else {
      _chest(canvas, w, h, soft);
    }
    // film grain / vignette
    final rnd = math.Random(3);
    final grain = Paint()..color = Colors.white.withValues(alpha: .035);
    for (var i = 0; i < 700; i++) {
      canvas.drawCircle(Offset(rnd.nextDouble() * w, rnd.nextDouble() * h), rnd.nextDouble() * 1.2, grain);
    }
  }

  void _chest(Canvas c, double w, double h, Paint soft) {
    Paint fill(double a) => Paint()..color = Colors.white.withValues(alpha: a);
    // body silhouette
    c.drawOval(Rect.fromCenter(center: Offset(w / 2, h * .55), width: w * .86, height: h * .98), soft..color = Colors.white.withValues(alpha: .1));
    // lungs (darker)
    for (final dx in [-1.0, 1.0]) {
      final r = Rect.fromCenter(center: Offset(w / 2 + dx * w * .2, h * .46), width: w * .32, height: h * .5);
      c.drawOval(r, Paint()..shader = RadialGradient(colors: [Colors.black.withValues(alpha: .65), Colors.black.withValues(alpha: .0)]).createShader(r)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
    // heart shadow
    c.drawOval(Rect.fromCenter(center: Offset(w * .55, h * .56), width: w * .26, height: h * .27), fill(.22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    // spine
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w / 2, h * .5), width: w * .05, height: h * .78), const Radius.circular(8)), fill(.28)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    for (var i = 0; i < 14; i++) {
      c.drawOval(Rect.fromCenter(center: Offset(w / 2, h * (.14 + i * .054)), width: w * .06, height: h * .02), fill(.22));
    }
    // ribs
    final rib = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
    for (var i = 0; i < 9; i++) {
      final y = h * (.2 + i * .055);
      for (final s in [-1.0, 1.0]) {
        final p = Path()
          ..moveTo(w / 2 + s * w * .03, y)
          ..quadraticBezierTo(w / 2 + s * w * .3, y - h * .05, w / 2 + s * w * .41, y + h * (.05 + i * .006));
        c.drawPath(p, rib);
      }
    }
    // clavicles
    final cl = Paint()..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round..color = Colors.white.withValues(alpha: .42)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final s in [-1.0, 1.0]) {
      c.drawPath(Path()..moveTo(w / 2 + s * w * .04, h * .15)..quadraticBezierTo(w / 2 + s * w * .22, h * .12, w / 2 + s * w * .4, h * .17), cl);
    }
    // diaphragm glow
    c.drawOval(Rect.fromCenter(center: Offset(w / 2, h * .78), width: w * .7, height: h * .14), fill(.16)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
  }

  void _knee(Canvas c, double w, double h, Paint soft) {
    Paint fill(double a) => Paint()..color = Colors.white.withValues(alpha: a);
    // soft tissue
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .22, 0, w * .56, h), const Radius.circular(60)), soft..color = Colors.white.withValues(alpha: .08));
    final femur = Path()
      ..moveTo(w * .42, 0)
      ..lineTo(w * .58, 0)
      ..cubicTo(w * .57, h * .3, w * .64, h * .38, w * .67, h * .45)
      ..quadraticBezierTo(w * .5, h * .5, w * .33, h * .45)
      ..cubicTo(w * .36, h * .38, w * .43, h * .3, w * .42, 0)
      ..close();
    final tibia = Path()
      ..moveTo(w * .34, h * .54)
      ..quadraticBezierTo(w * .5, h * .58, w * .66, h * .54)
      ..cubicTo(w * .62, h * .7, w * .58, h * .85, w * .57, h)
      ..lineTo(w * .43, h)
      ..cubicTo(w * .42, h * .85, w * .38, h * .7, w * .34, h * .54)
      ..close();
    final bone = Paint()..shader = LinearGradient(colors: [Colors.white.withValues(alpha: .55), Colors.white.withValues(alpha: .25), Colors.white.withValues(alpha: .5)]).createShader(Rect.fromLTWH(w * .3, 0, w * .4, h));
    c.drawPath(femur, bone);
    c.drawPath(tibia, bone);
    c.drawOval(Rect.fromCenter(center: Offset(w * .5, h * .46), width: w * .14, height: h * .08), fill(.5)); // patella
    c.drawOval(Rect.fromCenter(center: Offset(w * .72, h * .66), width: w * .05, height: h * .5), fill(.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)); // fibula
    // joint space
    c.drawLine(Offset(w * .36, h * .5), Offset(w * .64, h * .5), Paint()..color = Colors.black.withValues(alpha: .6)..strokeWidth = 5..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  @override
  bool shouldRepaint(covariant XRayPainter old) => old.knee != knee;
}
