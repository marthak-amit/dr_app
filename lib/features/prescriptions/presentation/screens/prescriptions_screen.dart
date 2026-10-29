import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/prescription_filter_provider.dart';

class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prescriptionsProvider);
    final filter = ref.watch(prescriptionPatientFilterProvider);
    final query = ref.watch(prescriptionQueryProvider).trim().toLowerCase();
    final p = context.pal;

    return Scaffold(
      appBar: const AppTopBar(title: 'Prescriptions'),
      body: async.when(
        loading: () => const ShimmerList(itemCount: 5, itemHeight: 140),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(prescriptionsProvider)),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(icon: Icons.description_outlined, title: 'No prescriptions yet', message: 'Prescriptions from your doctors will appear here after each consultation.', actionLabel: 'Book a consultation', onAction: () => context.push(Routes.search()));
          }
          final patients = {for (final r in all) r.patientName}.toList();
          final list = all.where((r) {
            if (filter.isNotEmpty && r.patientName != filter) return false;
            if (query.isEmpty) return true;
            final d = doctorById(r.doctorId);
            return r.diagnosis.toLowerCase().contains(query) || d.name.toLowerCase().contains(query) || r.medicines.any((m) => m.name.toLowerCase().contains(query));
          }).toList();
          return RefreshIndicator(
            color: p.primary,
            onRefresh: () async {
              ref.invalidate(prescriptionsProvider);
              await ref.read(prescriptionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                _SearchBar(onChanged: (v) => ref.read(prescriptionQueryProvider.notifier).state = v),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    ChoicePill(label: 'All', selected: filter.isEmpty, onTap: () => ref.read(prescriptionPatientFilterProvider.notifier).state = ''),
                    for (final n in patients) ...[
                      const SizedBox(width: 8),
                      ChoicePill(label: n.split(' ').first, icon: Icons.person_rounded, selected: filter == n, onTap: () => ref.read(prescriptionPatientFilterProvider.notifier).state = n),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  Padding(padding: const EdgeInsets.only(top: 40), child: EmptyState(icon: Icons.search_off_rounded, title: 'No matches', message: 'Try a different name, medicine or patient filter.', actionLabel: 'Clear filters', onAction: () {
                    ref.read(prescriptionPatientFilterProvider.notifier).state = '';
                    ref.read(prescriptionQueryProvider.notifier).state = '';
                  }))
                else
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _RxCard(rx: list[i], onTap: () => context.push(Routes.prescription(list[i].id))).animate().fadeIn(delay: (60 * i).ms, duration: 300.ms).slideY(begin: .1),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => AppTextField(hint: 'Search diagnosis, doctor or medicine', prefixIcon: Icons.search_rounded, onChanged: onChanged);
}

class _RxCard extends StatelessWidget {
  const _RxCard({required this.rx, required this.onTap});
  final Prescription rx;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final d = doctorById(rx.doctorId);
    final shown = rx.medicines.take(2).toList();
    final more = rx.medicines.length - shown.length;
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          DoctorAvatar(doctor: d, size: 52, hero: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rx.diagnosis, style: context.tt.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${d.name} · ${d.specialty}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: p.textTertiary),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in shown) StatusChip(label: m.name, color: p.primary, bg: p.primarySoft, icon: Icons.medication_rounded, dense: true),
          if (more > 0) StatusChip(label: '+$more more', color: p.textSecondary, bg: p.surfaceAlt, dense: true),
        ]),
        const SizedBox(height: 12),
        Divider(color: p.border),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.person_outline_rounded, size: 16, color: p.textTertiary),
          const SizedBox(width: 4),
          Expanded(child: Text(rx.patientName, style: context.tt.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Icon(Icons.calendar_today_rounded, size: 14, color: p.textTertiary),
          const SizedBox(width: 6),
          Text(fmtDateShort(rx.date), style: context.tt.bodySmall),
        ]),
      ]),
    );
  }
}
