import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

/// Striking gradient card shown when the next visit is today (in-clinic).
class LiveQueueCard extends ConsumerWidget {
  const LiveQueueCard({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = ref.watch(queueProvider);
    final me = q.me;
    if (me == null) return const SizedBox.shrink();
    final doctor = doctorById(appointment.doctorId);
    final done = me.status == QueueStatus.done;
    final progress = q.entries.isEmpty ? 0.0 : (q.doneCount + (q.current != null ? .5 : 0)) / q.entries.length;
    final nowServing = q.current?.token;

    return TapScale(
      scale: .98,
      onTap: () => context.push(Routes.queue),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0A5C64), Color(0xFF0E7C86), Color(0xFF1AA7B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: AppRadius.rXl,
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .35), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Stack(children: [
          Positioned(right: -30, top: -40, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .07)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: AppRadius.rPill),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5EEAC0), shape: BoxShape.circle))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: .3, end: 1, duration: 800.ms),
                  const SizedBox(width: 6),
                  Text('LIVE QUEUE', style: context.tt.labelSmall!.copyWith(color: Colors.white, letterSpacing: 1)),
                ]),
              ),
              const Spacer(),
              Text(doctor.name, style: context.tt.labelMedium!.copyWith(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(done ? 'Visit completed' : 'You are #${q.myPosition}', style: context.tt.headlineMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    done ? 'Thank you for visiting!' : (q.aheadOfMe == 0 ? 'You are next — please be ready' : 'Est. wait ~${q.estimatedWaitMinutes} min · ${q.aheadOfMe} ahead'),
                    style: context.tt.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: .85)),
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Column(children: [
                Text('NOW', style: context.tt.labelSmall!.copyWith(color: Colors.white70)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.rMd),
                  child: Text(nowServing == null ? '–' : '#$nowServing', style: context.tt.titleLarge!.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                ),
              ]),
            ]),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0, 1)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => ClipRRect(
                borderRadius: AppRadius.rPill,
                child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: Colors.white.withValues(alpha: .2), valueColor: const AlwaysStoppedAnimation(Color(0xFF5EEAC0))),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Text('Token #${me.token} · ${fmtTime(appointment.dateTime)}', style: context.tt.labelMedium!.copyWith(color: Colors.white))),
              Text('Track live', style: context.tt.labelMedium!.copyWith(color: Colors.white)),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
            ]),
          ]),
        ]),
      ),
    );
  }
}
