import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/records_providers.dart';
import '../widgets/record_actions.dart';
import '../widgets/record_tile.dart';
import '../widgets/upload_sheet.dart';

class RecordFolderScreen extends ConsumerStatefulWidget {
  const RecordFolderScreen({super.key, required this.kind});
  final String kind;

  @override
  ConsumerState<RecordFolderScreen> createState() => _RecordFolderScreenState();
}

class _RecordFolderScreenState extends ConsumerState<RecordFolderScreen> {
  bool _grid = false;
  bool _newestFirst = true;
  String _q = '';

  Future<void> _refresh() async {
    ref.invalidate(recordsProvider);
    await ref.read(recordsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final meta = metaOfKey(widget.kind);
    final async = ref.watch(recordsProvider);
    return Scaffold(
      appBar: AppTopBar(
        title: meta.title,
        actions: [
          AppIconButton(icon: _newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 40, tooltip: 'Sort by date', onTap: () {
            setState(() => _newestFirst = !_newestFirst);
            showAppSnack(context, _newestFirst ? 'Newest first' : 'Oldest first', icon: Icons.sort_rounded);
          }),
          const SizedBox(width: 8),
          AppIconButton(icon: _grid ? Icons.view_list_rounded : Icons.grid_view_rounded, size: 40, tooltip: 'Toggle view', onTap: () => setState(() => _grid = !_grid)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: p.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => showUploadSheet(context, ref, initialKind: meta.kind),
        icon: const Icon(Icons.cloud_upload_rounded),
        label: const Text('Upload'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 4, AppSpacing.screenH, 12),
          child: AppTextField(hint: 'Search in ${meta.title}', prefixIcon: Icons.search_rounded, onChanged: (v) => setState(() => _q = v)),
        ),
        Expanded(
          child: AsyncBody<List<HealthRecord>>(
            value: async,
            onRetry: _refresh,
            builder: (all) {
              final list = all.where((r) => r.kind == meta.kind && matchesQuery(r, _q)).toList()
                ..sort((a, b) => _newestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
              return RefreshIndicator(
                color: p.primary,
                onRefresh: _refresh,
                child: list.isEmpty ? _empty(context, meta, all.any((r) => r.kind == meta.kind)) : (_grid ? _gridView(list) : _listView(list)),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _empty(BuildContext context, KindMeta meta, bool hasAny) {
    return LayoutBuilder(
      builder: (_, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: c.maxHeight,
          child: hasAny
              ? EmptyState(icon: Icons.search_off_rounded, title: 'No matching files', message: 'Nothing in ${meta.title} matches "$_q".')
              : EmptyState(icon: Icons.folder_open_rounded, title: 'No files here yet', message: 'Upload your first file to ${meta.title}.', actionLabel: 'Upload', onAction: () => showUploadSheet(context, ref, initialKind: meta.kind)),
        ),
      ),
    );
  }

  Widget _listView(List<HealthRecord> list) {
    final p = context.pal;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 100),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = list[i];
        return Dismissible(
          key: ValueKey(r.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(color: p.dangerSoft, borderRadius: AppRadius.rLg),
            child: Icon(Icons.delete_outline_rounded, color: p.danger),
          ),
          onDismissed: (_) => deleteWithUndo(context, ref, r),
          child: RecordTile(record: r, index: i, onTap: () => context.push(Routes.recordFile(r.id)), onAction: (a) => handleRecordAction(context, ref, r, a)),
        );
      },
    );
  }

  Widget _gridView(List<HealthRecord> list) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 176),
      itemCount: list.length,
      itemBuilder: (_, i) => RecordGridCard(record: list[i], index: i, onTap: () => context.push(Routes.recordFile(list[i].id))),
    );
  }
}
