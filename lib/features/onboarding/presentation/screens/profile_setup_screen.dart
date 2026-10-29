import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  Gender _gender = Gender.male;
  String _blood = 'B+';
  bool _saving = false;
  bool _done = false;
  String? _nameErr;

  static const _groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_name.text.trim().length < 2) {
      setState(() => _nameErr = 'Please enter your full name');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await fakeLatency();
    if (!mounted) return;
    final cur = ref.read(sessionProvider).profile;
    ref.read(sessionProvider.notifier).saveProfile(cur.copyWith(
          name: _name.text.trim(),
          age: int.tryParse(_age.text) ?? cur.age,
          gender: _gender,
          bloodGroup: _blood,
          email: _email.text.trim(),
        ));
    setState(() {
      _saving = false;
      _done = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go(Routes.home);
  }

  void _skip() {
    showAppSnack(context, 'You can complete your profile anytime from Profile', icon: Icons.info_outline_rounded);
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    if (_done) return _Welcome(name: _name.text.trim().split(' ').first);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Row(children: [
              Expanded(child: Text('Step 3 of 3', style: context.tt.labelMedium!.copyWith(color: p.textSecondary))),
              AppButton(label: 'Skip for now', variant: AppButtonVariant.text, size: AppButtonSize.small, expand: false, onPressed: _skip),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 4, AppSpacing.screenH, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: AppRadius.rPill,
                  child: LinearProgressIndicator(value: 1, minHeight: 6, color: p.primary, backgroundColor: p.border),
                ),
                const SizedBox(height: 24),
                Text('Tell us about you', style: context.tt.headlineLarge).animate().fadeIn().slideY(begin: .2),
                const SizedBox(height: 6),
                Text('This helps doctors give you better care. You can edit it later.', style: context.tt.bodyMedium),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _name,
                  label: 'Full name',
                  hint: 'e.g. Amit Marthak',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _nameErr = null),
                ),
                if (_nameErr != null) Padding(padding: const EdgeInsets.only(top: 6, left: 4), child: Text(_nameErr!, style: context.tt.bodySmall!.copyWith(color: p.danger))),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 110,
                    child: AppTextField(
                      controller: _age,
                      label: 'Age',
                      hint: '32',
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Gender', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        ChoicePill(label: 'Male', icon: Icons.male_rounded, selected: _gender == Gender.male, onTap: () => setState(() => _gender = Gender.male)),
                        ChoicePill(label: 'Female', icon: Icons.female_rounded, selected: _gender == Gender.female, onTap: () => setState(() => _gender = Gender.female)),
                      ]),
                    ]),
                  ),
                ]),
                const SizedBox(height: 20),
                Text('Blood group', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [for (final g in _groups) ChoicePill(label: g, selected: _blood == g, onTap: () => setState(() => _blood = g))]),
                const SizedBox(height: 20),
                AppTextField(controller: _email, label: 'Email (optional)', hint: 'you@example.com', prefixIcon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 16),
            child: AppButton(label: 'Complete setup', loading: _saving, trailingIcon: Icons.check_rounded, onPressed: _complete),
          ),
        ]),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Lottie.asset(
                'assets/lottie/success.json',
                repeat: false,
                errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(color: p.successSoft, shape: BoxShape.circle), child: Icon(Icons.check_rounded, size: 64, color: p.success)),
              ),
            ),
            const SizedBox(height: 16),
            Text(name.isEmpty ? "You're all set!" : "Welcome, $name!", style: context.tt.headlineLarge, textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms).slideY(begin: .2),
            const SizedBox(height: 8),
            Text('Your profile is ready. Taking you home…', style: context.tt.bodyMedium, textAlign: TextAlign.center).animate().fadeIn(delay: 350.ms),
          ]),
        ),
      ),
    );
  }
}
