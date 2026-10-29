import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  const _Slide(this.image, this.title, this.body);
  final String image, title, body;
}

const _slides = [
  _Slide('assets/images/illustrations/onb1.png', 'Find the right doctor', 'Browse 2,400+ verified specialists near you, compare fees and read real patient reviews.'),
  _Slide('assets/images/illustrations/onb2.png', 'Consult from anywhere', 'Book in-clinic visits or HD video consultations in a few taps — skip the waiting room.'),
  _Slide('assets/images/illustrations/onb3.png', 'All your health records, one place', 'Prescriptions, lab reports and vitals — securely stored and always within reach.'),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _i = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_i == _slides.length - 1) {
      context.go(Routes.login);
    } else {
      _ctrl.nextPage(duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final last = _i == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: last ? 0 : 1,
                child: AppButton(label: 'Skip', variant: AppButtonVariant.text, size: AppButtonSize.small, expand: false, onPressed: last ? null : () => context.go(Routes.login)),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _slides.length,
              onPageChanged: (v) => setState(() => _i = v),
              itemBuilder: (_, i) {
                final s = _slides[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                  child: Column(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.asset(s.image, fit: BoxFit.contain),
                      ),
                    ),
                    Text(s.title, style: context.tt.headlineLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(s.body, style: context.tt.bodyLarge!.copyWith(color: p.textSecondary), textAlign: TextAlign.center),
                  ]).animate(key: ValueKey(_i == i ? 'a$i' : 'b$i')).fadeIn(duration: 350.ms).slideY(begin: .06, curve: Curves.easeOutCubic),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SmoothPageIndicator(
            controller: _ctrl,
            count: _slides.length,
            effect: ExpandingDotsEffect(dotHeight: 8, dotWidth: 8, expansionFactor: 3.5, activeDotColor: p.primary, dotColor: p.border),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 24, AppSpacing.screenH, 24),
            child: AppButton(label: last ? 'Get started' : 'Next', trailingIcon: Icons.arrow_forward_rounded, onPressed: _next),
          ),
        ]),
      ),
    );
  }
}
