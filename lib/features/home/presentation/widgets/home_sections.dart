import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

/// Horizontal quick-action tiles.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final items = <(Widget, String, Color, Color, String)>[
      (const SvgIcon('pill', size: 24), 'Prescriptions', p.primary, p.primarySoft, Routes.prescriptions),
      (const SvgIcon('bell', size: 24), 'Reminders', p.accent, p.accentSoft, Routes.reminders),
      (const SvgIcon('test-tube-diagonal', size: 24), 'Lab tests', p.success, p.successSoft, Routes.labTests),
      (const SvgIcon('activity', size: 24), 'Vitals', p.danger, p.dangerSoft, Routes.vitals),
      (const Icon(Icons.chat_bubble_outline_rounded, size: 24), 'Chat', p.warning, p.warningSoft, Routes.chat),
      (const SvgIcon('video', size: 24), 'Video consult', p.primary, p.primarySoft, Routes.search()),
    ];
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final (icon, label, c, bg, route) = items[i];
          return TapScale(
            onTap: () => context.push(route),
            child: SizedBox(
              width: 76,
              child: Column(children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                  child: IconTheme(data: IconThemeData(color: c), child: Center(child: icon)),
                ),
                const SizedBox(height: 8),
                Text(label, style: context.tt.labelSmall!.copyWith(color: p.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _SpecialtyTile extends StatelessWidget {
  const _SpecialtyTile({required this.s, required this.onTap});
  final Specialty s;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TapScale(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: p.isDark ? s.color.withValues(alpha: .18) : s.tint, borderRadius: BorderRadius.circular(20)),
          child: Center(child: SvgIcon(s.icon, size: 26, color: s.color)),
        ),
        const SizedBox(height: 8),
        Text(s.name, style: context.tt.labelSmall!.copyWith(color: p.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
      ]),
    );
  }
}

class SpecialtyGrid extends StatelessWidget {
  const SpecialtyGrid({super.key, required this.specialties});
  final List<Specialty> specialties;

  @override
  Widget build(BuildContext context) {
    final shown = specialties.take(8).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: .82,
        children: [for (final s in shown) _SpecialtyTile(s: s, onTap: () => context.push(Routes.search(specialty: s.id)))],
      ),
    );
  }
}

void showAllSpecialties(BuildContext context, List<Specialty> all) {
  showAppBottomSheet<void>(
    context,
    title: 'All specialties',
    builder: (ctx) => GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: .82,
      children: [
        for (final s in all)
          _SpecialtyTile(
            s: s,
            onTap: () {
              Navigator.pop(ctx);
              context.push(Routes.search(specialty: s.id));
            },
          ),
      ],
    ),
  );
}

const _tips = <(String, String, String)>[
  ('Stay hydrated', 'Drink 8–10 glasses of water a day.', 'Water supports digestion, regulates body temperature and keeps your skin healthy. Carry a bottle with you and sip regularly — especially in the hot Gujarat summers. Add a pinch of salt and lemon after heavy sweating.'),
  ('Walk 30 minutes', 'A brisk daily walk lowers heart risk by 30%.', 'Regular brisk walking improves blood pressure, blood sugar and mood. Aim for 30 minutes, 5 days a week. Split it into three 10 minute walks if that is easier — it counts just the same.'),
  ('Sleep 7–8 hours', 'Good sleep strengthens immunity.', 'Keep a consistent bedtime, avoid screens 30 minutes before sleep and keep the room cool and dark. Poor sleep is linked to higher BP, weight gain and weaker immunity.'),
  ('Cut the salt', 'Less than 5 g of salt a day keeps BP in check.', 'Packaged snacks, pickles and papad are hidden sources of sodium. Use herbs, lemon and spices for flavour, and read nutrition labels when shopping.'),
];

class HealthTipBanner extends StatefulWidget {
  const HealthTipBanner({super.key});
  @override
  State<HealthTipBanner> createState() => _HealthTipBannerState();
}

class _HealthTipBannerState extends State<HealthTipBanner> {
  int _i = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) setState(() => _i = (_i + 1) % _tips.length);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tips[_i];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppColors.gradientAccent, borderRadius: AppRadius.rXl, boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Row(children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Column(
              key: ValueKey(_i),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HEALTH TIP', style: context.tt.labelSmall!.copyWith(color: Colors.white70, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(tip.$1, style: context.tt.titleLarge!.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(tip.$2, style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .9)), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                TapScale(
                  onTap: () => showAppBottomSheet<void>(context, title: tip.$1, builder: (ctx) => Text(tip.$3, style: ctx.tt.bodyLarge!.copyWith(color: ctx.pal.textSecondary, height: 1.6))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.rPill),
                    child: Text('Read more', style: context.tt.labelMedium!.copyWith(color: AppColors.accent)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), shape: BoxShape.circle),
          child: const Center(child: SvgIcon('heart-pulse', size: 42, color: Colors.white)),
        ),
      ]),
    );
  }
}
