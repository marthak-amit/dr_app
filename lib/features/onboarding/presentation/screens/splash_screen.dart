import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../data/repositories/providers.dart';
import '../widgets/mediq_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      final loggedIn = ref.read(sessionProvider).loggedIn;
      context.go(loggedIn ? Routes.home : Routes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A5C64), Color(0xFF0E7C86), Color(0xFF17A2AC)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Stack(children: [
          Positioned(top: -80, right: -60, child: _blob(260, .08)),
          Positioned(bottom: -100, left: -70, child: _blob(300, .07)),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Stack(alignment: Alignment.center, children: [
                for (var i = 0; i < 2; i++)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .5), width: 2)),
                  )
                      .animate(onPlay: (c) => c.repeat(), delay: (i * 700).ms)
                      .scale(begin: const Offset(1, 1), end: const Offset(2.1, 2.1), duration: 1600.ms, curve: Curves.easeOut)
                      .fadeOut(duration: 1600.ms),
                const MediQLogo(size: 112, onDark: true).animate().scale(begin: const Offset(.4, .4), duration: 700.ms, curve: Curves.easeOutBack).fadeIn(duration: 450.ms),
              ]),
              const SizedBox(height: 40),
              Text(AppConfig.appName, style: context.tt.displayMedium!.copyWith(color: Colors.white, letterSpacing: -1))
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: .3, curve: Curves.easeOutCubic),
              const SizedBox(height: 6),
              Text(AppConfig.tagline, style: context.tt.bodyLarge!.copyWith(color: Colors.white.withValues(alpha: .85)))
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 500.ms),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white.withValues(alpha: .8)),
                ).animate(delay: 1000.ms).fadeIn(),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _blob(double s, double a) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: a)));
}
