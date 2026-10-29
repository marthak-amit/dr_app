import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/queue_prefs_provider.dart';
import '../widgets/queue_hero.dart';
import '../widgets/queue_parts.dart';

class LiveQueueScreen extends ConsumerStatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  ConsumerState<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends ConsumerState<LiveQueueScreen> {
  Timer? _timer;
  bool _loading = true;
  int? _lastAhead;

  @override
  void initState() {
    super.initState();
    fakeLatency(400, 700).then((_) {
      if (mounted) setState(() => _loading = false);
    });
    // Demo liveness: the queue advances on its own until it's the patient's turn.
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => _tick());
  }

  void _tick() {
    final s = ref.read(queueProvider);
    final me = s.me;
    if (me != null && me.status == QueueStatus.waiting && s.doctorStatus != DoctorStatus.onBreak) {
      ref.read(queueProvider.notifier).callNext();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _afterState(QueueState s) {
    final ahead = s.aheadOfMe;
    final me = s.me;
    if (_lastAhead != null && ahead != _lastAhead && me != null) {
      HapticFeedback.mediumImpact();
      if (me.status == QueueStatus.inConsult) {
        WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? showAppSnack(context, "It's your turn! Please proceed to the consultation room.", icon: Icons.campaign_rounded) : null);
      } else if (ref.read(queueNotifyProvider) && ahead == 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? showAppSnack(context, 'Only 2 patients ahead of you — get ready!', icon: Icons.notifications_active_rounded) : null);
      }
    }
    _lastAhead = ahead;
  }

  Future<void> _refresh() async {
    await fakeLatency(400, 600);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(queueProvider);
    ref.listen(queueProvider, (_, next) => _afterState(next));
    final doctor = doctorById(kDoctorModeDoctorId);
    final me = s.me;
    final p = context.pal;

    return Scaffold(
      appBar: AppTopBar(title: 'Live queue', actions: [AppIconButton(icon: Icons.chat_bubble_outline_rounded, size: 42, onTap: () => context.push(Routes.chat), tooltip: 'Chat with clinic')]),
      body: _loading
          ? const Padding(padding: EdgeInsets.all(20), child: _QueueShimmer())
          : me == null
              ? EmptyState(
                  icon: Icons.confirmation_number_outlined,
                  title: 'You\'re not in a queue',
                  message: 'Book an in-clinic visit and your live token will show up here on the day of your appointment.',
                  actionLabel: 'Find a doctor',
                  onAction: () => context.push(Routes.search()),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: p.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    children: [
                      QueueHero(state: s).animate().fadeIn(duration: 350.ms).slideY(begin: .08),
                      const SizedBox(height: 16),
                      if (me.status == QueueStatus.inConsult) _Banner(icon: Icons.celebration_rounded, color: p.success, bg: p.successSoft, title: "It's your turn!", message: 'Please proceed to the consultation room.').animate().fadeIn().scale(begin: const Offset(.95, .95)),
                      if (me.status == QueueStatus.done) _DoneBanner(onRx: () => context.push(Routes.prescriptions)),
                      if (me.status == QueueStatus.skipped) _Banner(icon: Icons.info_outline_rounded, color: p.warning, bg: p.warningSoft, title: 'Your token was skipped', message: 'Please check with the front desk to be re-added to the queue.'),
                      if (me.status != QueueStatus.waiting) const SizedBox(height: 16),
                      QueueDoctorCard(doctor: doctor, status: s.doctorStatus).animate().fadeIn(delay: 80.ms).slideY(begin: .08),
                      const SizedBox(height: 16),
                      QueueTimeline(state: s).animate().fadeIn(delay: 160.ms).slideY(begin: .08),
                      const SizedBox(height: 16),
                      _NotifyTile(),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: AppButton(label: 'Chat with clinic', icon: Icons.chat_bubble_rounded, variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: () => context.push(Routes.chat))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Directions',
                            icon: Icons.near_me_rounded,
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.medium,
                            onPressed: () => showAppSnack(context, 'Opening Maps to ${clinicById(doctor.clinicId).name}…', icon: Icons.near_me_rounded),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: me.status == QueueStatus.waiting
                              ? () {
                                  ref.read(queueProvider.notifier).callNext();
                                  showAppSnack(context, 'Demo: next patient called', icon: Icons.skip_next_rounded);
                                }
                              : null,
                          icon: const Icon(Icons.fast_forward_rounded, size: 18),
                          label: const Text('Simulate next patient'),
                        ),
                      ),
                      if (me.status == QueueStatus.waiting) ...[
                        const SizedBox(height: 4),
                        AppButton(
                          label: 'Leave queue',
                          variant: AppButtonVariant.danger,
                          size: AppButtonSize.medium,
                          icon: Icons.logout_rounded,
                          onPressed: () async {
                            final ok = await showConfirmSheet(context,
                                title: 'Leave the queue?', message: 'You will lose token #${me.token}. You can rejoin from the front desk.', confirmLabel: 'Leave queue', destructive: true, icon: Icons.logout_rounded);
                            if (ok && context.mounted) {
                              showAppSnack(context, 'You left the queue. See you again soon!', icon: Icons.waving_hand_rounded);
                              context.pop();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _NotifyTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final on = ref.watch(queueNotifyProvider);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: p.accentSoft, borderRadius: AppRadius.rSm), child: Icon(Icons.notifications_active_rounded, color: p.accent, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Notify me', style: context.tt.titleSmall), Text('When 2 patients are ahead of me', style: context.tt.bodySmall)])),
        Switch(
          value: on,
          onChanged: (v) {
            ref.read(queueNotifyProvider.notifier).state = v;
            showAppSnack(context, v ? 'We\'ll alert you when 2 patients are ahead' : 'Queue alerts turned off', icon: v ? Icons.notifications_active_rounded : Icons.notifications_off_rounded);
          },
        ),
      ]),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.bg, required this.title, required this.message});
  final IconData icon;
  final Color color, bg;
  final String title, message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rLg, border: Border.all(color: color.withValues(alpha: .4))),
      child: Row(children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleMedium!.copyWith(color: color)), Text(message, style: context.tt.bodySmall!.copyWith(color: context.pal.textSecondary))])),
      ]),
    );
  }
}

class _DoneBanner extends StatelessWidget {
  const _DoneBanner({required this.onRx});
  final VoidCallback onRx;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _Banner(icon: Icons.check_circle_rounded, color: AppColors.success, bg: Color(0x1A1F9D6B), title: 'Visit completed', message: 'We hope you feel better soon. Your prescription is ready.'),
      const SizedBox(height: 12),
      AppButton(label: 'View prescription', icon: Icons.description_rounded, onPressed: onRx, variant: AppButtonVariant.primary, size: AppButtonSize.medium),
    ]);
  }
}

class _QueueShimmer extends StatelessWidget {
  const _QueueShimmer();
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      ShimmerBox(height: 230, radius: 28),
      SizedBox(height: 16),
      ShimmerBox(height: 96, radius: 20),
      SizedBox(height: 16),
      ShimmerBox(height: 200, radius: 20),
    ]);
  }
}
