import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/providers.dart';

({IconData icon, Color color, Color bg}) notifStyle(NotificationType t, AppPalette p) => switch (t) {
      NotificationType.appointment => (icon: Icons.event_available_rounded, color: p.primary, bg: p.primarySoft),
      NotificationType.reminder => (icon: Icons.medication_rounded, color: p.warning, bg: p.warningSoft),
      NotificationType.report => (icon: Icons.description_rounded, color: p.success, bg: p.successSoft),
      NotificationType.offer => (icon: Icons.local_offer_rounded, color: p.accent, bg: p.accentSoft),
      NotificationType.queue => (icon: Icons.groups_rounded, color: p.danger, bg: p.dangerSoft),
    };

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, required this.onTap});
  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final s = notifStyle(item.type, p);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      color: item.read ? p.surface : Color.alphaBlend(p.primary.withValues(alpha: .05), p.surface),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: s.bg, shape: BoxShape.circle), child: Icon(s.icon, color: s.color, size: 22)),
        Gap.h(12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(item.title, style: context.tt.titleSmall!.copyWith(fontWeight: item.read ? FontWeight.w600 : FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (!item.read) Container(width: 9, height: 9, margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle)),
            ]),
            Gap.v(3),
            Text(item.body, style: context.tt.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
            Gap.v(6),
            Text(timeAgo(item.time), style: context.tt.labelSmall!.copyWith(color: p.textTertiary)),
          ]),
        ),
      ]),
    );
  }
}
