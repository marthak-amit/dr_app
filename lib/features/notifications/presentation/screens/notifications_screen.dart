import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../widgets/notification_tile.dart';

enum _Filter { all, unread, appointments, reports }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _Filter _filter = _Filter.all;
  final Set<String> _dismissed = {};

  static const _labels = {_Filter.all: 'All', _Filter.unread: 'Unread', _Filter.appointments: 'Appointments', _Filter.reports: 'Reports'};

  bool _match(AppNotification n) => switch (_filter) {
        _Filter.all => true,
        _Filter.unread => !n.read,
        _Filter.appointments => n.type == NotificationType.appointment || n.type == NotificationType.queue,
        _Filter.reports => n.type == NotificationType.report,
      };

  void _open(AppNotification n) {
    ref.read(notificationsProvider.notifier).markRead(n.id);
    switch (n.type) {
      case NotificationType.queue:
        context.push(Routes.queue);
      case NotificationType.appointment:
        context.go(Routes.appointments);
      case NotificationType.report:
        context.go(Routes.records);
      case NotificationType.reminder:
        context.push(Routes.reminders);
      case NotificationType.offer:
        showAppSnack(context, 'Offer code MEDIQ20 copied to clipboard', icon: Icons.local_offer_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Notifications', actions: [
        if (unread > 0)
          TapScale(
            onTap: () {
              ref.read(notificationsProvider.notifier).markAllRead();
              showAppSnack(context, 'All notifications marked as read', icon: Icons.done_all_rounded);
            },
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), child: Text('Mark all read', style: context.tt.labelMedium!.copyWith(color: p.primary))),
          ),
      ]),
      body: Column(children: [
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH, vertical: 4),
            itemCount: _Filter.values.length,
            separatorBuilder: (_, __) => Gap.h(8),
            itemBuilder: (_, i) {
              final f = _Filter.values[i];
              return ChoicePill(label: f == _Filter.unread && unread > 0 ? 'Unread ($unread)' : _labels[f]!, selected: _filter == f, onTap: () => setState(() => _filter = f));
            },
          ),
        ),
        Expanded(
          child: AsyncBody<List<AppNotification>>(
            value: async,
            onRetry: () => ref.invalidate(notificationsProvider),
            loading: const ShimmerList(itemHeight: 104, itemCount: 6),
            builder: (all) {
              final list = all.where((n) => !_dismissed.contains(n.id) && _match(n)).toList();
              return RefreshIndicator(
                color: p.primary,
                onRefresh: () async {
                  _dismissed.clear();
                  ref.invalidate(notificationsProvider);
                  await ref.read(notificationsProvider.future);
                },
                child: list.isEmpty
                    ? ListView(children: [
                        SizedBox(
                          height: 460,
                          child: EmptyState(
                            icon: Icons.notifications_off_rounded,
                            title: _filter == _Filter.all ? 'You\'re all caught up' : 'Nothing here',
                            message: _filter == _Filter.all ? 'No new notifications right now. We\'ll let you know when something needs your attention.' : 'No ${_labels[_filter]!.toLowerCase()} notifications to show.',
                            actionLabel: _filter == _Filter.all ? null : 'Show all',
                            onAction: () => setState(() => _filter = _Filter.all),
                          ),
                        ),
                      ])
                    : _buildList(list),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildList(List<AppNotification> list) {
    final now = DateTime.now();
    bool today(AppNotification n) => isSameDay(n.time, now);
    final todays = list.where(today).toList();
    final earlier = list.where((n) => !today(n)).toList();
    final children = <Widget>[];
    var idx = 0;
    void section(String title, List<AppNotification> items) {
      if (items.isEmpty) return;
      children.add(Padding(padding: const EdgeInsets.fromLTRB(4, 12, 0, 10), child: Text(title, style: context.tt.titleSmall)));
      for (final n in items) {
        final i = idx++;
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(color: context.pal.dangerSoft, borderRadius: AppRadius.rLg),
              child: Icon(Icons.delete_rounded, color: context.pal.danger),
            ),
            onDismissed: (_) {
              setState(() => _dismissed.add(n.id));
              showAppSnack(context, 'Notification removed', icon: Icons.delete_outline_rounded, action: SnackBarAction(label: 'UNDO', textColor: Colors.white, onPressed: () => setState(() => _dismissed.remove(n.id))));
            },
            child: NotificationTile(item: n, onTap: () => _open(n)),
          ).animate().fadeIn(delay: (50 * i).ms, duration: 300.ms).slideY(begin: .08, end: 0, delay: (50 * i).ms, duration: 300.ms, curve: Curves.easeOutCubic),
        ));
      }
    }

    section('Today', todays);
    section('Earlier', earlier);
    return ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 40), children: children);
  }
}
