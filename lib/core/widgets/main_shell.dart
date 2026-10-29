import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';
import 'svg_icon.dart';
import 'tap_scale.dart';

class _Tab {
  const _Tab(this.path, this.label, this.icon, this.activeIcon);
  final String path, label;
  final IconData icon, activeIcon;
}

const _patientTabs = [
  _Tab(Routes.home, 'Home', Icons.home_outlined, Icons.home_rounded),
  _Tab(Routes.appointments, 'Visits', Icons.calendar_month_outlined, Icons.calendar_month_rounded),
  _Tab(Routes.records, 'Records', Icons.folder_copy_outlined, Icons.folder_copy_rounded),
  _Tab(Routes.profile, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

const _doctorTabs = [
  _Tab(Routes.drDashboard, 'Dashboard', Icons.space_dashboard_outlined, Icons.space_dashboard_rounded),
  _Tab(Routes.drQueue, 'Queue', Icons.groups_outlined, Icons.groups_rounded),
  _Tab(Routes.drSchedule, 'Schedule', Icons.event_available_outlined, Icons.event_available_rounded),
  _Tab(Routes.drMore, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

/// Bottom-nav shell for the patient app (Home · Visits · [Quick book] · Records · Profile).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final idx = _patientTabs.indexWhere((t) => loc.startsWith(t.path)).clamp(0, 3);
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: _NavBar(
        tabs: _patientTabs,
        index: idx,
        fab: true,
        onTap: (i) => context.go(_patientTabs[i].path),
        onFab: () => _showQuickBook(context),
      ),
    );
  }
}

/// Bottom-nav shell for doctor mode.
class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    final idx = _doctorTabs.indexWhere((t) => loc.startsWith(t.path)).clamp(0, 3);
    return Scaffold(
      body: child,
      bottomNavigationBar: _NavBar(tabs: _doctorTabs, index: idx, fab: false, onTap: (i) => context.go(_doctorTabs[i].path)),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.tabs, required this.index, required this.onTap, required this.fab, this.onFab});
  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onTap;
  final bool fab;
  final VoidCallback? onFab;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final bottom = MediaQuery.of(context).padding.bottom;
    Widget item(int i) {
      final t = tabs[i];
      final sel = i == index;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(i);
          },
          child: SizedBox(
            height: 62,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: sel ? p.primarySoft : Colors.transparent, borderRadius: AppRadius.rPill),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(sel ? t.activeIcon : t.icon, key: ValueKey(sel), size: 24, color: sel ? p.primary : p.textTertiary),
                ),
              ),
              const SizedBox(height: 2),
              Text(t.label, maxLines: 1, style: context.tt.labelSmall!.copyWith(color: sel ? p.primary : p.textTertiary, fontWeight: sel ? FontWeight.w700 : FontWeight.w600)),
            ]),
          ),
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      if (fab && i == 2) children.add(const SizedBox(width: 72));
      children.add(item(i));
    }

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: p.border.withValues(alpha: .6))),
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, -6))],
      ),
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
        Row(children: children),
        if (fab)
          Positioned(
            top: -22,
            child: TapScale(
              onTap: onFab,
              haptic: true,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.surface, width: 4),
                  boxShadow: [BoxShadow(color: p.accent.withValues(alpha: .45), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
      ]),
    );
  }
}

void _showQuickBook(BuildContext context) {
  showAppBottomSheet<void>(
    context,
    title: 'Quick book',
    builder: (ctx) {
      final p = ctx.pal;
      Widget tile(String icon, String title, String sub, Color c, Color bg, VoidCallback onTap) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TapScale(
              onTap: () {
                Navigator.pop(ctx);
                onTap();
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rLg, border: Border.all(color: p.border)),
                child: Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rMd), child: Center(child: SvgIcon(icon, size: 24, color: c))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: ctx.tt.titleSmall), Text(sub, style: ctx.tt.bodySmall)])),
                  Icon(Icons.chevron_right_rounded, color: p.textTertiary),
                ]),
              ),
            ),
          );
      return Column(children: [
        tile('stethoscope', 'In-clinic visit', 'Find a doctor near you and pick a slot', p.primary, p.primarySoft, () => context.push(Routes.search())),
        tile('video', 'Video consultation', 'Talk to a doctor from home in minutes', p.accent, p.accentSoft, () => context.push(Routes.search())),
        tile('test-tube-diagonal', 'Lab test at home', 'Free sample pickup, reports in 24 hrs', p.success, p.successSoft, () => context.push(Routes.labTests)),
        tile('house-plus', 'Chat with clinic', 'Ask the front desk anything', p.warning, p.warningSoft, () => context.push(Routes.chat)),
      ]);
    },
  );
}
