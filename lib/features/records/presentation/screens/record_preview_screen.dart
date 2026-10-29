import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/records_providers.dart';
import '../widgets/record_actions.dart';
import '../widgets/record_paper.dart';

class RecordPreviewScreen extends ConsumerStatefulWidget {
  const RecordPreviewScreen({super.key, required this.recordId});
  final String recordId;

  @override
  ConsumerState<RecordPreviewScreen> createState() => _RecordPreviewScreenState();
}

class _RecordPreviewScreenState extends ConsumerState<RecordPreviewScreen> {
  double? _dl; // download progress

  Future<void> _download(HealthRecord r) async {
    if (_dl != null) return;
    setState(() => _dl = 0);
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _dl = i / 10);
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _dl = null);
    showAppSnack(context, '${r.title} saved to Downloads', icon: Icons.download_done_rounded);
  }

  void _info(HealthRecord r) {
    showAppBottomSheet<void>(context, title: 'File details', builder: (ctx) {
      final p = ctx.pal;
      Widget row(String k, String v) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 96, child: Text(k, style: ctx.tt.bodyMedium)),
              Expanded(child: Text(v, style: ctx.tt.titleSmall, textAlign: TextAlign.right)),
            ]),
          );
      final ext = r.isPdf ? 'pdf' : 'jpg';
      return Column(children: [
        row('Name', '${r.title.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}.$ext'),
        Divider(color: p.border),
        row('Type', metaOf(r.kind).title),
        Divider(color: p.border),
        row('Size', fmtFileSize(r.sizeKb)),
        Divider(color: p.border),
        row('Date', fmtDateLong(r.date)),
        Divider(color: p.border),
        row('Source', r.source),
      ]);
    });
  }

  Future<void> _delete(HealthRecord r) async {
    final ok = await showConfirmSheet(context, title: 'Delete this file?', message: '"${r.title}" will be removed from your vault.', confirmLabel: 'Delete', destructive: true, icon: Icons.delete_outline_rounded);
    if (ok && mounted) {
      ref.read(recordsProvider.notifier).remove(r.id);
      context.pop();
      showAppSnack(context, 'File deleted', icon: Icons.delete_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final async = ref.watch(recordsProvider);
    return async.when(
      loading: () => Scaffold(appBar: const AppTopBar(title: 'Preview'), body: const Padding(padding: EdgeInsets.all(20), child: ShimmerBox(height: 460, radius: 20))),
      error: (e, _) => Scaffold(appBar: const AppTopBar(title: 'Preview'), body: ErrorState(onRetry: () => ref.invalidate(recordsProvider))),
      data: (list) {
        final r = list.where((e) => e.id == widget.recordId).firstOrNull;
        if (r == null) {
          return Scaffold(appBar: const AppTopBar(title: 'Preview'), body: const EmptyState(icon: Icons.insert_drive_file_outlined, title: 'File not found', message: 'This file may have been deleted.'));
        }
        final isXray = !r.isPdf || r.kind == RecordKind.xray;
        return Scaffold(
          backgroundColor: isXray ? const Color(0xFF05090B) : p.surfaceAlt,
          body: SafeArea(
            child: Column(children: [
              _header(context, r, isXray),
              if (_dl != null) LinearProgressIndicator(value: _dl, minHeight: 3, color: p.accent, backgroundColor: Colors.transparent),
              Expanded(child: isXray ? _xray(r) : _paper(r)),
              _bottom(context, r, isXray),
            ]),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, HealthRecord r, bool dark) {
    final p = context.pal;
    final fg = dark ? Colors.white : p.textPrimary;
    final bg = dark ? Colors.white.withValues(alpha: .12) : p.surface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(children: [
        AppIconButton(icon: Icons.arrow_back_rounded, size: 42, color: fg, bg: bg, onTap: () => context.pop()),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.title, style: context.tt.titleSmall!.copyWith(color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${fmtDateShort(r.date)} · ${fmtFileSize(r.sizeKb)}', style: context.tt.bodySmall!.copyWith(color: fg.withValues(alpha: .7))),
        ])),
        AppIconButton(icon: Icons.download_rounded, size: 40, color: fg, bg: bg, tooltip: 'Download', onTap: () => _download(r)),
        const SizedBox(width: 8),
        AppIconButton(icon: Icons.ios_share_rounded, size: 40, color: fg, bg: bg, tooltip: 'Share', onTap: () => showAppSnack(context, 'Share link copied — valid for 24 hours', icon: Icons.link_rounded)),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          color: p.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          onSelected: (v) => v == 'info' ? _info(r) : _delete(r),
          child: Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: dark ? Colors.transparent : p.border)), child: Icon(Icons.more_vert_rounded, size: 20, color: fg)),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'info', child: Row(children: [Icon(Icons.info_outline_rounded, size: 20, color: p.textPrimary), const SizedBox(width: 10), Text('File details', style: context.tt.labelMedium)])),
            PopupMenuItem(value: 'del', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 20, color: p.danger), const SizedBox(width: 10), Text('Delete', style: context.tt.labelMedium!.copyWith(color: p.danger))])),
          ],
        ),
      ]),
    );
  }

  Widget _paper(HealthRecord r) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: RecordPaper(record: r),
      );

  Widget _xray(HealthRecord r) {
    final knee = r.title.toLowerCase().contains('knee');
    return Stack(children: [
      Positioned.fill(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: AspectRatio(
              aspectRatio: .8,
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CustomPaint(painter: XRayPainter(knee: knee))),
            ),
          ),
        ),
      ),
      Positioned(
        left: 20,
        top: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .5), borderRadius: AppRadius.rPill),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.pinch_rounded, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text('Pinch to zoom · drag to pan', style: context.tt.bodySmall!.copyWith(color: Colors.white70)),
          ]),
        ),
      ),
      Positioned(left: 24, bottom: 14, child: Text('R  ${knee ? 'AP VIEW' : 'PA VIEW'}\n${fmtDateShort(r.date)}', style: context.tt.labelSmall!.copyWith(color: Colors.white54))),
    ]);
  }

  Widget _bottom(BuildContext context, HealthRecord r, bool dark) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(color: dark ? const Color(0xFF0B1316) : p.surface, border: Border(top: BorderSide(color: dark ? Colors.white12 : p.border))),
      child: AppButton(label: 'Share with doctor', icon: Icons.send_rounded, onPressed: () => shareWithDoctor(context, r)),
    );
  }
}
