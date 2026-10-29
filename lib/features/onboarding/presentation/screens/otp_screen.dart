import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _len = 6;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _left = 30;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _startTimer() {
    _left = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) t.cancel();
      if (mounted) setState(() => _left--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_ctrl.text.length < _len || _verifying) return;
    FocusScope.of(context).unfocus();
    setState(() => _verifying = true);
    await fakeLatency(600, 900);
    if (!mounted) return;
    ref.read(sessionProvider.notifier).login(widget.phone);
    showAppSnack(context, 'Phone number verified', icon: Icons.verified_rounded);
    context.go(Routes.profileSetup);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final text = _ctrl.text;
    final ph = widget.phone.length == 10 ? '${widget.phone.substring(0, 5)} ${widget.phone.substring(5)}' : widget.phone;
    return Scaffold(
      appBar: const AppTopBar(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rLg),
              child: Icon(Icons.sms_rounded, color: p.primary, size: 32),
            ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
            const SizedBox(height: 20),
            Text('Verify your number', style: context.tt.headlineLarge),
            const SizedBox(height: 8),
            Text.rich(TextSpan(style: context.tt.bodyMedium, children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(text: '+91 $ph', style: context.tt.titleSmall),
              const TextSpan(text: '. Any code works in this demo.'),
            ])),
            const SizedBox(height: 32),
            Stack(children: [
              Row(
                children: [
                  for (var i = 0; i < _len; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _Box(char: i < text.length ? text[i] : '', active: i == text.length && _focus.hasFocus, filled: i < text.length)),
                  ],
                ],
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    maxLength: _len,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enableInteractiveSelection: false,
                    onChanged: (v) {
                      setState(() {});
                      if (v.length == _len) _verify();
                    },
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 28),
            AppButton(label: 'Verify & continue', loading: _verifying, onPressed: text.length == _len ? _verify : null),
            const SizedBox(height: 20),
            Center(
              child: _left > 0
                  ? Text.rich(TextSpan(style: context.tt.bodyMedium, children: [
                      const TextSpan(text: 'Resend code in '),
                      TextSpan(text: '00:${_left.toString().padLeft(2, '0')}', style: context.tt.titleSmall!.copyWith(color: p.primary)),
                    ]))
                  : AppButton(
                      label: 'Resend OTP',
                      variant: AppButtonVariant.text,
                      expand: false,
                      size: AppButtonSize.medium,
                      onPressed: () {
                        _startTimer();
                        setState(() {});
                        showAppSnack(context, 'A new OTP has been sent', icon: Icons.sms_rounded);
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Center(child: AppButton(label: 'Change number', variant: AppButtonVariant.text, expand: false, size: AppButtonSize.small, onPressed: () => context.pop())),
          ]),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.char, required this.active, required this.filled});
  final String char;
  final bool active, filled;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? p.primarySoft : p.surface,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: active ? p.primary : (filled ? p.primary.withValues(alpha: .4) : p.border), width: active ? 2 : 1.2),
      ),
      child: Text(char, style: context.tt.headlineSmall!.copyWith(color: p.primary)),
    );
  }
}
