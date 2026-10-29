import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

/// Header: circular progress ("3 of 6 taken") + next dose.
class ReminderHeader extends StatelessWidget {
  const ReminderHeader({super.key, required this.items});
  final List<MedicineReminder> items;

  @override
  Widget build(BuildContext context) {
    final taken = items.where((e) => e.taken).length;
    final frac = items.isEmpty ? 0.0 : taken / items.length;
    final now = TimeOfDay.now();
    int mins(TimeOfDay t) => t.hour * 60 + t.minute;
    final pending = items.where((e) => !e.taken).toList();
    final next = pending.where((e) => mins(e.time) >= mins(now)).firstOrNull ?? pending.firstOrNull;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        SizedBox(
          width: 84,
          height: 84,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: frac),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Stack(alignment: Alignment.center, children: [
              SizedBox.expand(child: CircularProgressIndicator(value: 1, strokeWidth: 8, color: Colors.white.withValues(alpha: .2))),
              SizedBox.expand(child: CircularProgressIndicator(value: v, strokeWidth: 8, strokeCap: StrokeCap.round, color: Colors.white)),
              Text('$taken/${items.length}', style: context.tt.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(items.isNotEmpty && taken == items.length ? 'All done for today! 🎉' : '$taken of ${items.length} taken', style: context.tt.titleMedium!.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            if (next != null) ...[
              Text('NEXT DOSE', style: context.tt.labelSmall!.copyWith(color: Colors.white70, letterSpacing: 1.2)),
              Text(next.medicine, style: context.tt.titleSmall!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${fmtTimeOfDay(next.time)} · ${next.dose}', style: context.tt.bodySmall!.copyWith(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
            ] else
              Text('Great adherence — keep it up.', style: context.tt.bodySmall!.copyWith(color: Colors.white70)),
          ]),
        ),
      ]),
    );
  }
}

/// One timeline row: time | dot+line | card with big check.
class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.item, required this.first, required this.last, required this.onToggle});
  final MedicineReminder item;
  final bool first, last;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final taken = item.taken;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 62, child: Padding(padding: const EdgeInsets.only(top: 18), child: Text(fmtTimeOfDay(item.time), style: context.tt.labelMedium!.copyWith(color: taken ? p.textTertiary : p.textPrimary), maxLines: 1))),
        SizedBox(
          width: 22,
          child: Column(children: [
            Container(width: 2, height: 22, color: first ? Colors.transparent : p.border),
            AnimatedContainer(duration: const Duration(milliseconds: 250), width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: taken ? p.success : p.surface, border: Border.all(color: taken ? p.success : p.primary, width: 2.5))),
            Expanded(child: Container(width: 2, color: last ? Colors.transparent : p.border)),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              decoration: BoxDecoration(color: taken ? p.successSoft : p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: taken ? p.success.withValues(alpha: .35) : p.border)),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: p.surface.withValues(alpha: taken ? .6 : 1), borderRadius: AppRadius.rSm, border: Border.all(color: p.border)), child: Center(child: SvgIcon('pill', size: 20, color: taken ? p.success : p.primary))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.medicine, style: context.tt.titleSmall!.copyWith(decoration: taken ? TextDecoration.lineThrough : null, color: taken ? p.textSecondary : p.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${item.dose} · ${item.note}', style: context.tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                const SizedBox(width: 8),
                TapScale(
                  scale: .85,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onToggle();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: taken ? p.success : Colors.transparent, border: Border.all(color: taken ? p.success : p.textTertiary, width: 2)),
                    child: AnimatedScale(scale: taken ? 1 : 0, duration: const Duration(milliseconds: 250), curve: Curves.easeOutBack, child: const Icon(Icons.check_rounded, color: Colors.white, size: 22)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
