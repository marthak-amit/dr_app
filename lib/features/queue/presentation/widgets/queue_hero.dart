import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';

/// Gradient hero: token, position, wait estimate + animated progress ring.
class QueueHero extends StatelessWidget {
  const QueueHero({super.key, required this.state});
  final QueueState state;

  @override
  Widget build(BuildContext context) {
    final me = state.me!;
    final before = state.entries.where((e) => e.token < me.token).toList();
    final doneBefore = before.where((e) => e.status == QueueStatus.done || e.status == QueueStatus.skipped).length;
    final frac = me.status == QueueStatus.done || me.status == QueueStatus.inConsult
        ? 1.0
        : (before.isEmpty ? 1.0 : (doneBefore + (state.current != null ? .5 : 0)) / before.length).clamp(0.0, 1.0);

    String title;
    switch (me.status) {
      case QueueStatus.inConsult:
        title = "It's your turn!";
      case QueueStatus.done:
        title = 'Visit completed';
      case QueueStatus.skipped:
        title = 'Token skipped';
      case QueueStatus.waiting:
        title = 'You are #${state.myPosition} in line';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A5C64), Color(0xFF0E7C86), Color(0xFF1FA5AE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .35), blurRadius: 28, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YOUR TOKEN', style: context.tt.labelSmall!.copyWith(color: Colors.white70, letterSpacing: 1.4)),
              Text('#${me.token}', style: context.tt.displayLarge!.copyWith(color: Colors.white, fontSize: 60, height: 1.05)),
            ]),
          ),
          SizedBox(
            width: 92,
            height: 92,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: frac),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Stack(alignment: Alignment.center, children: [
                SizedBox.expand(child: CircularProgressIndicator(value: 1, strokeWidth: 9, color: Colors.white.withValues(alpha: .18))),
                SizedBox.expand(child: CircularProgressIndicator(value: v, strokeWidth: 9, strokeCap: StrokeCap.round, color: Colors.white)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(v * 100).round()}%', style: context.tt.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  Text('there', style: context.tt.labelSmall!.copyWith(color: Colors.white70)),
                ]),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(title, style: context.tt.headlineSmall!.copyWith(color: Colors.white)).animate(key: ValueKey(title)).fadeIn(duration: 300.ms).slideY(begin: .2),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _HeroChip(icon: Icons.campaign_rounded, label: 'Now serving', value: state.current != null ? '#${state.current!.token}' : '—'),
          _HeroChip(
            icon: Icons.timer_outlined,
            label: 'Est. wait',
            value: me.status == QueueStatus.waiting ? '~${state.estimatedWaitMinutes} min' : (me.status == QueueStatus.inConsult ? 'Now' : '—'),
          ),
          _HeroChip(icon: Icons.groups_rounded, label: 'Ahead of you', value: me.status == QueueStatus.waiting ? '${state.aheadOfMe}' : '0'),
        ]),
      ]),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: context.tt.labelSmall!.copyWith(color: Colors.white70, fontSize: 10)),
          Text(value, style: context.tt.labelLarge!.copyWith(color: Colors.white)),
        ]),
      ]),
    );
  }
}
