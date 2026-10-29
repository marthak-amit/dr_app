import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../providers/doctor_providers.dart';
import '../widgets/doctor_widgets.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.patientId});
  final String patientId;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _note = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fakeLatency(350, 600).then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final pt = findPatient(widget.patientId);
    final seed = pt.name.length;
    final sys = 118 + seed % 20, dia = 76 + seed % 12, sugar = 94 + (seed * 3) % 40;
    final weight = 58 + (seed * 2) % 24;

    return Scaffold(
      appBar: AppTopBar(title: 'Patient details', actions: [
        AppIconButton(icon: Icons.more_horiz_rounded, size: 42, onTap: () => showAppSnack(context, 'More options coming soon', icon: Icons.more_horiz_rounded)),
      ]),
      body: _loading
          ? const Padding(padding: EdgeInsets.all(20), child: Column(children: [ShimmerBox(height: 120, radius: 24), SizedBox(height: 16), ShimmerBox(height: 90, radius: 20), SizedBox(height: 16), ShimmerBox(height: 200, radius: 20)]))
          : Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
                  animIn(
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        PatientAvatar(patient: pt, size: 64),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(pt.name, style: context.tt.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${pt.age} yrs · ${pt.gender == Gender.male ? 'Male' : 'Female'}', style: context.tt.bodyMedium),
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, runSpacing: 6, children: [
                              StatusChip(label: pt.bloodGroup, color: p.danger, bg: p.dangerSoft, icon: Icons.bloodtype_rounded, dense: true),
                              StatusChip(label: '${pt.visits.length} visits', color: p.primary, bg: p.primarySoft, dense: true),
                            ]),
                          ]),
                        ),
                      ]),
                    ),
                    0,
                  ),
                  const SizedBox(height: 12),
                  animIn(
                    AppCard(
                      onTap: () => showAppSnack(context, 'Calling ${pt.phone}…', icon: Icons.call_rounded),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.phone_rounded, size: 20, color: p.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(pt.phone, style: context.tt.titleSmall)),
                        Container(width: 38, height: 38, decoration: BoxDecoration(color: p.successSoft, shape: BoxShape.circle), child: Icon(Icons.call_rounded, size: 18, color: p.success)),
                      ]),
                    ),
                    1,
                  ),
                  const SizedBox(height: 20),
                  animIn(_Block(title: 'Allergies', child: pt.allergies.isEmpty
                      ? Text('No known allergies', style: context.tt.bodyMedium)
                      : Wrap(spacing: 8, runSpacing: 8, children: [for (final a in pt.allergies) StatusChip(label: a, color: p.danger, bg: p.dangerSoft, icon: Icons.warning_amber_rounded)])), 2),
                  const SizedBox(height: 16),
                  animIn(_Block(title: 'Conditions', child: pt.conditions.isEmpty
                      ? Text('No chronic conditions recorded', style: context.tt.bodyMedium)
                      : Wrap(spacing: 8, runSpacing: 8, children: [for (final a in pt.conditions) StatusChip(label: a, color: p.primary, bg: p.primarySoft)])), 3),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Latest vitals', padding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  animIn(
                    Row(children: [
                      Expanded(child: _Vital(icon: Icons.favorite_rounded, label: 'BP', value: '$sys/$dia', unit: 'mmHg', color: p.danger, bg: p.dangerSoft)),
                      const SizedBox(width: 10),
                      Expanded(child: _Vital(icon: Icons.water_drop_rounded, label: 'Sugar', value: '$sugar', unit: 'mg/dL', color: p.warning, bg: p.warningSoft)),
                      const SizedBox(width: 10),
                      Expanded(child: _Vital(icon: Icons.monitor_weight_rounded, label: 'Weight', value: '$weight', unit: 'kg', color: p.primary, bg: p.primarySoft)),
                    ]),
                    4,
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Past visits', padding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  if (pt.visits.isEmpty)
                    AppCard(padding: const EdgeInsets.all(20), child: Row(children: [
                      Icon(Icons.history_toggle_off_rounded, color: p.textTertiary),
                      const SizedBox(width: 12),
                      Expanded(child: Text('First visit — no history yet.', style: context.tt.bodyMedium)),
                    ]))
                  else
                    for (var i = 0; i < pt.visits.length; i++) animIn(_VisitTile(visit: pt.visits[i], last: i == pt.visits.length - 1), 5 + i),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Reports & files', padding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  _FileTile(icon: Icons.science_rounded, title: 'Lipid profile', meta: '2 months ago · PDF', onTap: () => showAppSnack(context, 'Opening Lipid profile…', icon: Icons.description_rounded)),
                  _FileTile(icon: Icons.monitor_heart_rounded, title: 'ECG report', meta: '3 months ago · PDF', onTap: () => showAppSnack(context, 'Opening ECG report…', icon: Icons.description_rounded)),
                  _FileTile(icon: Icons.image_rounded, title: 'Chest X-ray', meta: '5 months ago · Image', onTap: () => showAppSnack(context, 'Opening Chest X-ray…', icon: Icons.image_rounded)),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Private notes', subtitle: 'Only visible to you', padding: EdgeInsets.zero),
                  const SizedBox(height: 12),
                  AppTextField(controller: _note, hint: 'Add a clinical note…', maxLines: 3),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(label: 'Save note', expand: false, size: AppButtonSize.small, variant: AppButtonVariant.secondary, icon: Icons.save_rounded, onPressed: () {
                      FocusScope.of(context).unfocus();
                      showAppSnack(context, _note.text.trim().isEmpty ? 'Write something first' : 'Note saved to ${pt.name}\'s chart', error: _note.text.trim().isEmpty);
                    }),
                  ),
                ]),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
                child: Row(children: [
                  Expanded(child: AppButton(label: 'Call', icon: Icons.call_rounded, variant: AppButtonVariant.outline, onPressed: () => showAppSnack(context, 'Calling ${pt.name}…', icon: Icons.call_rounded))),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: AppButton(label: 'Write prescription', icon: Icons.edit_note_rounded, onPressed: () => context.push(Routes.drRx(pt.id)))),
                ]),
              ),
            ]),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleMedium), const SizedBox(height: 10), child]);
}

class _Vital extends StatelessWidget {
  const _Vital({required this.icon, required this.label, required this.value, required this.unit, required this.color, required this.bg});
  final IconData icon;
  final String label, value, unit;
  final Color color, bg;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      radius: AppRadius.md,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: color)),
        const SizedBox(height: 8),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: context.tt.titleMedium)),
        Text(unit, style: context.tt.bodySmall, maxLines: 1),
        Text(label, style: context.tt.labelSmall),
      ]),
    );
  }
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({required this.visit, required this.last});
  final PastVisit visit;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 20,
          child: Column(children: [
            const SizedBox(height: 6),
            Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: p.primary, border: Border.all(color: p.primarySoft, width: 3))),
            if (!last) Expanded(child: Container(width: 2, color: p.border)),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fmtDateLong(visit.date), style: context.tt.labelSmall!.copyWith(color: p.primary)),
                const SizedBox(height: 4),
                Text(visit.diagnosis, style: context.tt.titleSmall),
                const SizedBox(height: 4),
                Text(visit.notes, style: context.tt.bodySmall),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.icon, required this.title, required this.meta, required this.onTap});
  final IconData icon;
  final String title, meta;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        shadow: false,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rSm), child: Icon(icon, color: p.primary, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleSmall), Text(meta, style: context.tt.bodySmall)])),
          Icon(Icons.chevron_right_rounded, color: p.textTertiary),
        ]),
      ),
    );
  }
}
