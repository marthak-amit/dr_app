import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/records_providers.dart';

enum RecordAction { share, download, delete }

/// List row for a [HealthRecord].
class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, required this.onTap, required this.onAction, this.index = 0});
  final HealthRecord record;
  final VoidCallback onTap;
  final ValueChanged<RecordAction> onAction;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final m = metaOf(record.kind);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      radius: AppRadius.lg,
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: m.tint(p), borderRadius: AppRadius.rMd),
          child: Center(child: SvgIcon(m.icon, size: 24, color: m.color(p))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record.title, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(record.source, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Icon(record.isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded, size: 13, color: p.textTertiary),
              const SizedBox(width: 4),
              Flexible(
                child: Text('${fmtDateShort(record.date)} · ${fmtFileSize(record.sizeKb)}',
                    style: context.tt.bodySmall!.copyWith(color: p.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ]),
        ),
        PopupMenuButton<RecordAction>(
          icon: Icon(Icons.more_vert_rounded, color: p.textSecondary),
          color: p.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          onSelected: onAction,
          itemBuilder: (_) => [
            PopupMenuItem(value: RecordAction.share, child: _menuRow(context, Icons.ios_share_rounded, 'Share with doctor', p.textPrimary)),
            PopupMenuItem(value: RecordAction.download, child: _menuRow(context, Icons.download_rounded, 'Download', p.textPrimary)),
            PopupMenuItem(value: RecordAction.delete, child: _menuRow(context, Icons.delete_outline_rounded, 'Delete', p.danger)),
          ],
        ),
      ]),
    ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: .08, curve: Curves.easeOutCubic);
  }

  Widget _menuRow(BuildContext c, IconData i, String t, Color col) =>
      Row(children: [Icon(i, size: 20, color: col), const SizedBox(width: 10), Text(t, style: c.tt.labelMedium!.copyWith(color: col))]);
}

/// Grid card used by the folder screen's grid mode.
class RecordGridCard extends StatelessWidget {
  const RecordGridCard({super.key, required this.record, required this.onTap, this.index = 0});
  final HealthRecord record;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final m = metaOf(record.kind);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(color: m.tint(p), borderRadius: AppRadius.rMd),
          child: Center(child: SvgIcon(m.icon, size: 32, color: m.color(p))),
        ),
        const SizedBox(height: 8),
        Text(record.title, style: context.tt.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        const Spacer(),
        Text('${fmtDateShort(record.date)} · ${fmtFileSize(record.sizeKb)}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(.95, .95), curve: Curves.easeOutCubic);
  }
}
