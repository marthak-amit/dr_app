import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

/// Small "DOCTOR VIEW" pill shown in headers.
class DoctorModeChip extends StatelessWidget {
  const DoctorModeChip({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: p.accentSoft, borderRadius: AppRadius.rPill, border: Border.all(color: p.accent.withValues(alpha: .35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.medical_services_rounded, size: 11, color: p.accent),
        const SizedBox(width: 5),
        Text('DOCTOR VIEW', style: context.tt.labelSmall!.copyWith(color: p.accent, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: .6)),
      ]),
    );
  }
}

/// Round token number badge.
class TokenBadge extends StatelessWidget {
  const TokenBadge({super.key, required this.token, this.size = 44, this.highlight = false, this.muted = false});
  final int token;
  final double size;
  final bool highlight, muted;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final bg = muted ? p.surfaceAlt : (highlight ? p.primary : p.primarySoft);
    final fg = muted ? p.textTertiary : (highlight ? p.onPrimary : p.primary);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .32)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('TOKEN', style: TextStyle(fontSize: size * .15, color: fg.withValues(alpha: .8), fontWeight: FontWeight.w700, height: 1)),
        Text('$token', style: TextStyle(fontSize: size * .4, color: fg, fontWeight: FontWeight.w800, height: 1.1)),
      ]),
    );
  }
}

class PatientAvatar extends StatelessWidget {
  const PatientAvatar({super.key, required this.patient, this.size = 48});
  final Patient patient;
  final double size;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final colors = [p.primary, p.accent, p.warning, p.success];
    final c = colors[patient.name.length % colors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.withValues(alpha: .14), shape: BoxShape.circle),
      child: Text(patient.initials, style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: size * .34, fontWeight: FontWeight.w800, color: c)),
    );
  }
}

/// Card tile with icon, big value and caption.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.label, required this.value, required this.color, required this.bg, this.suffix = '', this.prefix = '', this.isInt = true, this.fractionDigits = 0});
  final IconData icon;
  final String label, suffix, prefix;
  final double value;
  final Color color, bg;
  final bool isInt;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rSm), child: Icon(icon, size: 20, color: color)),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) {
            final s = isInt ? _fmt(v.round()) : v.toStringAsFixed(fractionDigits);
            return FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('$prefix$s$suffix', style: context.tt.headlineSmall));
          },
        ),
        const SizedBox(height: 2),
        Text(label, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  String _fmt(int v) => prefix == '₹' ? rupees(v).substring(1) : '$v';
}

/// Section card with title.
Widget animIn(Widget w, int i) => w.animate().fadeIn(duration: 350.ms, delay: (60 * i).ms).slideY(begin: .06, end: 0, duration: 350.ms, delay: (60 * i).ms, curve: Curves.easeOutCubic);

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, required this.color, required this.bg, this.icon});
  final String label;
  final Color color, bg;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => StatusChip(label: label, color: color, bg: bg, icon: icon);
}
