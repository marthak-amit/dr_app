import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final profile = ref.watch(sessionProvider).profile;
    final unread = ref.watch(unreadCountProvider);
    final first = profile.name.split(' ').first;
    return Row(children: [
      TapScale(
        onTap: () => context.go(Routes.profile),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(gradient: AppColors.gradientPrimary, shape: BoxShape.circle),
          child: Text(profile.name.isEmpty ? 'M' : profile.name[0].toUpperCase(), style: context.tt.titleMedium!.copyWith(color: Colors.white)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting(), style: context.tt.bodySmall!.copyWith(color: p.textSecondary)),
          Text('Hi, $first 👋', style: context.tt.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
      AppIconButton(icon: Icons.notifications_none_rounded, badge: unread > 0, onTap: () => context.push(Routes.notifications), tooltip: 'Notifications'),
    ]);
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TapScale(
      scale: .985,
      onTap: () => context.push(Routes.search(focus: true)),
      child: Container(
        height: 54,
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: AppRadius.rMd,
          border: Border.all(color: p.border),
          boxShadow: p.isDark ? null : [BoxShadow(color: p.shadow, blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, color: p.textTertiary),
          const SizedBox(width: 10),
          Expanded(child: Text('Search doctors, specialties…', style: context.tt.bodyMedium!.copyWith(color: p.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rSm),
            child: Icon(Icons.tune_rounded, color: p.primary, size: 20),
          ),
        ]),
      ),
    );
  }
}
