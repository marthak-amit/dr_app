import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../providers/doctor_providers.dart';
import '../widgets/doctor_widgets.dart';

class QueueControlScreen extends ConsumerStatefulWidget {
  const QueueControlScreen({super.key});

  @override
  ConsumerState<QueueControlScreen> createState() => _QueueControlScreenState();
}

class _QueueControlScreenState extends ConsumerState<QueueControlScreen> {
  bool _showDone = false;
  bool _showSkipped = true;

  Future<void> _refresh() async {
    ref.invalidate(doctorDashboardLoadProvider);
    await ref.read(doctorDashboardLoadProvider.future);
  }

  void _haptic() => HapticFeedback.mediumImpact();

  void _callNext() {
    final q = ref.read(queueProvider);
    if (q.waiting.isEmpty && q.current == null) {
      showAppSnack(context, 'No patients waiting in the queue', icon: Icons.info_outline_rounded);
      return;
    }
    _haptic();
    ref.read(queueProvider.notifier).callNext();
    final c = ref.read(queueProvider).current;
    showAppSnack(context, c != null ? 'Token #${c.token} called · ${c.patient.name}' : 'Queue complete — all patients seen', icon: Icons.campaign_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final load = ref.watch(doctorDashboardLoadProvider);
    final q = ref.watch(queueProvider);
    final skipped = q.entries.where((e) => e.status == QueueStatus.skipped).toList();
    final done = q.entries.where((e) => e.status == QueueStatus.done).toList();
    final waiting = q.waiting;
    final canCall = waiting.isNotEmpty || q.current != null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Queue control', style: context.tt.headlineMedium),
                  const SizedBox(height: 4),
                  const DoctorModeChip(),
                ]),
              ),
              _StatusPill(status: q.doctorStatus),
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
              color: p.primary,
              onRefresh: _refresh,
              child: load.when(
                loading: () => const ShimmerList(itemCount: 5, itemHeight: 96),
                error: (_, __) => ListView(children: [SizedBox(height: 400, child: ErrorState(onRetry: _refresh))]),
                data: (_) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _Summary(waiting: waiting.length, done: done.length, avg: q.avgMinutes, onBreak: q.doctorStatus == DoctorStatus.onBreak, onToggleBreak: () {
                      _haptic();
                      ref.read(queueProvider.notifier).toggleBreak();
                      final b = ref.read(queueProvider).doctorStatus == DoctorStatus.onBreak;
                      showAppSnack(context, b ? 'You are on a break — patients are notified' : 'Welcome back! Queue resumed', icon: b ? Icons.free_breakfast_rounded : Icons.play_circle_rounded);
                    }),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: c)),
                      child: q.current != null
                          ? _NowCard(key: ValueKey(q.current!.id), entry: q.current!, onDone: () {
                              _haptic();
                              ref.read(queueProvider.notifier).markDone(q.current!.id);
                              showAppSnack(context, 'Consultation completed · Token #${q.current!.token}', icon: Icons.task_alt_rounded);
                            }, onNext: _callNext, onOpen: () => context.push(Routes.drPatient(q.current!.patient.id)))
                          : _NoCurrent(key: const ValueKey('none'), onBreak: q.doctorStatus == DoctorStatus.onBreak),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Text('Waiting', style: context.tt.titleLarge),
                      const SizedBox(width: 8),
                      StatusChip(label: '${waiting.length}', color: p.warning, bg: p.warningSoft, dense: true),
                    ]),
                    const SizedBox(height: 4),
                    Text('Swipe right to call · swipe left to skip', style: context.tt.bodySmall),
                    const SizedBox(height: 12),
                    if (waiting.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(children: [
                          Icon(Icons.inbox_rounded, size: 40, color: p.textTertiary),
                          const SizedBox(height: 10),
                          Text('No one waiting', style: context.tt.titleMedium),
                          Text('New check-ins will appear here instantly.', style: context.tt.bodySmall, textAlign: TextAlign.center),
                        ]),
                      )
                    else
                      for (var i = 0; i < waiting.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WaitingRow(
                            key: ValueKey(waiting[i].id),
                            entry: waiting[i],
                            first: i == 0,
                            onCall: () {
                              _haptic();
                              ref.read(queueProvider.notifier).callPatient(waiting[i].id);
                              showAppSnack(context, 'Token #${waiting[i].token} called · ${waiting[i].patient.name}', icon: Icons.campaign_rounded);
                            },
                            onSkip: () {
                              _haptic();
                              ref.read(queueProvider.notifier).skip(waiting[i].id);
                              showAppSnack(context, 'Token #${waiting[i].token} skipped', icon: Icons.skip_next_rounded);
                            },
                          ).animate().fadeIn(duration: 300.ms, delay: (40 * i).ms).slideX(begin: .05, end: 0),
                        ),
                    if (skipped.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _CollapseHeader(title: 'Skipped', count: skipped.length, open: _showSkipped, onTap: () => setState(() => _showSkipped = !_showSkipped)),
                      if (_showSkipped) for (final e in skipped) _MiniRow(entry: e, trailing: 'Skipped', color: p.danger, bg: p.dangerSoft, onRecall: () {
                        ref.read(queueProvider.notifier).callPatient(e.id);
                        showAppSnack(context, 'Token #${e.token} recalled', icon: Icons.replay_rounded);
                      }),
                    ],
                    const SizedBox(height: 8),
                    _CollapseHeader(title: 'Completed', count: done.length, open: _showDone, onTap: () => setState(() => _showDone = !_showDone)),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.topCenter,
                      child: _showDone ? Column(children: [for (final e in done) _MiniRow(entry: e, trailing: 'Done', color: p.success, bg: p.successSoft)]) : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            decoration: BoxDecoration(color: p.bg, border: Border(top: BorderSide(color: p.border))),
            child: AppButton(label: waiting.isEmpty && q.current != null ? 'Finish last consultation' : 'Call next patient', icon: Icons.campaign_rounded, onPressed: canCall ? _callNext : null, variant: AppButtonVariant.accent),
          ),
        ]),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final DoctorStatus status;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final (l, c, bg) = switch (status) {
      DoctorStatus.inConsult => ('In consult', p.success, p.successSoft),
      DoctorStatus.onBreak => ('On break', p.warning, p.warningSoft),
      DoctorStatus.idle => ('Available', p.primary, p.primarySoft),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)).animate(onPlay: (a) => a.repeat(reverse: true)).fade(begin: .4, end: 1, duration: 800.ms),
        const SizedBox(width: 8),
        Text(l, style: context.tt.labelMedium!.copyWith(color: c, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.waiting, required this.done, required this.avg, required this.onBreak, required this.onToggleBreak});
  final int waiting, done, avg;
  final bool onBreak;
  final VoidCallback onToggleBreak;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget cell(String v, String l, Color c) => Expanded(
          child: Column(children: [
            Text(v, style: context.tt.headlineSmall!.copyWith(color: c)),
            Text(l, style: context.tt.bodySmall),
          ]),
        );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [cell('$waiting', 'Waiting', p.warning), cell('$done', 'Done', p.success), cell('$avg min', 'Avg / patient', p.primary)]),
        const SizedBox(height: 14),
        Divider(color: p.border),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.free_breakfast_rounded, size: 20, color: p.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(onBreak ? 'On break · tap to resume' : 'Take a break', style: context.tt.titleSmall)),
          Switch(value: onBreak, onChanged: (_) => onToggleBreak()),
        ]),
      ]),
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({super.key, required this.entry, required this.onDone, required this.onNext, required this.onOpen});
  final QueueEntry entry;
  final VoidCallback onDone, onNext, onOpen;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rXl,
        gradient: AppColors.gradientPrimary,
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .28), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5EEAC0), shape: BoxShape.circle)).animate(onPlay: (a) => a.repeat(reverse: true)).fade(begin: .3, end: 1, duration: 700.ms),
          const SizedBox(width: 8),
          Text('NOW CONSULTING', style: context.tt.labelSmall!.copyWith(color: Colors.white.withValues(alpha: .9), fontWeight: FontWeight.w800, letterSpacing: 1)),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onOpen,
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Container(width: 56, height: 56, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: AppRadius.rMd), child: Text('#${entry.token}', style: context.tt.titleLarge!.copyWith(color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(entry.patient.name, style: context.tt.titleMedium!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${entry.patient.age} yrs · ${entry.reason}', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .85)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _CardBtn(label: 'Done', icon: Icons.check_rounded, onTap: onDone, filled: false)),
          const SizedBox(width: 10),
          Expanded(child: _CardBtn(label: 'Call next', icon: Icons.campaign_rounded, onTap: onNext, filled: true)),
        ]),
        const SizedBox(height: 0),
        SizedBox(height: 0, child: Text('', style: TextStyle(color: p.bg))),
      ]),
    );
  }
}

