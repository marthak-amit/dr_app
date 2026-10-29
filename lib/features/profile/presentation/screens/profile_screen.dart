import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../widgets/settings_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final profile = ref.watch(sessionProvider).profile;
    final family = ref.watch(familyProvider).valueOrNull?.length;
    final visits = ref.watch(appointmentsProvider).valueOrNull?.where((a) => a.status == AppointmentStatus.completed).length;
    final records = ref.watch(recordsProvider).valueOrNull?.length;
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

    Widget stagger(Widget w, int i) => w.animate().fadeIn(delay: (60 * i).ms, duration: 350.ms).slideY(begin: .06, end: 0, delay: (60 * i).ms, duration: 350.ms, curve: Curves.easeOutCubic);

    return Scaffold(
      body: RefreshIndicator(
        color: p.primary,
        onRefresh: () async {
          ref.invalidate(familyProvider);
          ref.invalidate(recordsProvider);
          ref.invalidate(appointmentsProvider);
          await fakeLatency();
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(AppSpacing.screenH, MediaQuery.of(context).padding.top + 16, AppSpacing.screenH, 120),
          children: [
            Text('Profile', style: context.tt.headlineMedium),
            Gap.v(16),
            stagger(_Header(name: profile.name, phone: profile.phone, onEdit: () => context.push(Routes.editProfile)), 0),
            Gap.v(16),
            stagger(
              Row(children: [
                Expanded(child: _Stat(value: family, label: 'Family', icon: Icons.groups_rounded, color: p.primary, onTap: () => context.push(Routes.family))),
                Gap.h(12),
                Expanded(child: _Stat(value: visits, label: 'Visits', icon: Icons.local_hospital_rounded, color: p.accent, onTap: () => context.go(Routes.appointments))),
                Gap.h(12),
                Expanded(child: _Stat(value: records, label: 'Records', icon: Icons.folder_rounded, color: p.warning, onTap: () => context.go(Routes.records))),
              ]),
              1,
            ),
            Gap.v(20),
            stagger(_DoctorSwitchCard(onTap: () {
              ref.read(appModeProvider.notifier).state = AppMode.doctor;
              showAppSnack(context, 'Switched to Doctor view', icon: Icons.medical_services_rounded);
              context.go(Routes.drDashboard);
            }), 2),
            Gap.v(24),
            stagger(
              SettingsGroup(title: 'Health', children: [
                SettingsTile(icon: Icons.family_restroom_rounded, label: 'Family members', onTap: () => context.push(Routes.family)),
                SettingsTile(icon: Icons.folder_copy_rounded, label: 'Medical records', color: p.warning, onTap: () => context.go(Routes.records)),
                SettingsTile(icon: Icons.receipt_long_rounded, label: 'Prescriptions', color: p.accent, onTap: () => context.push(Routes.prescriptions)),
                SettingsTile(icon: Icons.alarm_rounded, label: 'Medicine reminders', color: p.success, onTap: () => context.push(Routes.reminders)),
                SettingsTile(icon: Icons.monitor_heart_rounded, label: 'Vitals tracker', color: p.danger, onTap: () => context.push(Routes.vitals)),
                SettingsTile(icon: Icons.science_rounded, label: 'Lab tests', onTap: () => context.push(Routes.labTests)),
              ]),
              3,
            ),
            Gap.v(20),
            stagger(
              SettingsGroup(title: 'Payments', children: [
                SettingsTile(icon: Icons.account_balance_wallet_rounded, label: 'Payment methods', onTap: () => context.push(Routes.payments)),
                SettingsTile(icon: Icons.history_rounded, label: 'Transactions', color: p.warning, onTap: () => _showTransactions(context)),
              ]),
              4,
            ),
            Gap.v(20),
            stagger(
              SettingsGroup(title: 'Preferences', children: [
                SettingsTile(icon: Icons.translate_rounded, label: 'Language', trailingText: lang, onTap: () => context.push(Routes.language)),
                SettingsTile(icon: Icons.notifications_rounded, label: 'Notifications', color: p.accent, onTap: () => context.push(Routes.notifications)),
                SettingsSwitchTile(
                  icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  label: 'Dark mode',
                  color: const Color(0xFF6C5CE7),
                  value: dark,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light,
                ),
                SettingsTile(icon: Icons.settings_rounded, label: 'Settings', color: p.textSecondary, onTap: () => context.push(Routes.settings)),
              ]),
              5,
            ),
            Gap.v(20),
            stagger(
              SettingsGroup(title: 'Support', children: [
                SettingsTile(icon: Icons.help_center_rounded, label: 'Help centre', onTap: () => _showHelp(context)),
                SettingsTile(icon: Icons.support_agent_rounded, label: 'Chat with clinic', color: p.success, onTap: () => context.push(Routes.chat)),
                SettingsTile(icon: Icons.star_rounded, label: 'Rate ${AppConfig.appName}', color: AppColors.star, onTap: () => _showRate(context)),
                SettingsTile(icon: Icons.privacy_tip_rounded, label: 'Privacy policy', color: p.textSecondary, onTap: () => _showPrivacy(context)),
              ]),
              6,
            ),
            Gap.v(24),
            stagger(
              AppButton(
                label: 'Log out',
                variant: AppButtonVariant.danger,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  final ok = await showConfirmSheet(context, title: 'Log out?', message: 'You will need to verify your phone number again to sign back in.', confirmLabel: 'Log out', destructive: true, icon: Icons.logout_rounded);
                  if (ok && context.mounted) {
                    ref.read(sessionProvider.notifier).logout();
                    ref.read(appModeProvider.notifier).state = AppMode.patient;
                    context.go(Routes.login);
                  }
                },
              ),
              7,
            ),
            Gap.v(20),
            Center(child: Text('${AppConfig.appName} v1.0.0 (build 1) · Made in India 🇮🇳', style: context.tt.bodySmall!.copyWith(color: p.textTertiary), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  void _showTransactions(BuildContext context) {
    const items = [
      ('Dr. Rakesh Patel · In-clinic', '₹1,000', 'UPI', true),
      ('Dr. Priya Shah · Video', '₹500', 'Card', true),
      ('Full Body Checkup', '₹1,499', 'UPI', true),
      ('Dr. Kavita Trivedi · In-clinic', '₹400', 'UPI', true),
      ('Dr. Vikram Desai · Refund', '₹900', 'Wallet', false),
    ];
    showAppBottomSheet<void>(context, title: 'Recent transactions', builder: (ctx) {
      final p = ctx.pal;
      return Column(children: [
        for (final t in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: t.$4 ? p.dangerSoft : p.successSoft, shape: BoxShape.circle),
                child: Icon(t.$4 ? Icons.north_east_rounded : Icons.south_west_rounded, size: 18, color: t.$4 ? p.danger : p.success),
              ),
              Gap.h(12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.$1, style: ctx.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis), Text('via ${t.$3}', style: ctx.tt.bodySmall)])),
              Text('${t.$4 ? '-' : '+'}${t.$2}', style: ctx.tt.titleSmall!.copyWith(color: t.$4 ? p.textPrimary : p.success)),
            ]),
          ),
      ]);
    });
  }

  void _showHelp(BuildContext context) {
    showAppBottomSheet<void>(context, title: 'Help centre', builder: (ctx) {
      final p = ctx.pal;
      Widget row(IconData i, String t, String s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () {
                Navigator.pop(ctx);
                showAppSnack(context, '$t – opening soon', icon: i);
              },
              child: Row(children: [
                Icon(i, color: p.primary),
                Gap.h(14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: ctx.tt.titleSmall), Text(s, style: ctx.tt.bodySmall)])),
              ]),
            ),
          );
      return Column(children: [
        row(Icons.call_rounded, 'Call support', AppConfig.supportPhone),
        row(Icons.mail_rounded, 'Email us', 'support@mediq.example'),
        row(Icons.quiz_rounded, 'FAQs', 'Bookings, refunds, video consults'),
      ]);
    });
  }

  void _showRate(BuildContext context) {
    showAppBottomSheet<void>(context, title: 'Enjoying ${AppConfig.appName}?', builder: (ctx) {
      return Column(children: [
        Text('Tap a star to rate your experience', style: ctx.tt.bodyMedium),
        Gap.v(16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(ctx);
                showAppSnack(context, 'Thanks for rating us $i★!', icon: Icons.favorite_rounded);
              },
              icon: const Icon(Icons.star_rounded, size: 40, color: AppColors.star),
            ),
        ]),
      ]);
    });
  }

  void _showPrivacy(BuildContext context) {
    showAppBottomSheet<void>(context, title: 'Privacy policy', builder: (ctx) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your health data stays yours. This is a prototype build: all information shown is mock data stored on-device only and is never sent to any server.', style: ctx.tt.bodyMedium),
        Gap.v(20),
        AppButton(label: 'Got it', onPressed: () => Navigator.pop(ctx)),
      ]);
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.phone, required this.onEdit});
  final String name, phone;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: AppRadius.rXl,
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: InitialsAvatar(initials: initialsOf(name), size: 66, bg: Colors.white, fg: AppColors.primary),
        ),
        Gap.h(16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: context.tt.titleLarge!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
            Gap.v(2),
            Text(phone, style: context.tt.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: .85))),
            Gap.v(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: AppRadius.rPill),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                Gap.h(4),
                Text('Verified', style: context.tt.labelSmall!.copyWith(color: Colors.white)),
              ]),
            ),
          ]),
        ),
        TapScale(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.rPill),
            child: Text('Edit', style: context.tt.labelMedium!.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.icon, required this.color, required this.onTap});
  final int? value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        Gap.v(6),
        value == null ? const ShimmerBox(width: 24, height: 20) : Text('$value', style: context.tt.titleLarge),
        Text(label, style: context.tt.bodySmall),
      ]),
    );
  }
}

class _DoctorSwitchCard extends StatelessWidget {
  const _DoctorSwitchCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      scale: .98,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.gradientAccent,
          borderRadius: AppRadius.rLg,
          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: AppRadius.rMd),
            child: const Padding(padding: EdgeInsets.all(12), child: SvgIcon('stethoscope', color: Colors.white)),
          ),
          Gap.h(14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Switch to Doctor view', style: context.tt.titleMedium!.copyWith(color: Colors.white)),
              Text('Manage queue, schedule & prescriptions', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .9)), maxLines: 2),
            ]),
          ),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ]),
      ),
    );
  }
}
