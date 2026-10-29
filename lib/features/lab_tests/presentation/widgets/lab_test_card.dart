import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

class LabTestCard extends StatelessWidget {
  const LabTestCard({super.key, required this.test, required this.qty, required this.onAdd, required this.onInc, required this.onDec, this.index = 0});
  final LabTest test;
  final int qty;
  final VoidCallback onAdd, onInc, onDec;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rMd), child: Center(child: SvgIcon(test.icon, size: 24, color: p.primary))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(test.name, style: context.tt.titleSmall),
              const SizedBox(height: 3),
              Text(test.description, style: context.tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [
          StatusChip(label: '${test.testsCount} tests', color: p.primary, bg: p.primarySoft, dense: true),
          StatusChip(label: 'Report in ${test.reportIn}', color: p.success, bg: p.successSoft, icon: Icons.schedule_rounded, dense: true),
          if (test.fasting) StatusChip(label: 'Fasting', color: p.warning, bg: p.warningSoft, icon: Icons.no_food_rounded, dense: true),
          if (test.popular) StatusChip(label: 'Popular', color: p.accent, bg: p.accentSoft, icon: Icons.local_fire_department_rounded, dense: true),
        ]),
        const SizedBox(height: 12),
        Divider(color: p.border),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
              Text(rupees(test.price), style: context.tt.titleMedium),
              Text(rupees(test.mrp), style: context.tt.bodySmall!.copyWith(decoration: TextDecoration.lineThrough, color: p.textTertiary)),
              Text('${test.discountPct}% off', style: context.tt.labelSmall!.copyWith(color: p.success)),
            ]),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
            child: qty == 0
                ? AppButton(key: const ValueKey('add'), label: 'Add', icon: Icons.add_rounded, size: AppButtonSize.small, expand: false, variant: AppButtonVariant.secondary, onPressed: onAdd)
                : _Stepper(key: const ValueKey('step'), qty: qty, onInc: onInc, onDec: onDec),
          ),
        ]),
      ]),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 320.ms).slideY(begin: .08, curve: Curves.easeOutCubic);
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({super.key, required this.qty, required this.onInc, required this.onDec});
  final int qty;
  final VoidCallback onInc, onDec;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget btn(IconData i, VoidCallback f) => TapScale(onTap: f, child: SizedBox(width: 36, height: 36, child: Icon(i, size: 20, color: p.onPrimary)));
    return Container(
      decoration: BoxDecoration(color: p.primary, borderRadius: AppRadius.rSm),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded, onDec),
        SizedBox(width: 22, child: Text('$qty', textAlign: TextAlign.center, style: context.tt.labelLarge!.copyWith(color: p.onPrimary))),
        btn(Icons.add_rounded, onInc),
      ]),
    );
  }
}
