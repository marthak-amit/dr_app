import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

/// Content of the "Add reminder" bottom sheet. Returns the new reminder through [onAdd].
class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key, required this.onAdd});
  final ValueChanged<MedicineReminder> onAdd;

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _name = TextEditingController();
  final _dose = TextEditingController(text: '1 tablet');
  final _note = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _repeat = 'Daily';

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final valid = _name.text.trim().isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppTextField(controller: _name, label: 'Medicine name', hint: 'e.g. Metformin 500 mg', prefixIcon: Icons.medication_rounded, onChanged: (_) => setState(() {}), textInputAction: TextInputAction.next),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: AppTextField(controller: _dose, label: 'Dose', hint: '1 tablet', prefixIcon: Icons.colorize_rounded)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Time', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
            const SizedBox(height: 8),
            TapScale(
              onTap: _pickTime,
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: p.border)),
                child: Row(children: [
                  Icon(Icons.access_time_rounded, size: 20, color: p.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(fmtTimeOfDay(_time), style: context.tt.titleSmall, maxLines: 1)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
      const SizedBox(height: 14),
      Text('Repeat', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final r in const ['Daily', 'Weekdays', 'Custom']) ChoicePill(label: r, selected: _repeat == r, onTap: () => setState(() => _repeat = r)),
      ]),
      const SizedBox(height: 14),
      AppTextField(controller: _note, label: 'Note (optional)', hint: 'After food, with water…', prefixIcon: Icons.sticky_note_2_outlined),
      const SizedBox(height: 22),
      AppButton(
        label: 'Save reminder',
        icon: Icons.alarm_add_rounded,
        onPressed: valid
            ? () {
                widget.onAdd(MedicineReminder(
                  id: 'm${DateTime.now().millisecondsSinceEpoch}',
                  medicine: _name.text.trim(),
                  dose: _dose.text.trim().isEmpty ? '1 tablet' : _dose.text.trim(),
                  time: _time,
                  note: _note.text.trim().isEmpty ? _repeat : '${_note.text.trim()} · $_repeat',
                ));
                Navigator.pop(context);
              }
            : null,
      ),
    ]);
  }
}
