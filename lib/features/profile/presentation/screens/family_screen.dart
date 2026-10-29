import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../widgets/add_member_sheet.dart';
import '../../widgets/settings_widgets.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final async = ref.watch(familyProvider);

    void add() => showAppBottomSheet<void>(context, title: 'Add family member', builder: (ctx) => AddMemberSheet(onAdd: (m) {
          ref.read(familyProvider.notifier).add(m);
          showAppSnack(context, '${m.name} added to your family', icon: Icons.person_add_alt_1_rounded);
        }));

    return Scaffold(
      appBar: AppTopBar(title: 'Family members', actions: [AppIconButton(icon: Icons.add_rounded, onTap: add, size: 42, tooltip: 'Add member')]),
      body: AsyncBody<List<Patient>>(
        value: async,
        onRetry: () => ref.invalidate(familyProvider),
        loading: const ShimmerList(itemHeight: 118, itemCount: 4),
        builder: (list) => RefreshIndicator(
          color: p.primary,
          onRefresh: () async {
            ref.invalidate(familyProvider);
            await ref.read(familyProvider.future);
          },
          child: list.isEmpty
              ? ListView(children: [
                  SizedBox(
                    height: 480,
                    child: EmptyState(icon: Icons.family_restroom_rounded, title: 'No family members yet', message: 'Add your loved ones to book appointments and manage their records in one place.', actionLabel: 'Add member', onAction: add),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 120),
                  itemCount: list.length + 1,
                  separatorBuilder: (_, __) => Gap.v(14),
                  itemBuilder: (ctx, i) {
                    if (i == list.length) {
                      return AppButton(label: 'Add family member', variant: AppButtonVariant.outline, icon: Icons.add_rounded, onPressed: add);
                    }
                    final m = list[i];
                    final card = _MemberCard(
                      member: m,
                      onTap: () => _showDetails(context, m),
                      onRemove: m.relation == 'Self' ? null : () => _remove(context, ref, m),
                    );
                    final w = m.relation == 'Self'
                        ? card
                        : Dismissible(
                            key: ValueKey(m.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => showConfirmSheet(context, title: 'Remove ${m.name.split(' ').first}?', message: 'They will be removed from your family list. You can undo right after.', confirmLabel: 'Remove', destructive: true, icon: Icons.person_remove_rounded),
                            onDismissed: (_) => _doRemove(context, ref, m, i),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(color: p.dangerSoft, borderRadius: AppRadius.rLg),
                              child: Icon(Icons.delete_rounded, color: p.danger),
                            ),
                            child: card,
                          );
                    return w.animate().fadeIn(delay: (70 * i).ms, duration: 350.ms).slideY(begin: .08, end: 0, delay: (70 * i).ms, duration: 350.ms, curve: Curves.easeOutCubic);
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, Patient m) async {
    final ok = await showConfirmSheet(context, title: 'Remove ${m.name.split(' ').first}?', message: 'They will be removed from your family list. You can undo right after.', confirmLabel: 'Remove', destructive: true, icon: Icons.person_remove_rounded);
    if (ok && context.mounted) _doRemove(context, ref, m, 0);
  }

  void _doRemove(BuildContext context, WidgetRef ref, Patient m, int index) {
    ref.read(familyProvider.notifier).remove(m.id);
    showAppSnack(context, '${m.name} removed', icon: Icons.delete_outline_rounded, action: SnackBarAction(label: 'UNDO', textColor: Colors.white, onPressed: () => ref.read(familyProvider.notifier).add(m)));
  }

  void _showDetails(BuildContext context, Patient m) {
    showAppBottomSheet<void>(context, title: m.name, builder: (ctx) {
      final p = ctx.pal;
      Widget row(String k, String v) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [Expanded(child: Text(k, style: ctx.tt.bodyMedium)), Gap.h(12), Flexible(child: Text(v, style: ctx.tt.titleSmall, textAlign: TextAlign.end))]),
          );
      return Column(children: [
        InitialsAvatar(initials: m.initials, size: 72, bg: _tint(m, p), fg: _fg(m, p)),
        Gap.v(12),
        row('Relation', m.relation),
        Divider(color: p.border),
        row('Age / Gender', '${m.age} yrs · ${m.gender == Gender.male ? 'Male' : 'Female'}'),
        Divider(color: p.border),
        row('Blood group', m.bloodGroup),
        Divider(color: p.border),
        row('Allergies', m.allergies.isEmpty ? 'None reported' : m.allergies.join(', ')),
        Divider(color: p.border),
        row('Conditions', m.conditions.isEmpty ? 'None reported' : m.conditions.join(', ')),
        Gap.v(20),
        AppButton(label: 'Book for ${m.name.split(' ').first}', icon: Icons.calendar_month_rounded, onPressed: () {
          Navigator.pop(ctx);
          showAppSnack(context, 'Choose a doctor to book for ${m.name.split(' ').first}', icon: Icons.search_rounded);
        }),
      ]);
    });
  }
}

Color _tint(Patient m, AppPalette p) => m.gender == Gender.male ? p.primarySoft : p.accentSoft;
Color _fg(Patient m, AppPalette p) => m.gender == Gender.male ? p.primary : p.accent;

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onTap, this.onRemove});
  final Patient member;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final m = member;
    return AppCard(
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InitialsAvatar(initials: m.initials, size: 54, bg: _tint(m, p), fg: _fg(m, p)),
        Gap.h(14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(m.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Gap.h(8),
              StatusChip(label: m.relation, color: p.primary, bg: p.primarySoft, dense: true),
            ]),
            Gap.v(4),
            Text('${m.age} yrs · ${m.gender == Gender.male ? 'Male' : 'Female'} · ${m.bloodGroup}', style: context.tt.bodySmall),
            if (m.allergies.isNotEmpty || m.conditions.isNotEmpty) ...[
              Gap.v(8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final a in m.allergies) StatusChip(label: 'Allergy: $a', color: p.danger, bg: p.dangerSoft, dense: true),
                for (final c in m.conditions) StatusChip(label: c, color: p.warning, bg: p.warningSoft, dense: true),
              ]),
            ],
          ]),
        ),
        if (onRemove != null)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: p.textTertiary),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
            onSelected: (v) => v == 'remove' ? onRemove!() : onTap(),
            itemBuilder: (_) => const [PopupMenuItem(value: 'view', child: Text('View details')), PopupMenuItem(value: 'remove', child: Text('Remove'))],
          ),
      ]),
    );
  }
}
