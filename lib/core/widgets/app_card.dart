import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tap_scale.dart';

/// Rounded surface with soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = AppRadius.lg,
    this.border = true,
    this.shadow = true,
    this.gradient,
    this.margin,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  final bool border, shadow;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? p.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border && gradient == null ? Border.all(color: p.border.withValues(alpha: p.isDark ? 1 : .7)) : null,
        boxShadow: shadow && !p.isDark ? [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, 8))] : null,
      ),
      child: child,
    );
    return onTap == null ? box : TapScale(onTap: onTap, scale: .98, child: box);
  }
}

/// Small pill label, e.g. status / tags.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, required this.bg, this.icon, this.dense = false});
  final String label;
  final Color color, bg;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: color), const SizedBox(width: 4)],
        Text(label, style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: dense ? 11 : 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.count});
  final double rating;
  final int? count;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1), style: context.tt.labelMedium),
      if (count != null) Text(' ($count)', style: context.tt.bodySmall!.copyWith(color: p.textTertiary)),
    ]);
  }
}
