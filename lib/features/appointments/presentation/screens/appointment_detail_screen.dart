import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/appointment_providers.dart';
import '../widgets/appointment_sheets.dart';
import '../widgets/appointment_utils.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appointmentsProvider);
    final a = ref.watch(appointmentByIdProvider(appointmentId));
    return Scaffold(
      appBar: const AppTopBar(title: 'Appointment details'),
      body: async.when(
        loading: () => const ShimmerList(itemCount: 3, itemHeight: 150),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(appointmentsProvider)),
        data: (_) => a == null
            ? EmptyState(icon: Icons.search_off_rounded, title: 'Appointment not found', message: 'This appointment may have been removed.', actionLabel: 'Go to visits', onAction: () => context.go(Routes.appointments))
            : _Body(a: a),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.a});
  final Appointment a;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final doc = doctorById(a.doctorId);
    final clinic = clinicById(a.clinicId);
    final st = statusStyle(context, a.status);
    final video = a.type == ConsultType.video;
    final token = tokenFor(a);
    final gst = gstOn(platformFee);
    final total = a.fee + platformFee + gst;

    final items = <Widget>[
      // Status header
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: a.status == AppointmentStatus.upcoming ? AppColors.gradientPrimary : null,
          color: a.status == AppointmentStatus.upcoming ? null : st.bg,
          borderRadius: AppRadius.rXl,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: a.status == AppointmentStatus.upcoming ? Colors.white.withValues(alpha: .2) : p.surface, borderRadius: AppRadius.rPill),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(st.icon, size: 14, color: a.status == AppointmentStatus.upcoming ? Colors.white : st.fg),
                const SizedBox(width: 5),
                Text(st.label, style: context.tt.labelMedium!.copyWith(color: a.status == AppointmentStatus.upcoming ? Colors.white : st.fg)),
              ]),
            ),
            const Spacer(),
            if (token != null && a.status != AppointmentStatus.cancelled)
              Text('Token #$token', style: context.tt.titleSmall!.copyWith(color: a.status == AppointmentStatus.upcoming ? Colors.white : p.textPrimary)),
          ]),
          const SizedBox(height: 16),
          Text(
            fmtTime(a.dateTime),
            style: context.tt.displaySmall!.copyWith(color: a.status == AppointmentStatus.upcoming ? Colors.white : p.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            '${relativeDay(a.dateTime)} · ${fmtDateLong(a.dateTime)}',
            style: context.tt.bodyLarge!.copyWith(color: a.status == AppointmentStatus.upcoming ? Colors.white.withValues(alpha: .9) : p.textSecondary),
          ),
          if (a.status == AppointmentStatus.cancelled && a.cancelReason != null) ...[
            const SizedBox(height: 10),
            Text('Reason: ${a.cancelReason}', style: context.tt.bodyMedium!.copyWith(color: p.danger)),
          ],
        ]),
      ),
      // Doctor
      AppCard(
        onTap: () => context.push(Routes.doctor(doc.id)),
        child: Row(children: [
          DoctorAvatar(doctor: doc, size: 64, hero: false),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(doc.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
            const SizedBox(height: 4),
            RatingBadge(rating: doc.rating, count: doc.reviewCount),
          ])),
          Icon(Icons.chevron_right_rounded, color: p.textTertiary),
        ]),
      ),
      // Visit info
      AppCard(
        child: Column(children: [
          _Row(icon: video ? Icons.videocam_rounded : Icons.local_hospital_rounded, label: 'Consultation', value: typeLabel(a.type)),
          _Row(icon: Icons.person_outline_rounded, label: 'Patient', value: a.patientName),
          _Row(icon: Icons.medical_information_outlined, label: 'Reason', value: a.reason),
          _Row(icon: Icons.tag_rounded, label: 'Booking ID', value: bookingCode(a), last: true),
        ]),
      ),
      // Clinic
      if (!video)
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              child: SizedBox(height: 110, width: double.infinity, child: Image.asset(clinic.image, fit: BoxFit.cover, cacheWidth: 800)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(clinic.name, style: context.tt.titleMedium),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.location_on_rounded, size: 16, color: p.accent),
                  const SizedBox(width: 6),
                  Expanded(child: Text(clinic.address, style: context.tt.bodyMedium)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: AppButton(label: 'Call', icon: Icons.call_rounded, variant: AppButtonVariant.secondary, size: AppButtonSize.small, onPressed: () => showAppSnack(context, 'Calling ${clinic.phone}…', icon: Icons.call_rounded))),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton(label: 'Directions', icon: Icons.directions_rounded, variant: AppButtonVariant.outline, size: AppButtonSize.small, onPressed: () => showAppSnack(context, 'Opening maps – ${clinic.distanceKm} km away', icon: Icons.map_rounded))),
                ]),
              ]),
            ),
          ]),
        ),
      // Payment
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment summary', style: context.tt.titleMedium),
          const SizedBox(height: 12),
          _Money(label: 'Consultation fee', value: rupees(a.fee)),
          _Money(label: 'Platform fee', value: rupees(platformFee)),
          _Money(label: 'GST (18%)', value: rupees(gst)),
          const Divider(height: 24),
          _Money(label: 'Total', value: rupees(total), bold: true),
          const SizedBox(height: 12),
          Row(children: [
            Icon(paymentIcon(a.payment), size: 18, color: p.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(paymentLabel(a.payment), style: context.tt.bodyMedium)),
            StatusChip(
              label: a.status == AppointmentStatus.cancelled ? (a.paid ? 'Refunded' : 'Void') : (a.paid ? 'Paid' : 'Pay at clinic'),
              color: a.paid ? p.success : p.warning,
              bg: a.paid ? p.successSoft : p.warningSoft,
              dense: true,
            ),
          ]),
        ]),
      ),
      ..._actions(context, doc),
      Center(
        child: TextButton.icon(
          onPressed: () => context.push(Routes.chat),
          icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: p.primary),
          label: Text('Need help? Chat with clinic', style: context.tt.labelMedium!.copyWith(color: p.primary)),
        ),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => items[i].animate(delay: (50 * i).ms).fadeIn(duration: 320.ms).slideY(begin: .05, curve: Curves.easeOutCubic),
    );
  }

  List<Widget> _actions(BuildContext context, Doctor doc) {
    final video = a.type == ConsultType.video;
    final receipt = AppButton(
      label: 'Download receipt',
      icon: Icons.download_rounded,
      variant: AppButtonVariant.outline,
      onPressed: () => showAppSnack(context, 'Receipt saved to Downloads', icon: Icons.download_done_rounded),
    );
    switch (a.status) {
      case AppointmentStatus.upcoming:
        return [
          if (video)
            AppButton(label: 'Join video call', icon: Icons.videocam_rounded, onPressed: () => context.push(Routes.video(a.id)))
          else if (a.isToday)
            AppButton(label: 'Track live queue', icon: Icons.groups_rounded, variant: AppButtonVariant.accent, onPressed: () => context.push(Routes.queue)),
          Row(children: [
            Expanded(child: AppButton(label: 'Reschedule', variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: () => showRescheduleSheet(context, a))),
            const SizedBox(width: 12),
            Expanded(child: AppButton(label: 'Cancel', variant: AppButtonVariant.danger, size: AppButtonSize.medium, onPressed: () => showCancelSheet(context, a))),
          ]),
          receipt,
        ];
      case AppointmentStatus.completed:
        return [
          AppButton(label: 'View prescription', icon: Icons.description_outlined, onPressed: () => context.push(Routes.prescriptions)),
          Row(children: [
            Expanded(child: AppButton(label: 'Book again', variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: () => context.push(Routes.book(a.doctorId)))),
            const SizedBox(width: 12),
            Expanded(child: AppButton(label: 'Rate visit', icon: Icons.star_rounded, variant: AppButtonVariant.outline, size: AppButtonSize.medium, onPressed: () => showRateSheet(context, doc))),
          ]),
          receipt,
        ];
      case AppointmentStatus.cancelled:
        return [AppButton(label: 'Rebook this doctor', icon: Icons.replay_rounded, onPressed: () => context.push(Routes.book(a.doctorId))), receipt];
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, this.last = false});
  final IconData icon;
  final String label, value;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rSm), child: Icon(icon, size: 18, color: p.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: context.tt.bodySmall), Text(value, style: context.tt.titleSmall)])),
      ]),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.label, required this.value, this.bold = false});
  final String label, value;
  final bool bold;
  @override
  Widget build(BuildContext context) {
    final s = bold ? context.tt.titleMedium : context.tt.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label, style: s)), Text(value, style: bold ? s : s!.copyWith(color: context.pal.textPrimary, fontWeight: FontWeight.w600))]),
    );
  }
}
