import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/appointment_providers.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Keep local changes (new bookings / cancellations) – just simulate a network round trip.
    await fakeLatency(500, 800);
    if (mounted) ref.invalidate(appointmentByIdProvider);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final async = ref.watch(appointmentsProvider);
    int count(AppointmentStatus s) => ref.watch(appointmentsByStatusProvider(s)).length;
    final loaded = async.hasValue;
    String label(String t, AppointmentStatus s) => loaded ? '$t (${count(s)})' : t;

    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 16, AppSpacing.screenH, 12),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My visits', style: context.tt.headlineMedium),
                Text('Manage your appointments', style: context.tt.bodyMedium),
              ]),
            ),
            AppIconButton(icon: Icons.add_rounded, color: p.onPrimary, bg: p.primary, onTap: () => context.push(Routes.search()), tooltip: 'Book new'),
          ]),
        ),
        TabBar(
          controller: _tabs,
          labelStyle: context.tt.labelMedium!.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: context.tt.labelMedium,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: label('Upcoming', AppointmentStatus.upcoming)),
            Tab(text: label('Completed', AppointmentStatus.completed)),
            Tab(text: label('Cancelled', AppointmentStatus.cancelled)),
          ],
        ),
        Expanded(
          child: async.when(
            loading: () => const ShimmerList(itemHeight: 168, padding: EdgeInsets.fromLTRB(AppSpacing.screenH, 16, AppSpacing.screenH, 120)),
            error: (_, __) => ErrorState(onRetry: () => ref.invalidate(appointmentsProvider)),
            data: (_) => TabBarView(
              controller: _tabs,
              children: [
                _VisitList(status: AppointmentStatus.upcoming, onRefresh: _refresh),
                _VisitList(status: AppointmentStatus.completed, onRefresh: _refresh),
                _VisitList(status: AppointmentStatus.cancelled, onRefresh: _refresh),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _VisitList extends ConsumerWidget {
  const _VisitList({required this.status, required this.onRefresh});
  final AppointmentStatus status;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(appointmentsByStatusProvider(status));
    final (icon, title, msg) = switch (status) {
      AppointmentStatus.upcoming => (Icons.event_available_rounded, 'No upcoming visits', 'Book a doctor and your appointments will show up here.'),
      AppointmentStatus.completed => (Icons.history_rounded, 'No completed visits yet', 'Once you finish a consultation it will appear here with prescriptions.'),
      AppointmentStatus.cancelled => (Icons.event_busy_rounded, 'Nothing cancelled', 'Great – you have no cancelled appointments.'),
    };
    return RefreshIndicator(
      color: context.pal.primary,
      onRefresh: onRefresh,
      child: list.isEmpty
          ? LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: c.maxHeight,
                  child: EmptyState(
                    icon: icon,
                    title: title,
                    message: msg,
                    actionLabel: status == AppointmentStatus.cancelled ? null : 'Book now',
                    onAction: () => context.push(Routes.search()),
                  ),
                ),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 16, AppSpacing.screenH, 120),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => AppointmentCard(appointment: list[i])
                  .animate(delay: (60 * i).ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: .06, curve: Curves.easeOutCubic),
            ),
    );
  }
}
