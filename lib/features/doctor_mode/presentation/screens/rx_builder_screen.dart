import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../providers/doctor_providers.dart';
import '../widgets/doctor_widgets.dart';
import '../widgets/rx_data.dart';

class RxBuilderScreen extends ConsumerStatefulWidget {
  const RxBuilderScreen({super.key, required this.patientId});
  final String patientId;

  @override
  ConsumerState<RxBuilderScreen> createState() => _RxBuilderScreenState();
}

class _RxBuilderScreenState extends ConsumerState<RxBuilderScreen> {
  int _tab = 0;
  final _search = TextEditingController();
  final _diagnosis = TextEditingController();
  final _advice = TextEditingController();
  final _items = <RxItem>[];
  DateTime? _followUp;
  bool _sending = false;
  String _query = '';

  late final Patient _patient = findPatient(widget.patientId);

  @override
  void dispose() {
    _search.dispose();
    _diagnosis.dispose();
    _advice.dispose();
    super.dispose();
  }

  List<DrugEntry> get _matches {
    final q = _query.trim().toLowerCase();
    final already = _items.map((e) => e.drug.label).toSet();
    final list = kFormulary.where((d) => !already.contains(d.label) && (q.isEmpty || d.label.toLowerCase().contains(q)));
    return list.take(q.isEmpty ? 8 : 6).toList();
  }

  void _add(DrugEntry d) {
    setState(() {
      _items.add(RxItem(drug: d));
      _search.clear();
      _query = '';
    });
    FocusScope.of(context).unfocus();
    showAppSnack(context, '${d.label} added', icon: Icons.add_circle_rounded);
  }

