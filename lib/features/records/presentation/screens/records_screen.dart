import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/records_providers.dart';
import '../widgets/record_actions.dart';
import '../widgets/record_tile.dart';
import '../widgets/upload_sheet.dart';

/// Health records vault (patient shell TAB).
class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(recordsProvider);
    await ref.read(recordsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final async = ref.watch(recordsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: p.primary,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              ...async.when(
                loading: () => [const SliverToBoxAdapter(child: _VaultShimmer())],
                error: (e, _) => [SliverFillRemaining(hasScrollBody: false, child: ErrorState(onRetry: _refresh))],
                data: (list) => _content(context, list),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final p = context.pal;
    final list = ref.watch(recordsProvider).valueOrNull ?? const <HealthRecord>[];
    final usedKb = list.fold<int>(0, (s, r) => s + r.sizeKb) + 5400;
    const totalKb = 1024 * 1024;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 16, AppSpacing.screenH, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Health vault', style: context.tt.headlineMedium),
            Text('All your medical files, safe & private', style: context.tt.bodySmall),
          ])),
          AppIconButton(icon: Icons.add_rounded, bg: p.primary, color: p.onPrimary, tooltip: 'Upload', onTap: () => showUploadSheet(context, ref)),
        ]),
        const SizedBox(height: 16),
        AppCard(
          gradient: AppColors.gradientPrimary,
          shadow: true,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle), child: const Icon(Icons.shield_rounded, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${(usedKb / 1024).toStringAsFixed(1)} MB of 1 GB used', style: context.tt.titleSmall!.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: AppRadius.rPill,
                  child: LinearProgressIndicator(value: (usedKb / totalKb).clamp(.03, 1), minHeight: 7, backgroundColor: Colors.white.withValues(alpha: .25), color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text('${list.length} files · end-to-end encrypted', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .85))),
              ]),
            ),
          ]),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: .1, curve: Curves.easeOutCubic),
        const SizedBox(height: 16),
        AppTextField(
          controller: _search,
          hint: 'Search reports, labs, doctors…',
          prefixIcon: Icons.search_rounded,
          onChanged: (v) => setState(() => _q = v),
          suffix: _q.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: p.textTertiary),
                  onPressed: () {
                    _search.clear();
                    setState(() => _q = '');
                  },
                ),
        ),
      ]),
    );
  }

  List<Widget> _content(BuildContext context, List<HealthRecord> all) {
    final searching = _q.trim().isNotEmpty;
    final sorted = [...all]..sort((a, b) => b.date.compareTo(a.date));
    final shown = searching ? sorted.where((r) => matchesQuery(r, _q)).toList() : sorted.take(5).toList();

    if (all.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 380,
            child: EmptyState(icon: Icons.folder_open_rounded, title: 'Your vault is empty', message: 'Upload lab reports, X-rays and prescriptions to keep them handy for every visit.', actionLabel: 'Upload first file', onAction: () => showUploadSheet(context, ref)),
          ),
        ),
      ];
    }

    return [
      if (!searching) ...[
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(child: SectionHeader(title: 'Folders', subtitle: '${kindMetas.length} folders')),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 142),
            delegate: SliverChildListDelegate([
              for (var i = 0; i < kindMetas.length; i++)
                _FolderCard(meta: kindMetas[i], records: all.where((r) => r.kind == kindMetas[i].kind).toList(), index: i, onTap: () => context.push(Routes.recordFolder(kindMetas[i].key))),
              _UploadCard(onTap: () => showUploadSheet(context, ref)),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
      SliverToBoxAdapter(
        child: SectionHeader(
          title: searching ? 'Results' : 'Recent files',
          subtitle: searching ? '${shown.length} found' : null,
          action: searching ? null : 'Share all',
          onAction: () => showAppSnack(context, 'Choose a file first, then tap Share with doctor', icon: Icons.info_outline_rounded),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      if (shown.isEmpty)
        SliverToBoxAdapter(child: SizedBox(height: 260, child: EmptyState(icon: Icons.search_off_rounded, title: 'No matching files', message: 'Nothing found for "$_q". Try a different keyword.')))
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          sliver: SliverList.separated(
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = shown[i];
              return RecordTile(record: r, index: i, onTap: () => context.push(Routes.recordFile(r.id)), onAction: (a) => handleRecordAction(context, ref, r, a));
            },
          ),
        ),
    ];
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.meta, required this.records, required this.onTap, required this.index});
  final KindMeta meta;
  final List<HealthRecord> records;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: AppRadius.xl,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: meta.tint(p), borderRadius: AppRadius.rMd),
          child: Center(child: SvgIcon(meta.icon, size: 24, color: meta.color(p))),
        ),
        const Spacer(),
        Text(meta.title, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text('${records.length} files · ${lastUpdatedLabel(records)}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ).animate(delay: (index * 70).ms).fadeIn(duration: 350.ms).slideY(begin: .1, curve: Curves.easeOutCubic);
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.accentSoft,
          borderRadius: AppRadius.rXl,
          border: Border.all(color: p.accent.withValues(alpha: .45), width: 1.4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(gradient: AppColors.gradientAccent, borderRadius: AppRadius.rMd), child: const Icon(Icons.cloud_upload_rounded, color: Colors.white)),
          const Spacer(),
          Text('Upload file', style: context.tt.titleSmall!.copyWith(color: p.accent)),
          const SizedBox(height: 2),
          Text('Camera · Gallery · PDF', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ).animate(delay: 280.ms).fadeIn(duration: 350.ms).slideY(begin: .1, curve: Curves.easeOutCubic);
  }
}

class _VaultShimmer extends StatelessWidget {
  const _VaultShimmer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      child: Column(children: [
        Row(children: const [Expanded(child: ShimmerBox(height: 130, radius: 24)), SizedBox(width: 12), Expanded(child: ShimmerBox(height: 130, radius: 24))]),
        const SizedBox(height: 12),
        Row(children: const [Expanded(child: ShimmerBox(height: 130, radius: 24)), SizedBox(width: 12), Expanded(child: ShimmerBox(height: 130, radius: 24))]),
        const SizedBox(height: 20),
        const ShimmerList(itemCount: 3, itemHeight: 84, padding: EdgeInsets.zero, shrink: true),
      ]),
    );
  }
}
