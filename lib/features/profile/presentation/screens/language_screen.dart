import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _langs = [
    ('English', 'English', 'Aa'),
    ('Hindi', 'हिन्दी', 'अ'),
    ('Gujarati', 'ગુજરાતી', 'અ'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final current = ref.watch(languageProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Language'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 40),
        children: [
          Text('Choose your preferred language', style: context.tt.bodyMedium),
          Gap.v(16),
          for (var i = 0; i < _langs.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LangTile(
                glyph: _langs[i].$3,
                native: _langs[i].$2,
                english: _langs[i].$1,
                selected: current == _langs[i].$1,
                onTap: () {
                  ref.read(languageProvider.notifier).state = _langs[i].$1;
                  showAppSnack(context, 'Language set to ${_langs[i].$1}', icon: Icons.translate_rounded);
                },
              ).animate().fadeIn(delay: (80 * i).ms, duration: 350.ms).slideY(begin: .08, end: 0, delay: (80 * i).ms),
            ),
          Gap.v(8),
          AppCard(
            color: p.primarySoft,
            border: false,
            shadow: false,
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: p.primary, size: 20),
              Gap.h(12),
              Expanded(child: Text('Full translation coming soon. Your selection is saved and will apply once translations are available.', style: context.tt.bodySmall!.copyWith(color: p.textSecondary))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({required this.glyph, required this.native, required this.english, required this.selected, required this.onTap});
  final String glyph, native, english;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TapScale(
      onTap: onTap,
      scale: .98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? p.primarySoft : p.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: selected ? p.primary : p.border, width: selected ? 1.6 : 1),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: selected ? p.primary : p.surfaceAlt, borderRadius: AppRadius.rMd),
            child: Text(glyph, style: context.tt.titleLarge!.copyWith(color: selected ? p.onPrimary : p.textSecondary)),
          ),
          Gap.h(14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(native, style: context.tt.titleMedium), Text(english, style: context.tt.bodySmall)])),
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? p.primary : p.textTertiary),
        ]),
      ),
    );
  }
}
