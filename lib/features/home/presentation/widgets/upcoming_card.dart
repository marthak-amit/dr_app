import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final d = doctorById(appointment.doctorId);
    final clinic = clinicById(appointment.clinicId);
    final video = appointment.type == ConsultType.video;
    return AppCard(
      onTap: () => context.push(Routes.appointment(appointment.id)),
      padding: const EdgeInsets.all(16),
      radius: AppRadius.xl,
      child: Column(children: [
        Row(children: [
          DoctorAvatar(doctor: d, size: 60, hero: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(d.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
              const SizedBox(height: 4),
              Text('For ${appointment.patientName}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          StatusChip(label: video ? 'Video' : 'In-clinic', color: video ? p.accent : p.primary, bg: video ? p.accentSoft : p.primarySoft, icon: video ? Icons.videocam_rounded : Icons.local_hospital_rounded, dense: true),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: p.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(fmtWhen(appointment.dateTime), style: context.tt.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Icon(video ? Icons.videocam_outlined : Icons.location_on_outlined, size: 16, color: p.primary),
            const SizedBox(width: 4),
            Flexible(child: Text(video ? 'Online' : clinic.name, style: context.tt.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppButton(label: 'Details', variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: () => context.push(Routes.appointment(appointment.id)))),
          const SizedBox(width: 12),
          Expanded(
            child: video
                ? AppButton(label: 'Join call', icon: Icons.videocam_rounded, size: AppButtonSize.medium, variant: AppButtonVariant.accent, onPressed: () => context.push(Routes.video(appointment.id)))
                : AppButton(label: 'Directions', icon: Icons.near_me_rounded, size: AppButtonSize.medium, onPressed: () => showAppSnack(context, 'Opening directions to ${clinic.name}…', icon: Icons.near_me_rounded)),
          ),
        ]),
      ]),
    );
  }
}

class NoUpcomingCard extends StatelessWidget {
  const NoUpcomingCard({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      radius: AppRadius.xl,
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: p.primarySoft, shape: BoxShape.circle), child: Icon(Icons.event_available_rounded, color: p.primary)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('No upcoming visits', style: context.tt.titleSmall),
            Text('Book a doctor in under a minute.', style: context.tt.bodySmall),
          ]),
        ),
        AppButton(label: 'Book', expand: false, size: AppButtonSize.small, variant: AppButtonVariant.accent, onPressed: () => context.push(Routes.search())),
      ]),
    );
  }
}