  void _addAdvice(String s) {
    final cur = _advice.text.trim();
    if (cur.contains(s)) return;
    setState(() => _advice.text = cur.isEmpty ? s : '$cur\n$s');
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final rx = Prescription(
      id: 'rx${DateTime.now().millisecondsSinceEpoch}',
      doctorId: kDoctorModeDoctorId,
      patientName: _patient.name,
      date: DateTime.now(),
      diagnosis: _diagnosis.text.trim().isEmpty ? 'General consultation' : _diagnosis.text.trim(),
      medicines: [for (final i in _items) Medicine(name: i.drug.name, strength: i.drug.strength, dosage: i.dosage, duration: '${i.days} days', instructions: i.instruction)],
      advice: _advice.text.trim(),
      followUp: _followUp,
    );
    ref.read(prescriptionsProvider.notifier).add(rx);
    if (!mounted) return;
    setState(() => _sending = false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final p = ctx.pal;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 140, height: 140, child: Lottie.asset('assets/lottie/success.json', repeat: false, errorBuilder: (_, __, ___) => Icon(Icons.check_circle_rounded, size: 100, color: p.success))),
              const SizedBox(height: 8),
              Text('Prescription sent', style: ctx.tt.titleLarge),
              const SizedBox(height: 6),
              Text('Prescription sent to ${_patient.name}. They can view it in their app instantly.', style: ctx.tt.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              AppButton(label: 'Done', onPressed: () => Navigator.pop(ctx)),
            ]),
          ),
        );
      },
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final canSend = _items.isNotEmpty && !_sending;
    return Scaffold(
      appBar: AppTopBar(title: 'New prescription', actions: [
        TextButton(onPressed: () => showAppSnack(context, 'Draft saved', icon: Icons.save_rounded), child: const Text('Save draft')),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(children: [
            PatientAvatar(patient: _patient, size: 40),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_patient.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${_patient.age} yrs · ${_patient.gender == Gender.male ? 'Male' : 'Female'}${_patient.allergies.isEmpty ? '' : ' · Allergy: ${_patient.allergies.first}'}', style: context.tt.bodySmall!.copyWith(color: _patient.allergies.isEmpty ? null : p.danger), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ),
        _Tabs(index: _tab, labels: ['Medicines (${_items.length})', 'Advice', 'Preview'], onChanged: (i) {
          FocusScope.of(context).unfocus();
          setState(() => _tab = i);
        }),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(_tab),
              child: switch (_tab) { 0 => _medicines(context), 1 => _adviceTab(context), _ => _preview(context) },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
          child: _tab == 2
              ? AppButton(label: 'Send to patient', icon: Icons.send_rounded, loading: _sending, onPressed: canSend ? _send : null, variant: AppButtonVariant.accent)
              : AppButton(label: _tab == 0 ? 'Next: Advice' : 'Preview prescription', trailingIcon: Icons.arrow_forward_rounded, onPressed: () => setState(() => _tab++)),
        ),
      ]),
    );
  }

  Widget _medicines(BuildContext context) {
    final p = context.pal;
    final matches = _matches;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      AppTextField(
        controller: _search,
        hint: 'Search medicine (e.g. Paracetamol)',
        prefixIcon: Icons.search_rounded,
        onChanged: (v) => setState(() => _query = v),
        suffix: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => setState(() {
              _search.clear();
              _query = '';
            })),
      ),
      const SizedBox(height: 12),
      Text(_query.isEmpty ? 'Commonly prescribed' : 'Results', style: context.tt.labelSmall),
      const SizedBox(height: 8),
      if (matches.isEmpty)
        AppCard(padding: const EdgeInsets.all(16), child: Row(children: [Icon(Icons.search_off_rounded, color: p.textTertiary), const SizedBox(width: 10), Expanded(child: Text('No medicine found for "$_query". Try another name.', style: context.tt.bodyMedium))]))
      else
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final d in matches)
            TapScale(
              onTap: () => _add(d),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rPill),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_rounded, size: 16, color: p.primary), const SizedBox(width: 4), Text(d.label, style: context.tt.labelMedium!.copyWith(color: p.primary))]),
              ),
            ),
        ]),
      const SizedBox(height: 20),
      if (_items.isEmpty)
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: p.primarySoft, shape: BoxShape.circle), child: Center(child: SvgIcon('pill', size: 28, color: p.primary))),
            const SizedBox(height: 12),
            Text('No medicines added', style: context.tt.titleMedium),
            Text('Search above or tap a suggestion to start the prescription.', style: context.tt.bodySmall, textAlign: TextAlign.center),
          ]),
        )
      else
        for (var i = 0; i < _items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _MedCard(
              key: ValueKey(_items[i].drug.label),
              item: _items[i],
              index: i,
              onChanged: () => setState(() {}),
              onDelete: () {
                final d = _items[i].drug.label;
                setState(() => _items.removeAt(i));
                showAppSnack(context, '$d removed', icon: Icons.delete_outline_rounded);
              },
            ).animate().fadeIn(duration: 250.ms).slideY(begin: .08, end: 0),
          ),
    ]);
  }

  Widget _adviceTab(BuildContext context) {
    final p = context.pal;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      AppTextField(controller: _diagnosis, label: 'Diagnosis', hint: 'e.g. Essential hypertension', prefixIcon: Icons.medical_information_outlined),
      const SizedBox(height: 18),
      AppTextField(controller: _advice, label: 'Advice & instructions', hint: 'Write advice for the patient…', maxLines: 4),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final a in kAdviceChips) ChoicePill(label: a, selected: _advice.text.contains(a), icon: Icons.add_rounded, onTap: () => _addAdvice(a))]),
      const SizedBox(height: 20),
      Text('Follow-up', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
      const SizedBox(height: 8),
      AppCard(
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _followUp ?? DateTime.now().add(const Duration(days: 14)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) setState(() => _followUp = d);
        },
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rSm), child: Icon(Icons.event_rounded, color: p.primary)),
          const SizedBox(width: 12),
          Expanded(child: Text(_followUp == null ? 'Pick follow-up date' : fmtDateLong(_followUp!), style: context.tt.titleSmall)),
          if (_followUp != null) IconButton(onPressed: () => setState(() => _followUp = null), icon: const Icon(Icons.close_rounded, size: 18)) else Icon(Icons.chevron_right_rounded, color: p.textTertiary),
        ]),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, children: [
        for (final d in [7, 14, 30]) ChoicePill(label: 'In $d days', selected: _followUp != null && isSameDay(_followUp!, DateTime.now().add(Duration(days: d))), onTap: () => setState(() => _followUp = DateTime.now().add(Duration(days: d)))),
      ]),
    ]);
  }

  Widget _preview(BuildContext context) {
    const ink = Color(0xFF1B2A30);
    const muted = Color(0xFF6A7C84);
    final doc = doctorById(kDoctorModeDoctorId);
    final clinic = clinicById(doc.clinicId);
    final tt = context.tt;
    TextStyle s(double size, {FontWeight w = FontWeight.w500, Color c = ink}) => tt.bodyMedium!.copyWith(fontSize: size, fontWeight: w, color: c);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      if (_items.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StatusChip(label: 'Add at least one medicine to send', color: context.pal.warning, bg: context.pal.warningSoft, icon: Icons.info_outline_rounded),
        ),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.rMd, boxShadow: [BoxShadow(color: context.pal.shadow, blurRadius: 24, offset: const Offset(0, 8))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add_rounded, color: Colors.white)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(clinic.name, style: s(15, w: FontWeight.w800, c: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis), Text(clinic.phone, style: s(11, c: muted))])),
          ]),
          const SizedBox(height: 12),
          Text(doc.name, style: s(15, w: FontWeight.w800)),
          Text('${doc.qualification} · ${doc.specialty}', style: s(11, c: muted)),
          const Divider(height: 24, color: Color(0xFFE2EAEE)),
          Row(children: [
            Expanded(child: Text('Patient: ${_patient.name}', style: s(13, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(fmtDateShort(DateTime.now()), style: s(12, c: muted)),
          ]),
          Text('${_patient.age} yrs · ${_patient.gender == Gender.male ? 'M' : 'F'} · ${_patient.bloodGroup}', style: s(12, c: muted)),
          if (_diagnosis.text.trim().isNotEmpty) ...[const SizedBox(height: 8), Text('Dx: ${_diagnosis.text.trim()}', style: s(13, w: FontWeight.w600))],
          const SizedBox(height: 16),
          Text('℞', style: s(34, w: FontWeight.w800, c: AppColors.primary)),
          if (_items.isEmpty) Text('— no medicines —', style: s(13, c: muted)),
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${i + 1}.', style: s(13, w: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_items[i].drug.label, style: s(14, w: FontWeight.w700)),
                  Text('${_items[i].dosage} · ${_items[i].days} days · ${_items[i].instruction}', style: s(12, c: muted)),
                ])),
              ]),
            ),
          if (_advice.text.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Advice', style: s(12, w: FontWeight.w800, c: AppColors.primary)),
            const SizedBox(height: 4),
            Text(_advice.text.trim(), style: s(12)),
          ],
          if (_followUp != null) ...[const SizedBox(height: 10), Text('Follow-up: ${fmtDateLong(_followUp!)}', style: s(12, w: FontWeight.w700))],
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Dr. R. Patel', style: TextStyle(fontFamily: 'cursive', fontStyle: FontStyle.italic, fontSize: 24, color: AppColors.primaryDark.withValues(alpha: .85), letterSpacing: 1)),
              Container(width: 130, height: 1, color: muted),
              Text('${doc.name} · Reg. GMC-2004-1187', style: s(10, c: muted)),
            ]),
          ),
          const SizedBox(height: 8),
          Text('Generated with ${AppConfig.appName}', style: s(9, c: muted)),
        ]),
      ),
    ]);
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.labels, required this.onChanged});
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: i == index ? p.surface : Colors.transparent, borderRadius: AppRadius.rSm, boxShadow: i == index ? [BoxShadow(color: p.shadow, blurRadius: 8)] : null),
                child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium!.copyWith(color: i == index ? p.primary : p.textSecondary, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({super.key, required this.item, required this.index, required this.onChanged, required this.onDelete});
  final RxItem item;
  final int index;
  final VoidCallback onChanged, onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: p.primarySoft, borderRadius: BorderRadius.circular(10)), child: Text('${index + 1}', style: context.tt.labelMedium!.copyWith(color: p.primary))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.drug.label, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis), Text(item.drug.form, style: context.tt.bodySmall)])),
          IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline_rounded, color: p.danger)),
        ]),
        const SizedBox(height: 10),
        Text('Dosage (M-A-N)', style: context.tt.labelSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final d in kDosages) ChoicePill(label: d, selected: item.dosage == d, onTap: () {
              item.dosage = d;
              onChanged();
            })]),
        const SizedBox(height: 12),
        Text('Duration', style: context.tt.labelSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          for (final d in kDurations) ChoicePill(label: '$d d', selected: item.days == d, onTap: () {
                item.days = d;
                onChanged();
              }),
          Container(
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rPill),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _Step(icon: Icons.remove_rounded, onTap: () {
                if (item.days > 1) {
                  item.days--;
                  onChanged();
                }
              }),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('${item.days} days', style: context.tt.labelMedium)),
              _Step(icon: Icons.add_rounded, onTap: () {
                item.days++;
                onChanged();
              }),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text('Instructions', style: context.tt.labelSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final d in kInstructions) ChoicePill(label: d, selected: item.instruction == d, onTap: () {
              item.instruction = d;
              onChanged();
            })]),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TapScale(onTap: onTap, child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 18, color: context.pal.primary)));
}
