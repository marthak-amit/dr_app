import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Horizontal strip of the next [days] days.
class DateStrip extends StatelessWidget {
  const DateStrip({super.key, required this.selected, required this.onChanged, this.days = 14});
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final int days;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final today = dateOnly(DateTime.now());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(DateFormat('MMMM yyyy').format(selected), style: context.tt.titleSmall),
      const SizedBox(height: 12),
      SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: days,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final d = today.add(Duration(days: i));
            final sel = isSameDay(d, selected);
            return TapScale(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                decoration: BoxDecoration(
                  color: sel ? p.primary : p.surface,
                  borderRadius: AppRadius.rMd,
                  border: Border.all(color: sel ? p.primary : p.border),
                  boxShadow: sel ? [BoxShadow(color: p.primary.withValues(alpha: .3), blurRadius: 14, offset: const Offset(0, 5))] : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(i == 0 ? 'Today' : DateFormat('EEE').format(d), maxLines: 1, style: context.tt.labelSmall!.copyWith(color: sel ? p.onPrimary.withValues(alpha: .85) : p.textSecondary)),
                  const SizedBox(height: 6),
                  Text('${d.day}', style: context.tt.titleLarge!.copyWith(color: sel ? p.onPrimary : p.textPrimary)),
                  const SizedBox(height: 4),
                  Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? p.onPrimary : Colors.transparent)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

/// Slots for [date], grouped morning / afternoon / evening.
class SlotGrid extends ConsumerWidget {
  const SlotGrid({super.key, required this.doctorId, required this.date, required this.selected, required this.onSelect, this.showLegend = true});
  final String doctorId;
  final DateTime date;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final bool showLegend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (doctorId, dateOnly(date));
    final async = ref.watch(slotsProvider(key));
    return async.when(
      loading: () => const _SlotShimmer(),
      error: (_, __) => ErrorState(title: 'Could not load slots', message: 'Please check your connection and try again.', onRetry: () => ref.invalidate(slotsProvider(key))),
      data: (slots) {
        final available = slots.where((s) => s.available).length;
        if (available == 0) {
          return EmptyState(icon: Icons.event_busy_rounded, title: 'No slots available', message: 'This doctor is fully booked on this day. Try another date.', color: context.pal.warning);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final period in SlotPeriod.values) ...[
            _Group(period: period, slots: slots.where((s) => s.period == period).toList(), selected: selected, onSelect: onSelect),
            const SizedBox(height: 16),
          ],
          if (showLegend) const _Legend(),
        ]);
      },
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.period, required this.slots, required this.selected, required this.onSelect});
  final SlotPeriod period;
  final List<Slot> slots;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final (label, icon) = switch (period) {
      SlotPeriod.morning => ('Morning', Icons.wb_twilight_rounded),
      SlotPeriod.afternoon => ('Afternoon', Icons.wb_sunny_rounded),
      SlotPeriod.evening => ('Evening', Icons.nights_stay_rounded),
    };
    final free = slots.where((s) => s.available).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: p.warning),
        const SizedBox(width: 8),
        Text(label, style: context.tt.titleSmall),
        const SizedBox(width: 8),
        Text('$free slots', style: context.tt.bodySmall),
      ]),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (context, c) {
        const gap = 8.0;
        final w = (c.maxWidth - gap * 2) / 3;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          for (final s in slots)
            SizedBox(
              width: w,
              child: SlotChip(
                label: fmtTime(s.time),
                selected: selected != null && selected!.isAtSameMomentAs(s.time),
                disabled: !s.available,
                onTap: () => onSelect(s.time),
              ),
            ),
        ]);
      }),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget dot(Color c, String t, {bool border = false}) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4), border: border ? Border.all(color: p.border) : null)),
          const SizedBox(width: 6),
          Text(t, style: context.tt.bodySmall),
        ]);
    return Wrap(spacing: 16, runSpacing: 6, children: [dot(p.surface, 'Available', border: true), dot(p.primary, 'Selected'), dot(p.surfaceAlt, 'Booked')]);
  }
}

class _SlotShimmer extends StatelessWidget {
  const _SlotShimmer();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - 16) / 3;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var g = 0; g < 2; g++) ...[
          const ShimmerBox(width: 110, height: 16),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < 6; i++) ShimmerBox(width: w, height: 44, radius: 12)]),
          const SizedBox(height: 20),
        ],
      ]);
    });
  }
}
