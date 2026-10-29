import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/providers.dart';

const kRelations = ['Spouse', 'Son', 'Daughter', 'Father', 'Mother', 'Sibling', 'Other'];
const kBloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

class AddMemberSheet extends StatefulWidget {
  const AddMemberSheet({super.key, required this.onAdd});
  final ValueChanged<Patient> onAdd;
  @override
  State<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<AddMemberSheet> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _relation = 'Spouse';
  Gender _gender = Gender.female;
  String _blood = 'B+';
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  void _submit() {
    final age = int.tryParse(_age.text.trim());
    if (_name.text.trim().length < 2) return setState(() => _error = 'Please enter the member\'s full name');
    if (age == null || age < 0 || age > 120) return setState(() => _error = 'Please enter a valid age');
    widget.onAdd(Patient(id: 'p${DateTime.now().microsecondsSinceEpoch}', name: _name.text.trim(), age: age, gender: _gender, phone: '+91 98765 43210', relation: _relation, bloodGroup: _blood));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppTextField(controller: _name, label: 'Full name', hint: 'e.g. Rahul Marthak', prefixIcon: Icons.person_outline_rounded, textInputAction: TextInputAction.next),
      Gap.v(16),
      Text('Relation', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
      Gap.v(8),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final r in kRelations) ChoicePill(label: r, selected: _relation == r, onTap: () => setState(() => _relation = r))]),
      Gap.v(16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: AppTextField(controller: _age, label: 'Age', hint: 'Years', keyboardType: TextInputType.number, maxLength: 3, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
        Gap.h(12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Gender', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
            Gap.v(8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChoicePill(label: 'Male', selected: _gender == Gender.male, onTap: () => setState(() => _gender = Gender.male)),
              ChoicePill(label: 'Female', selected: _gender == Gender.female, onTap: () => setState(() => _gender = Gender.female)),
            ]),
          ]),
        ),
      ]),
      Gap.v(16),
      Text('Blood group', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
      Gap.v(8),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final b in kBloodGroups) ChoicePill(label: b, selected: _blood == b, onTap: () => setState(() => _blood = b))]),
      if (_error != null) ...[Gap.v(12), Text(_error!, style: context.tt.bodySmall!.copyWith(color: p.danger))],
      Gap.v(24),
      AppButton(label: 'Add member', icon: Icons.person_add_alt_1_rounded, onPressed: _submit),
    ]);
  }
}