class _CardBtn extends StatelessWidget {
  const _CardBtn({required this.label, required this.icon, required this.onTap, required this.filled});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(color: filled ? Colors.white : Colors.white.withValues(alpha: .16), borderRadius: AppRadius.rMd),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: filled ? AppColors.primary : Colors.white),
          const SizedBox(width: 6),
          Text(label, style: context.tt.labelMedium!.copyWith(color: filled ? AppColors.primary : Colors.white, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _NoCurrent extends StatelessWidget {
  const _NoCurrent({super.key, required this.onBreak});
  final bool onBreak;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: onBreak ? p.warningSoft : p.primarySoft, shape: BoxShape.circle), child: Icon(onBreak ? Icons.free_breakfast_rounded : Icons.event_seat_rounded, color: onBreak ? p.warning : p.primary)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(onBreak ? 'You are on a break' : 'No active consultation', style: context.tt.titleMedium), Text(onBreak ? 'Resume to start calling patients.' : 'Tap "Call next patient" to begin.', style: context.tt.bodySmall)])),
      ]),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({super.key, required this.entry, required this.first, required this.onCall, required this.onSkip});
  final QueueEntry entry;
  final bool first;
  final VoidCallback onCall, onSkip;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final mins = DateTime.now().difference(entry.arrival).inMinutes;
    final video = entry.type == ConsultType.video;
    return Dismissible(
      key: ValueKey('d-${entry.id}'),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onCall();
        } else {
          onSkip();
        }
        return false; // state change removes the row
      },
      background: _swipeBg(context, true),
      secondaryBackground: _swipeBg(context, false),
      child: AppCard(
        onTap: () => context.push(Routes.drPatient(entry.patient.id)),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            TokenBadge(token: entry.token, highlight: first),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(entry.patient.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (entry.isMe) ...[const SizedBox(width: 6), StatusChip(label: 'App booking', color: p.accent, bg: p.accentSoft, dense: true)],
                ]),
                Text('${entry.patient.age} yrs · ${entry.reason}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.schedule_rounded, size: 13, color: p.textTertiary),
                  const SizedBox(width: 3),
                  Text('Waiting $mins min', style: context.tt.bodySmall!.copyWith(color: p.textTertiary)),
                  const SizedBox(width: 8),
                  Icon(video ? Icons.videocam_rounded : Icons.local_hospital_rounded, size: 13, color: p.textTertiary),
                  const SizedBox(width: 3),
                  Text(video ? 'Video' : 'In-clinic', style: context.tt.bodySmall!.copyWith(color: p.textTertiary)),
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: AppButton(label: 'Skip', onPressed: onSkip, variant: AppButtonVariant.secondary, size: AppButtonSize.small, icon: Icons.skip_next_rounded)),
            const SizedBox(width: 10),
            Expanded(child: AppButton(label: 'Call', onPressed: onCall, size: AppButtonSize.small, icon: Icons.campaign_rounded)),
          ]),
        ]),
      ),
    );
  }

  Widget _swipeBg(BuildContext context, bool call) {
    final p = context.pal;
    return Container(
      alignment: call ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: call ? p.successSoft : p.warningSoft, borderRadius: AppRadius.rLg),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(call ? Icons.campaign_rounded : Icons.skip_next_rounded, color: call ? p.success : p.warning),
        const SizedBox(width: 8),
        Text(call ? 'Call' : 'Skip', style: context.tt.labelLarge!.copyWith(color: call ? p.success : p.warning)),
      ]),
    );
  }
}

class _CollapseHeader extends StatelessWidget {
  const _CollapseHeader({required this.title, required this.count, required this.open, required this.onTap});
  final String title;
  final int count;
  final bool open;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Text(title, style: context.tt.titleMedium),
          const SizedBox(width: 8),
          StatusChip(label: '$count', color: p.textSecondary, bg: p.surfaceAlt, dense: true),
          const Spacer(),
          AnimatedRotation(turns: open ? .5 : 0, duration: const Duration(milliseconds: 200), child: Icon(Icons.keyboard_arrow_down_rounded, color: p.textSecondary)),
        ]),
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.entry, required this.trailing, required this.color, required this.bg, this.onRecall});
  final QueueEntry entry;
  final String trailing;
  final Color color, bg;
  final VoidCallback? onRecall;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        shadow: false,
        onTap: () => context.push(Routes.drPatient(entry.patient.id)),
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          TokenBadge(token: entry.token, size: 38, muted: true),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.patient.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis), Text(entry.reason, style: context.tt.bodySmall!.copyWith(color: p.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis)])),
          if (onRecall != null) TextButton(onPressed: onRecall, child: const Text('Recall')) else StatusChip(label: trailing, color: color, bg: bg, dense: true),
        ]),
      ),
    );
  }
}
