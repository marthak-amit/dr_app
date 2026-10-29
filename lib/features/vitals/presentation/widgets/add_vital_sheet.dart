import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/vitals_logic.dart';

Future<void> showAddVitalSheet(BuildContext context, WidgetRef ref, {required VitalType initial}) {
  return showAppBottomSheet<void>(
    context,
    title: 'Add entry',
    builder: (ctx) => _AddVital(
      initial: initial,
      onSave: (e) {
        ref.read(vitalsProvider.notifier).add(e);
        Navigator.of(ctx).pop();
        final m = vitalMeta(e.type);
        showAppSnack(context, '${m.title} saved: ${fmtValue(e)} ${m.unit}', icon: Icons.check_circle_rounded);
      },
    ),
  );
}

class _AddVital extends StatefulWidget {
  const _AddVital({required this.initial, required this.onSave});
  final VitalType initial;
  final ValueChanged<VitalEntry> onSave;

  @override
  State<_AddVital> createState() => _AddVitalState();
}

class _AddVitalState extends State<_AddVital> {
  late VitalType type = widget.initial;
  final sys = TextEditingController();
  final dia = TextEditingController();
  final single = TextEditingController();
  String sugarCtx = 'Fasting';
  DateTime when = DateTime.now();
  String? error;

  @override
  void dispose() {
    sys.dispose();
    dia.dispose();
    single.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final d = await showDatePicker(context: context, initialDate: when, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
    if (!mounted) return;
    setState(() => when = DateTime(d.year, d.month, d.day, t?.hour ?? when.hour, t?.minute ?? when.minute));
  }

  void _save() {
    VitalEntry? e;
    if (type == VitalType.bp) {
      final s = double.tryParse(sys.text), d = double.tryParse(dia.text);
      if (s == null || d == null || s < 60 || s > 260 || d < 30 || d > 160 || d >= s) {
        setState(() => error = 'Enter valid systolic (60–260) and diastolic (30–160) values.');
        return;
      }
      e = VitalEntry(type: type, date: when, value: s, value2: d);
    } else {
      final v = double.tryParse(single.text);
      final ok = type == VitalType.sugar ? (v != null && v >= 20 && v <= 700) : (v != null && v >= 2 && v <= 300);
      if (!ok) {
        setState(() => error = type == VitalType.sugar ? 'Enter sugar between 20 and 700 mg/dL.' : 'Enter a valid weight in kg.');
        return;
      }
      e = VitalEntry(type: type, date: when, value: v);
    }
    widget.onSave(e);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final meta = vitalMeta(type);
    final numFmt = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final m in vitalMetas)
          ChoicePill(label: m.type == VitalType.bp ? 'BP' : (m.type == VitalType.sugar ? 'Sugar' : 'Weight'), icon: m.icon, selected: type == m.type, onTap: () => setState(() {
                type = m.type;
                error = null;
              })),
      ]),
      const SizedBox(height: 18),
      if (type == VitalType.bp)
        Row(children: [
          Expanded(child: AppTextField(controller: sys, label: 'Systolic (high)', hint: '120', keyboardType: TextInputType.number, inputFormatters: numFmt, maxLength: 3)),
          const SizedBox(width: 12),
          Expanded(child: AppTextField(controller: dia, label: 'Diastolic (low)', hint: '80', keyboardType: TextInputType.number, inputFormatters: numFmt, maxLength: 3)),
        ])
      else
        AppTextField(controller: single, label: type == VitalType.sugar ? 'Blood sugar (mg/dL)' : 'Weight (kg)', hint: type == VitalType.sugar ? '105' : '74.5', keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: numFmt, maxLength: 5, prefixIcon: meta.icon),
      if (type == VitalType.sugar) ...[
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final c in ['Fasting', 'Post-meal', 'Random']) ChoicePill(label: c, selected: sugarCtx == c, onTap: () => setState(() => sugarCtx = c))]),
      ],
      const SizedBox(height: 14),
      TapScale(
        onTap: _pickWhen,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
          child: Row(children: [
            Icon(Icons.event_rounded, color: p.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(DateFormat('EEE, d MMM · h:mm a').format(when), style: context.tt.titleSmall)),
            Text('Change', style: context.tt.labelMedium!.copyWith(color: p.primary)),
          ]),
        ),
      ),
      if (error != null) ...[const SizedBox(height: 10), Text(error!, style: context.tt.bodySmall!.copyWith(color: p.danger))],
      const SizedBox(height: 20),
      AppButton(label: 'Save entry', icon: Icons.check_rounded, onPressed: _save),
    ]);
  }
}
