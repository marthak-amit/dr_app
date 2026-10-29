import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/records_providers.dart';

class _Source {
  const _Source(this.id, this.label, this.sub, this.icon, this.files);
  final String id, label, sub;
  final IconData icon;
  final List<(String, int)> files; // name, sizeKb
}

const _sources = <_Source>[
  _Source('camera', 'Camera', 'Scan a report or prescription', Icons.photo_camera_rounded, [('Scan_0412.jpg', 1860), ('Scan_0413.jpg', 2010)]),
  _Source('gallery', 'Gallery', 'Pick photos from your phone', Icons.photo_library_rounded, [('IMG_2041.jpg', 2480), ('IMG_2038.jpg', 1730), ('IMG_1997.jpg', 3015)]),
  _Source('files', 'Files (PDF)', 'Browse documents & downloads', Icons.folder_open_rounded, [
    ('blood_test_oct.pdf', 412),
    ('lipid_profile.pdf', 356),
    ('discharge_summary.pdf', 890),
    ('xray_chest_scan.jpg', 2650),
  ]),
];

/// Opens the mock file-picker → details → upload flow.
Future<void> showUploadSheet(BuildContext context, WidgetRef ref, {RecordKind? initialKind}) {
  return showAppBottomSheet<void>(
    context,
    title: 'Upload record',
    builder: (ctx) => _UploadFlow(
      initialKind: initialKind,
      rootContext: context,
      onUploaded: (r) => ref.read(recordsProvider.notifier).add(r),
    ),
  );
}

class _UploadFlow extends StatefulWidget {
  const _UploadFlow({required this.rootContext, required this.onUploaded, this.initialKind});
  final BuildContext rootContext;
  final ValueChanged<HealthRecord> onUploaded;
  final RecordKind? initialKind;

  @override
  State<_UploadFlow> createState() => _UploadFlowState();
}

class _UploadFlowState extends State<_UploadFlow> {
  int stage = 0; // 0 source · 1 pick · 2 details
  _Source? source;
  (String, int)? file;
  late RecordKind kind = widget.initialKind ?? RecordKind.lab;
  final nameCtrl = TextEditingController();
  double progress = 0;
  bool uploading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  String _pretty(String f) {
    final base = f.split('.').first.replaceAll('_', ' ');
    return base.isEmpty ? base : base[0].toUpperCase() + base.substring(1);
  }

  Future<void> _upload() async {
    if (nameCtrl.text.trim().isEmpty) {
      showAppSnack(context, 'Give your file a name first', error: true);
      return;
    }
    setState(() {
      uploading = true;
      progress = 0;
    });
    for (var i = 1; i <= 12; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() => progress = i / 12);
    }
    final isPdf = file!.$1.toLowerCase().endsWith('.pdf');
    widget.onUploaded(HealthRecord(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      title: nameCtrl.text.trim(),
      kind: kind,
      date: DateTime.now(),
      sizeKb: file!.$2,
      source: 'Uploaded by you',
      isPdf: isPdf,
    ));
    final root = widget.rootContext;
    Navigator.of(context).pop();
    if (root.mounted) showAppSnack(root, '"${nameCtrl.text.trim()}" saved to ${metaOf(kind).title}', icon: Icons.cloud_done_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(stage), child: switch (stage) { 0 => _source(context), 1 => _pick(context), _ => _details(context) }),
    );
  }

  Widget _source(BuildContext context) {
    final p = context.pal;
    return Column(children: [
      for (final s in _sources)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TapScale(
            onTap: () => setState(() {
              source = s;
              stage = 1;
            }),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rLg, border: Border.all(color: p.border)),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rMd), child: Icon(s.icon, color: p.primary)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.label, style: context.tt.titleSmall), Text(s.sub, style: context.tt.bodySmall)])),
                Icon(Icons.chevron_right_rounded, color: p.textTertiary),
              ]),
            ),
          ),
        ),
      Text('Supported: PDF, JPG, PNG · up to 25 MB', style: context.tt.bodySmall),
    ]);
  }

  Widget _pick(BuildContext context) {
    final p = context.pal;
    final s = source!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => stage = 0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.arrow_back_rounded, size: 18, color: p.primary),
          const SizedBox(width: 6),
          Text('${s.label} · choose a file', style: context.tt.labelMedium!.copyWith(color: p.primary)),
        ]),
      ),
      const SizedBox(height: 14),
      for (final f in s.files)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TapScale(
            onTap: () {
              nameCtrl.text = _pretty(f.$1);
              final n = f.$1.toLowerCase();
              kind = widget.initialKind ?? (n.contains('xray') || n.contains('scan') ? RecordKind.xray : RecordKind.lab);
              setState(() {
                file = f;
                stage = 2;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rSm),
                  child: Icon(f.$1.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf_rounded : Icons.image_rounded, color: f.$1.toLowerCase().endsWith('.pdf') ? p.danger : p.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.$1, style: context.tt.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(fmtFileSize(f.$2), style: context.tt.bodySmall),
                ])),
                Icon(Icons.radio_button_unchecked_rounded, color: p.textTertiary, size: 20),
              ]),
            ),
          ),
        ),
    ]);
  }

  Widget _details(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: p.successSoft, borderRadius: AppRadius.rMd),
        child: Row(children: [
          Icon(Icons.check_circle_rounded, color: p.success),
          const SizedBox(width: 10),
          Expanded(child: Text('${file!.$1} · ${fmtFileSize(file!.$2)}', style: context.tt.labelMedium!.copyWith(color: p.success), maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (!uploading)
            GestureDetector(onTap: () => setState(() => stage = 1), child: Text('Change', style: context.tt.labelMedium!.copyWith(color: p.primary))),
        ]),
      ),
      const SizedBox(height: 16),
      AppTextField(controller: nameCtrl, label: 'File name', hint: 'e.g. Blood test – Oct', prefixIcon: Icons.edit_note_rounded, textInputAction: TextInputAction.done),
      const SizedBox(height: 16),
      Text('Save to folder', style: context.tt.labelMedium!.copyWith(color: p.textSecondary)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final m in kindMetas) ChoicePill(label: m.title, selected: kind == m.kind, onTap: uploading ? null : () => setState(() => kind = m.kind)),
      ]),
      const SizedBox(height: 20),
      if (uploading) ...[
        ClipRRect(borderRadius: AppRadius.rPill, child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: p.surfaceAlt, color: p.primary)),
        const SizedBox(height: 8),
        Text('Uploading… ${(progress * 100).round()}%', style: context.tt.bodySmall),
        const SizedBox(height: 12),
      ],
      AppButton(label: uploading ? 'Uploading' : 'Upload to vault', icon: Icons.cloud_upload_rounded, loading: uploading, onPressed: uploading ? null : _upload),
    ]);
  }
}
