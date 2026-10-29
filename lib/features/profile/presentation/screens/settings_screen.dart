import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<String, bool> _t = {'push': true, 'appt': true, 'med': true, 'promo': false, 'bio': false, 'data': false};
  bool _clearing = false;

  void _set(String k, bool v, String msg) {
    setState(() => _t[k] = v);
    showAppSnack(context, '$msg ${v ? 'on' : 'off'}', icon: v ? Icons.check_circle_rounded : Icons.do_not_disturb_on_rounded);
  }

  Future<void> _clearCache() async {
    setState(() => _clearing = true);
    await fakeLatency(900, 1300);
    if (!mounted) return;
    setState(() => _clearing = false);
    showAppSnack(context, 'Cache cleared · 24.6 MB freed', icon: Icons.cleaning_services_rounded);
  }

  Future<void> _delete() async {
    final ok = await showConfirmSheet(context, title: 'Delete account?', message: 'This will permanently erase your profile, records and appointments. This action cannot be undone.', confirmLabel: 'Delete', destructive: true, icon: Icons.warning_amber_rounded);
    if (ok && mounted) {
      ref.read(sessionProvider.notifier).logout();
      showAppSnack(context, 'Account deleted (prototype)', icon: Icons.delete_forever_rounded);
      context.go(Routes.login);
    }
  }

  void _legal(String title, String body) {
    showAppBottomSheet<void>(context, title: title, builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(body, style: ctx.tt.bodyMedium),
          Gap.v(20),
          AppButton(label: 'I understand', onPressed: () => Navigator.pop(ctx)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Scaffold(
      appBar: const AppTopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 40),
        children: [
          SettingsGroup(title: 'Notifications', children: [
            SettingsSwitchTile(icon: Icons.notifications_active_rounded, label: 'Push notifications', value: _t['push']!, onChanged: (v) => _set('push', v, 'Push notifications')),
            SettingsSwitchTile(icon: Icons.event_rounded, label: 'Appointment reminders', color: p.accent, value: _t['appt']!, onChanged: (v) => _set('appt', v, 'Appointment reminders')),
            SettingsSwitchTile(icon: Icons.medication_rounded, label: 'Medicine reminders', color: p.success, value: _t['med']!, onChanged: (v) => _set('med', v, 'Medicine reminders')),
            SettingsSwitchTile(icon: Icons.local_offer_rounded, label: 'Promotional offers', color: p.warning, value: _t['promo']!, onChanged: (v) => _set('promo', v, 'Offers')),
          ]),
          Gap.v(20),
          SettingsGroup(title: 'Privacy & display', children: [
            SettingsSwitchTile(icon: Icons.fingerprint_rounded, label: 'Biometric lock', subtitle: 'Require fingerprint / face to open the app', value: _t['bio']!, onChanged: (v) => _set('bio', v, 'Biometric lock')),
            SettingsSwitchTile(
              icon: Icons.dark_mode_rounded,
              label: 'Dark mode',
              color: const Color(0xFF6C5CE7),
              value: dark,
              onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light,
            ),
            SettingsSwitchTile(icon: Icons.data_saver_on_rounded, label: 'Data saver', subtitle: 'Lower video quality on mobile data', color: p.textSecondary, value: _t['data']!, onChanged: (v) => _set('data', v, 'Data saver')),
          ]),
          Gap.v(20),
          SettingsGroup(title: 'Storage', children: [
            SettingsTile(
              icon: Icons.cleaning_services_rounded,
              label: 'Clear cache',
              subtitle: '24.6 MB used',
              color: p.warning,
              onTap: _clearing ? null : _clearCache,
              trailing: _clearing ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: p.primary)) : Icon(Icons.chevron_right_rounded, color: p.textTertiary),
            ),
          ]),
          Gap.v(20),
          SettingsGroup(title: 'About', children: [
            SettingsTile(icon: Icons.info_outline_rounded, label: 'About ${AppConfig.appName}', trailingText: 'v1.0.0', onTap: () => showAppSnack(context, '${AppConfig.appName} v1.0.0 (build 1) – ${AppConfig.tagline}', icon: Icons.info_outline_rounded)),
            SettingsTile(icon: Icons.description_rounded, label: 'Terms of service', color: p.textSecondary, onTap: () => _legal('Terms of service', 'By using ${AppConfig.appName} you agree to book appointments responsibly and provide accurate health information. This is a prototype; no real bookings are made.')),
            SettingsTile(icon: Icons.privacy_tip_rounded, label: 'Privacy policy', color: p.textSecondary, onTap: () => _legal('Privacy policy', 'All data in this prototype is mock data stored on your device. Nothing is uploaded or shared.')),
          ]),
          Gap.v(20),
          SettingsGroup(title: 'Danger zone', children: [
            SettingsTile(icon: Icons.delete_forever_rounded, label: 'Delete account', danger: true, onTap: _delete),
          ]),
        ],
      ),
    );
  }
}
