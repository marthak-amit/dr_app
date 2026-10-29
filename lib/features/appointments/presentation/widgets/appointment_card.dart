import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import 'appointment_sheets.dart';
import 'appointment_utils.dart';

/// Appointment summary card used in the visits list.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final a = appointment;
    final doc = doctorById(a.doctorId);
    final st = statusStyle(context, a.status);
    final video = a.type == ConsultType.video;
    return AppCard(
      onTap: () => context.push(Routes.appointment(a.id)),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DoctorAvatar(doctor: doc, size: 60, hero: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(doc.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.person_outline_rounded, size: 14, color: p.textTertiary),
                const SizedBox(width: 4),
                Expanded(child: Text(a.patientName, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          StatusChip(label: st.label, color: st.fg, bg: st.bg, dense: true),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rSm),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: p.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(fmtWhen(a.dateTime), style: context.tt.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Icon(video ? Icons.videocam_rounded : Icons.local_hospital_rounded, size: 16, color: video ? p.accent : p.primary),
            const SizedBox(width: 4),
            Text(video ? 'Video' : 'In-clinic', style: context.tt.labelMedium!.copyWith(color: video ? p.accent : p.primary)),
          ]),
        ),
        const SizedBox(height: 10),
        Text(a.reason, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (a.status == AppointmentStatus.cancelled && a.cancelReason != null) ...[
          const SizedBox(height: 4),
          Text('Reason: ${a.cancelReason}', style: context.tt.bodySmall!.copyWith(color: p.danger), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
        const SizedBox(height: 12),
        _Actions(appointment: a),
      ]),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final doc = doctorById(a.doctorId);
    Widget row(List<Widget> kids) => Row(children: [
          for (var i = 0; i < kids.length; i++) ...[if (i > 0) const SizedBox(width: 10), Expanded(child: kids[i])],
        ]);
    switch (a.status) {
      case AppointmentStatus.upcoming:
        final primary = a.type == ConsultType.video
            ? AppButton(label: 'Join video call', icon: Icons.videocam_rounded, size: AppButtonSize.medium, onPressed: () => context.push(Routes.video(a.id)))
            : (a.isToday ? AppButton(label: 'Track live queue', icon: Icons.groups_rounded, variant: AppButtonVariant.accent, size: AppButtonSize.medium, onPressed: () => context.push(Routes.queue)) : null);
        return Column(children: [
          if (primary != null) ...[primary, const SizedBox(height: 10)],
          row([
            AppButton(label: 'Reschedule', variant: AppButtonVariant.outline, size: AppButtonSize.small, onPressed: () => showRescheduleSheet(context, a)),
            AppButton(label: 'Cancel', variant: AppButtonVariant.danger, size: AppButtonSize.small, onPressed: () => showCancelSheet(context, a)),
          ]),
        ]);
      case AppointmentStatus.completed:
        return row([
          AppButton(label: 'Prescription', icon: Icons.description_outlined, variant: AppButtonVariant.secondary, size: AppButtonSize.small, onPressed: () => context.push(Routes.prescriptions)),
          AppButton(label: 'Book again', variant: AppButtonVariant.outline, size: AppButtonSize.small, onPressed: () => context.push(Routes.book(a.doctorId))),
          AppButton(label: 'Rate', icon: Icons.star_rounded, variant: AppButtonVariant.text, size: AppButtonSize.small, onPressed: () => showRateSheet(context, doc)),
        ]);
      case AppointmentStatus.cancelled:
        return row([AppButton(label: 'Rebook', icon: Icons.replay_rounded, variant: AppButtonVariant.secondary, size: AppButtonSize.small, onPressed: () => context.push(Routes.book(a.doctorId)))]);
    }
  }
}
