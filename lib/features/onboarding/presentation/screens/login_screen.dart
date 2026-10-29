import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../widgets/mediq_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool get _valid => _phone.text.length == 10;

  Future<void> _send() async {
    if (!_valid) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await fakeLatency();
    if (!mounted) return;
    setState(() => _loading = false);
    showAppSnack(context, 'OTP sent to +91 ${_phone.text}', icon: Icons.sms_rounded);
    context.push(Routes.otp(_phone.text));
  }

  Future<void> _guest({bool google = false}) async {
    setState(() => _loading = true);
    await fakeLatency();
    if (!mounted) return;
    ref.read(sessionProvider.notifier).login('98765 43210');
    setState(() => _loading = false);
    showAppSnack(context, google ? 'Signed in with Google (demo)' : 'Welcome! Continuing as a demo user', icon: Icons.waving_hand_rounded);
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(children: [
          Stack(children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
              decoration: const BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
              child: Column(children: [
                Row(children: [
                  const MediQLogo(size: 40, onDark: true),
                  const SizedBox(width: 10),
                  Text(AppConfig.appName, style: context.tt.titleLarge!.copyWith(color: Colors.white)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: AppRadius.rXl, child: Image.asset('assets/images/illustrations/login.png', height: 190, fit: BoxFit.contain)),
              ]),
            ),
          ]).animate().fadeIn(duration: 400.ms),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 28, AppSpacing.screenH, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back 👋', style: context.tt.headlineLarge).animate(delay: 100.ms).fadeIn().slideY(begin: .2),
              const SizedBox(height: 6),
              Text('Enter your mobile number to book appointments and manage your health.', style: context.tt.bodyMedium).animate(delay: 160.ms).fadeIn(),
              const SizedBox(height: 24),
              AppTextField(
                controller: _phone,
                label: 'Mobile number',
                hint: '98765 43210',
                prefixText: '+91  ',
                prefixIcon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _send(),
              ).animate(delay: 220.ms).fadeIn().slideY(begin: .2),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(children: [Icon(Icons.error_outline_rounded, size: 16, color: p.danger), const SizedBox(width: 6), Expanded(child: Text(_error!, style: context.tt.bodySmall!.copyWith(color: p.danger)))]),
                ),
              const SizedBox(height: 20),
              AppButton(label: 'Send OTP', loading: _loading, trailingIcon: Icons.arrow_forward_rounded, onPressed: _send).animate(delay: 280.ms).fadeIn().slideY(begin: .2),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Divider(color: p.border)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: context.tt.bodySmall)),
                Expanded(child: Divider(color: p.border)),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: AppButton(label: 'Google', icon: Icons.g_mobiledata_rounded, variant: AppButtonVariant.outline, size: AppButtonSize.medium, onPressed: _loading ? null : () => _guest(google: true))),
                const SizedBox(width: 12),
                Expanded(child: AppButton(label: 'Guest', icon: Icons.person_outline_rounded, variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: _loading ? null : _guest)),
              ]).animate(delay: 340.ms).fadeIn(),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => showAppSnack(context, 'Terms & Privacy Policy would open here', icon: Icons.description_outlined),
                  child: Text.rich(
                    TextSpan(style: context.tt.bodySmall, children: [
                      const TextSpan(text: 'By continuing you agree to our '),
                      TextSpan(text: 'Terms of Service', style: TextStyle(color: p.primary, fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' & '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: p.primary, fontWeight: FontWeight.w700)),
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
