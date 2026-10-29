import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

/// Doctor card with live status chip.
class QueueDoctorCard extends StatelessWidget {
  const QueueDoctorCard({super.key, required this.doctor, required this.status});
  final Doctor doctor;
  final DoctorStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final clinic = clinicById(doctor.clinicId);
    final (label, color, bg) = switch (status) {
      DoctorStatus.inConsult => ('In consultation', p.success, p.successSoft),
      DoctorStatus.onBreak => ('On a short break', p.warning, p.warningSoft),
      DoctorStatus.idle => ('Available', p.primary, p.primarySoft),
    };
    return AppCard(
      child: Row(children: [
        DoctorAvatar(doctor: doctor, size: 60, hero: false),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doctor.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${doctor.specialty} · ${clinic.name}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(status),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(.7, .7), end: const Offset(1.3, 1.3), duration: 800.ms),
                  const SizedBox(width: 6),
                  Text(label, style: context.tt.labelMedium!.copyWith(color: color, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Anonymised timeline of the queue.
class QueueTimeline extends StatelessWidget {
  const QueueTimeline({super.key, required this.state});
  final QueueState state;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final active = state.entries.where((e) => e.status == QueueStatus.inConsult || e.status == QueueStatus.waiting).toList()..sort((a, b) => a.token.compareTo(b.token));
    final done = state.doneCount;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Queue status', style: context.tt.titleMedium),
        const SizedBox(height: 4),
        Text('$done patient${done == 1 ? '' : 's'} completed today', style: context.tt.bodySmall),
        const SizedBox(height: 12),
        if (active.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('Everyone has been seen. 🎉', style: context.tt.bodyMedium))
        else
          for (var i = 0; i < active.length; i++) _TimelineRow(entry: active[i], first: i == 0, last: i == active.length - 1, pal: p),
      ]),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.first, required this.last, required this.pal});
  final QueueEntry entry;
  final bool first, last;
  final AppPalette pal;

  @override
  Widget build(BuildContext context) {
    final p = pal;
    final serving = entry.status == QueueStatus.inConsult;
    final me = entry.isMe;
    final dotColor = serving ? p.success : (me ? p.accent : p.textTertiary);
    final text = me ? 'Your token #${entry.token}' : 'Token #${entry.token}';
    final sub = serving ? 'In consultation' : (me ? 'That\'s you' : 'In queue');
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 28,
          child: Column(children: [
            Expanded(child: Container(width: 2, color: first ? Colors.transparent : p.border)),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: serving || me ? dotColor : p.surface, shape: BoxShape.circle, border: Border.all(color: dotColor, width: 2.5)),
            ),
            Expanded(child: Container(width: 2, color: last ? Colors.transparent : p.border)),
          ]),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: me ? p.accentSoft : (serving ? p.successSoft : p.surfaceAlt),
              borderRadius: AppRadius.rMd,
              border: me ? Border.all(color: p.accent.withValues(alpha: .6), width: 1.4) : null,
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(text, style: context.tt.titleSmall!.copyWith(color: me ? p.accent : null)),
                  Text(sub, style: context.tt.bodySmall!.copyWith(color: serving ? p.success : null)),
                ]),
              ),
              if (serving) Icon(Icons.medical_services_rounded, size: 20, color: p.success),
              if (me && !serving) Icon(Icons.person_pin_circle_rounded, size: 22, color: p.accent),
            ]),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 250.ms);
  }
}
