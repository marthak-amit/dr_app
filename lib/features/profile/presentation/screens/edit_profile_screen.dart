import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../widgets/add_member_sheet.dart';
import '../../widgets/settings_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name, _email, _age, _address, _phone;
  late Gender _gender;
  late String _blood;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final pr = ref.read(sessionProvider).profile;
    _name = TextEditingController(text: pr.name);
    _phone = TextEditingController(text: pr.phone);
    _email = TextEditingController(text: pr.email.isEmpty ? 'amit.marthak@example.com' : pr.email);
    _age = TextEditingController(text: '${pr.age}');
    _address = TextEditingController(text: 'B-204, Shivalik Residency, Ambawadi, Ahmedabad 380015');
    _gender = pr.gender;
    _blood = pr.bloodGroup;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _age.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final age = int.tryParse(_age.text.trim());
    if (_name.text.trim().length < 2) return setState(() => _error = 'Please enter your name');
    if (age == null || age < 1 || age > 120) return setState(() => _error = 'Please enter a valid age');
    if (_email.text.trim().isNotEmpty && !_email.text.contains('@')) return setState(() => _error = 'Please enter a valid email');
    setState(() {
      _error = null;
      _saving = true;
    });
    await fakeLatency();
    if (!mounted) return;
    final pr = ref.read(sessionProvider).profile;
    ref.read(sessionProvider.notifier).saveProfile(pr.copyWith(name: _name.text.trim(), email: _email.text.trim(), age: age, gender: _gender, bloodGroup: _blood));
    showAppSnack(context, 'Profile updated', icon: Icons.check_circle_rounded);
    context.canPop() ? context.pop() : null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final pr = ref.watch(sessionProvider).profile;
    return Scaffold(
      appBar: const AppTopBar(title: 'Edit profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 40),
        children: [
          Center(
            child: TapScale(
              onTap: () => showAppSnack(context, 'Photo picker would open here', icon: Icons.photo_camera_rounded),
              child: Stack(children: [
                InitialsAvatar(initials: initialsOf(_name.text.isEmpty ? pr.name : _name.text), size: 96),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle, border: Border.all(color: p.bg, width: 3)),
                    child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
          Gap.v(24),
          AppTextField(controller: _name, label: 'Full name', prefixIcon: Icons.person_outline_rounded, onChanged: (_) => setState(() {})),
          Gap.v(16),
          AppTextField(
            controller: _phone,
            label: 'Phone number',
            prefixIcon: Icons.phone_outlined,
            readOnly: true,
            onTap: () => showAppSnack(context, 'Verified numbers can only be changed from support', icon: Icons.lock_outline_rounded),
            suffix: Icon(Icons.verified_rounded, color: p.success, size: 20),
          ),
          Gap.v(16),
          AppTextField(controller: _email, label: 'Email', prefixIcon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
          Gap.v(16),
          AppTextField(controller: _age, label: 'Age', prefixIcon: Icons.cake_outlined, keyboardType: TextInputType.number, maxLength: 3, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          Gap.v(16),
          Text('Gender', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
          Gap.v(8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoicePill(label: 'Male', icon: Icons.male_rounded, selected: _gender == Gender.male, onTap: () => setState(() => _gender = Gender.male)),
            ChoicePill(label: 'Female', icon: Icons.female_rounded, selected: _gender == Gender.female, onTap: () => setState(() => _gender = Gender.female)),
          ]),
          Gap.v(16),
          Text('Blood group', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
          Gap.v(8),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final b in kBloodGroups) ChoicePill(label: b, selected: _blood == b, onTap: () => setState(() => _blood = b))]),
          Gap.v(16),
          AppTextField(controller: _address, label: 'Address', prefixIcon: Icons.location_on_outlined, maxLines: 2),
          if (_error != null) ...[Gap.v(12), Text(_error!, style: context.tt.bodySmall!.copyWith(color: p.danger))],
          Gap.v(28),
          AppButton(label: 'Save changes', loading: _saving, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}
