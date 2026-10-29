import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tap_scale.dart';

class SlotChip extends StatelessWidget {
  const SlotChip({super.key, required this.label, required this.selected, this.disabled = false, this.onTap});
  final String label;
  final bool selected, disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final Color bg = disabled ? p.surfaceAlt.withValues(alpha: .6) : (selected ? p.primary : p.surface);
    final Color fg = disabled ? p.textTertiary : (selected ? p.onPrimary : p.textPrimary);
    return TapScale(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.rSm,
          border: Border.all(color: selected ? p.primary : p.border),
          boxShadow: selected ? [BoxShadow(color: p.primary.withValues(alpha: .3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          style: context.tt.labelMedium!.copyWith(color: fg, decoration: disabled ? TextDecoration.lineThrough : null, fontWeight: selected ? FontWeight.w700 : FontWeight.w600),
        ),
      ),
    );
  }
}

/// Generic selectable pill (filters, dosage chips, etc.)
class ChoicePill extends StatelessWidget {
  const ChoicePill({super.key, required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? p.primary : p.surface,
          borderRadius: AppRadius.rPill,
          border: Border.all(color: selected ? p.primary : p.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 16, color: selected ? p.onPrimary : p.textSecondary), const SizedBox(width: 6)],
          Text(label, style: context.tt.labelMedium!.copyWith(color: selected ? p.onPrimary : p.textPrimary)),
        ]),
      ),
    );
  }
}
