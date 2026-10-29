import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../data/repositories/providers.dart';
import 'record_tile.dart';

/// Doctor picker sheet → snackbar confirmation.
Future<void> shareWithDoctor(BuildContext context, HealthRecord r) async {
  final docs = ['d2', 'd1', 'd7', 'd11'].map(doctorById).toList();
  final picked = await showAppBottomSheet<Doctor>(
    context,
    title: 'Share with doctor',
    builder: (ctx) {
      final p = ctx.pal;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('"${r.title}" will be shared securely for 7 days.', style: ctx.tt.bodyMedium),
        const SizedBox(height: 14),
        for (final d in docs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TapScale(
              onTap: () => Navigator.pop(ctx, d),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: p.border)),
                child: Row(children: [
                  DoctorAvatar(doctor: d, size: 48, hero: false),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.name, style: ctx.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(d.specialty, style: ctx.tt.bodySmall),
                  ])),
                  Icon(Icons.send_rounded, size: 18, color: p.primary),
                ]),
              ),
            ),
          ),
      ]);
    },
  );
  if (picked != null && context.mounted) showAppSnack(context, 'Shared with ${picked.name}', icon: Icons.ios_share_rounded);
}

Future<void> downloadRecord(BuildContext context, HealthRecord r) async {
  showAppSnack(context, 'Downloading ${r.title}…', icon: Icons.downloading_rounded);
  await Future<void>.delayed(const Duration(milliseconds: 1300));
  if (context.mounted) showAppSnack(context, 'Saved to Downloads/${AppConfig.appName}', icon: Icons.download_done_rounded);
}

/// Deletes with an undo snackbar.
void deleteWithUndo(BuildContext context, WidgetRef ref, HealthRecord r) {
  ref.read(recordsProvider.notifier).remove(r.id);
  showAppSnack(
    context,
    '"${r.title}" deleted',
    icon: Icons.delete_outline_rounded,
    action: SnackBarAction(label: 'UNDO', textColor: const Color(0xFF5EEAC0), onPressed: () => ref.read(recordsProvider.notifier).add(r)),
  );
}

void handleRecordAction(BuildContext context, WidgetRef ref, HealthRecord r, RecordAction a) {
  switch (a) {
    case RecordAction.share:
      shareWithDoctor(context, r);
    case RecordAction.download:
      downloadRecord(context, r);
    case RecordAction.delete:
      deleteWithUndo(context, ref, r);
  }
}
