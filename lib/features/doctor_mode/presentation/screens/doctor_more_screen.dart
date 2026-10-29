import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../widgets/doctor_widgets.dart';

class DoctorMoreScreen extends ConsumerStatefulWidget {
  const DoctorMoreScreen({super.key});

  @override
  ConsumerState<DoctorMoreScreen> createState() => _DoctorMoreScreenState();
}

class _DoctorMoreScreenState extends ConsumerState<DoctorMoreScreen> {
  bool _clinicConsult = true;
  bool _videoConsult = true;
  bool _accepting = true;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final doc = doctorById(kDoctorModeDoctorId);
    final clinic = clinicById(doc.clinicId);
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 28), children: [
          Row(children: [
            Expanded(child: Text('Profile', style: context.tt.headlineMedium)),
            const DoctorModeChip(),
          ]),
          const SizedBox(height: 16),
          animIn(
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: AppRadius.rXl, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .28), blurRadius: 22, offset: const Offset(0, 10))]),
              child: Column(children: [
                Row(children: [
                  DoctorAvatar(doctor: doc, size: 76, radius: 24, hero: false),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doc.name, style: context.tt.titleLarge!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${doc.specialty} · ${doc.qualification.split(',').first}', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .85)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.local_hospital_rounded, size: 14, color: Colors.white.withValues(alpha: .85)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(clinic.name, style: context.tt.bodySmall!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _Stat(value: '${doc.rating}', label: 'Rating'),
                  _Stat(value: '${doc.experienceYears}y', label: 'Experience'),
                  _Stat(value: '${(doc.patients / 1000).toStringAsFixed(1)}K', label: 'Patients'),
                ]),
              ]),
            ),
            0,
          ),
          const SizedBox(height: 16),
          animIn(
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(children: [
                _SwitchRow(icon: Icons.local_hospital_rounded, title: 'In-clinic consults', sub: '${rupees(doc.fee)} per visit', value: _clinicConsult, onChanged: (v) {
                  setState(() => _clinicConsult = v);
                  showAppSnack(context, v ? 'In-clinic bookings enabled' : 'In-clinic bookings paused', icon: Icons.local_hospital_rounded);
                }),
                Divider(color: p.border),
                _SwitchRow(icon: Icons.videocam_rounded, title: 'Video consults', sub: '${rupees(doc.videoFee)} per call', value: _videoConsult, onChanged: (v) {
                  setState(() => _videoConsult = v);
                  showAppSnack(context, v ? 'Video consults enabled' : 'Video consults paused', icon: Icons.videocam_rounded);
                }),
                Divider(color: p.border),
                _SwitchRow(icon: Icons.event_available_rounded, title: 'Accepting new patients', sub: 'Show my profile in search', value: _accepting, onChanged: (v) {
                  setState(() => _accepting = v);
                  showAppSnack(context, v ? 'You are visible to new patients' : 'New bookings paused', icon: Icons.event_available_rounded);
                }),
              ]),
            ),
            1,
          ),
          const SizedBox(height: 16),
          animIn(
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(children: [
                _Row(icon: Icons.apartment_rounded, title: 'Clinic details', sub: clinic.address, onTap: () => _info(context, 'Clinic details', [clinic.name, clinic.address, clinic.phone, 'Hours: ${clinic.openHours}'])),
                _Row(icon: Icons.currency_rupee_rounded, title: 'Fees & earnings', sub: 'This month ₹3,42,000', onTap: () => _info(context, 'Earnings', ['This month: ₹3,42,000', 'Last month: ₹3,18,500', 'Pending payout: ₹48,000', 'Next payout: Friday'])),
                _Row(icon: Icons.reviews_rounded, title: 'Patient reviews', sub: '${doc.reviewCount} reviews · ${doc.rating} avg', onTap: () => _reviews(context, doc)),
                _Row(icon: Icons.notifications_none_rounded, title: 'Notifications', sub: 'Bookings, cancellations, reports', onTap: () => showAppSnack(context, 'Notification preferences saved', icon: Icons.notifications_active_rounded)),
                _Row(icon: Icons.settings_outlined, title: 'Settings', sub: 'Language, privacy, security', last: true, onTap: () => showAppSnack(context, 'Settings are shared with the patient app', icon: Icons.settings_rounded)),
              ]),
            ),
            2,
          ),
          const SizedBox(height: 16),
          animIn(
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _SwitchRow(icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, title: 'Dark mode', sub: dark ? 'On' : 'Off', value: dark, onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light),
            ),
            3,
          ),
          const SizedBox(height: 24),
          animIn(
            AppButton(label: 'Switch to Patient view', icon: Icons.swap_horiz_rounded, onPressed: () {
              ref.read(appModeProvider.notifier).state = AppMode.patient;
              context.go(Routes.home);
            }),
            4,
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Log out', icon: Icons.logout_rounded, variant: AppButtonVariant.danger, onPressed: () async {
            final ok = await showConfirmSheet(context, title: 'Log out?', message: 'You will need to sign in again with your phone number.', confirmLabel: 'Log out', destructive: true, icon: Icons.logout_rounded);
            if (!ok || !context.mounted) return;
            ref.read(sessionProvider.notifier).logout();
            ref.read(appModeProvider.notifier).state = AppMode.patient;
            context.go(Routes.login);
          }),
          const SizedBox(height: 16),
          Center(child: Text('${AppConfig.appName} for Doctors · v1.0.0', style: context.tt.bodySmall)),
        ]),
      ),
    );
  }

  void _info(BuildContext context, String title, List<String> lines) {
    showAppBottomSheet<void>(context, title: title, builder: (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final l in lines) Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_circle_outline_rounded, size: 18, color: ctx.pal.primary), const SizedBox(width: 10), Expanded(child: Text(l, style: ctx.tt.bodyLarge))])),
          const SizedBox(height: 16),
          AppButton(label: 'Close', variant: AppButtonVariant.secondary, onPressed: () => Navigator.pop(ctx)),
        ]));
  }

  void _reviews(BuildContext context, Doctor doc) {
    showAppBottomSheet<void>(context, title: 'Patient reviews', builder: (ctx) => Column(children: [
          for (final r in doc.reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(r.author, style: ctx.tt.titleSmall)), RatingBadge(rating: r.rating)]),
                const SizedBox(height: 4),
                Text(r.text, style: ctx.tt.bodyMedium),
                Text('${r.daysAgo} days ago', style: ctx.tt.bodySmall),
              ]),
            ),
        ]));
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: AppRadius.rMd),
          child: Column(children: [
            Text(value, style: context.tt.titleMedium!.copyWith(color: Colors.white)),
            Text(label, style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .85))),
          ]),
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.title, required this.sub, required this.value, required this.onChanged});
  final IconData icon;
  final String title, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rSm), child: Icon(icon, size: 20, color: p.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleSmall), Text(sub, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)])),
        Switch(value: value, onChanged: onChanged),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, required this.sub, required this.onTap, this.last = false});
  final IconData icon;
  final String title, sub;
  final VoidCallback onTap;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rSm), child: Icon(icon, size: 20, color: p.textSecondary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleSmall), Text(sub, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)])),
          Icon(Icons.chevron_right_rounded, color: p.textTertiary),
        ]),
      ),
    );
  }
}
