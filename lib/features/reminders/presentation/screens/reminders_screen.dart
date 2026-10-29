import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../widgets/add_reminder_sheet.dart';
import '../widgets/reminder_parts.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  void _add(BuildContext context, WidgetRef ref) {
    showAppBottomSheet<void>(context, title: 'Add reminder', builder: (_) => AddReminderSheet(onAdd: (r) {
      ref.read(remindersProvider.notifier).add(r);
      showAppSnack(context, 'Reminder set for ${fmtTimeOfDay(r.time)}', icon: Icons.alarm_on_rounded);
    }));
  }

  static String _group(MedicineReminder r) {
    final h = r.time.hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    if (h < 21) return 'Evening';
    return 'Night';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(remindersProvider);
    final p = context.pal;
    return Scaffold(
      appBar: AppTopBar(title: 'Medicine reminders', actions: [
        AppIconButton(icon: Icons.add_rounded, size: 42, onTap: () => _add(context, ref), tooltip: 'Add reminder'),
      ]),
      floatingActionButton: async.hasValue && (async.value?.isNotEmpty ?? false)
          ? TapScale(
              onTap: () => _add(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(gradient: AppColors.gradientAccent, borderRadius: AppRadius.rPill, boxShadow: [BoxShadow(color: p.accent.withValues(alpha: .4), blurRadius: 16, offset: const Offset(0, 6))]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.alarm_add_rounded, color: Colors.white), const SizedBox(width: 8), Text('Add reminder', style: context.tt.labelLarge!.copyWith(color: Colors.white))]),
              ),
            )
          : null,
      body: async.when(
        loading: () => const ShimmerList(itemCount: 5, itemHeight: 84),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(remindersProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(icon: Icons.alarm_off_rounded, title: 'No reminders yet', message: 'Add your medicines and we\'ll nudge you on time, every time.', actionLabel: 'Add reminder', onAction: () => _add(context, ref));
          }
          const order = ['Morning', 'Afternoon', 'Evening', 'Night'];
          final groups = {for (final g in order) g: items.where((e) => _group(e) == g).toList()};
          return RefreshIndicator(
            color: p.primary,
            onRefresh: () async {
              ref.invalidate(remindersProvider);
              await ref.read(remindersProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
              children: [
                ReminderHeader(items: items).animate().fadeIn(duration: 350.ms).slideY(begin: .08),
                const SizedBox(height: 20),
                Text("Today's schedule", style: context.tt.titleLarge),
                const SizedBox(height: 4),
                Text('Swipe left to delete · tap the circle to mark as taken', style: context.tt.bodySmall),
                const SizedBox(height: 14),
                for (final g in order)
                  if (groups[g]!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Row(children: [
                        Icon(switch (g) { 'Morning' => Icons.wb_twilight_rounded, 'Afternoon' => Icons.wb_sunny_rounded, 'Evening' => Icons.wb_cloudy_rounded, _ => Icons.nightlight_round }, size: 18, color: p.primary),
                        const SizedBox(width: 8),
                        Text(g.toUpperCase(), style: context.tt.labelSmall!.copyWith(letterSpacing: 1.2, color: p.primary)),
                      ]),
                    ),
                    for (var i = 0; i < groups[g]!.length; i++) _row(context, ref, groups[g]![i], i, groups[g]!.length),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, WidgetRef ref, MedicineReminder r, int i, int n) {
    final p = context.pal;
    return Dismissible(
      key: ValueKey(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 92),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: p.dangerSoft, borderRadius: AppRadius.rMd),
        child: Icon(Icons.delete_outline_rounded, color: p.danger),
      ),
      onDismissed: (_) {
        ref.read(remindersProvider.notifier).remove(r.id);
        showAppSnack(context, '${r.medicine} reminder deleted', icon: Icons.delete_outline_rounded, action: SnackBarAction(label: 'UNDO', textColor: const Color(0xFF5EEAC0), onPressed: () => ref.read(remindersProvider.notifier).add(r)));
      },
      child: ReminderTile(
        item: r,
        first: i == 0,
        last: i == n - 1,
        onToggle: () {
          ref.read(remindersProvider.notifier).toggle(r.id);
          if (!r.taken) showAppSnack(context, '${r.medicine} marked as taken', icon: Icons.check_circle_rounded);
        },
      ),
    ).animate().fadeIn(delay: (50 * i).ms, duration: 280.ms).slideX(begin: .04);
  }
}
