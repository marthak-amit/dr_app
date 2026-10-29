import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/vitals_logic.dart';
import '../widgets/add_vital_sheet.dart';
import '../widgets/vitals_chart.dart';

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> {
  VitalType _type = VitalType.bp;
  int _days = 30;

  Future<void> _refresh() async {
    ref.invalidate(vitalsProvider);
    await ref.read(vitalsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final async = ref.watch(vitalsProvider);
    return Scaffold(
      appBar: AppTopBar(title: 'My vitals', actions: [AppIconButton(icon: Icons.ios_share_rounded, size: 40, tooltip: 'Share report', onTap: () => showAppSnack(context, 'Vitals report (PDF) ready to share with your doctor', icon: Icons.picture_as_pdf_rounded))]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: p.accent,
        foregroundColor: Colors.white,
        onPressed: () => showAddVitalSheet(context, ref, initial: _type),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add entry'),
      ),
      body: RefreshIndicator(
        color: p.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 4, AppSpacing.screenH, 110),
          children: [
            _Segmented(type: _type, onChanged: (t) => setState(() => _type = t)),
            const SizedBox(height: 16),
            ...async.when(
              loading: () => const [ShimmerBox(height: 130, radius: 24), SizedBox(height: 16), ShimmerBox(height: 260, radius: 24), SizedBox(height: 16), ShimmerBox(height: 80, radius: 20)],
              error: (e, _) => [SizedBox(height: 420, child: ErrorState(onRetry: _refresh))],
              data: _content,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(List<VitalEntry> all) {
    final p = context.pal;
    final meta = vitalMeta(_type);
    final ofType = all.where((e) => e.type == _type).toList()..sort((a, b) => a.date.compareTo(b.date));
    final cutoff = DateTime.now().subtract(Duration(days: _days));
    final list = ofType.where((e) => e.date.isAfter(cutoff)).toList();

    final rangeChips = Row(children: [
      for (final d in const [7, 30, 90]) ...[
        ChoicePill(label: '${d}D', selected: _days == d, onTap: () => setState(() => _days = d)),
        const SizedBox(width: 8),
      ],
    ]);

    if (list.isEmpty) {
      return [
        rangeChips,
        SizedBox(
          height: 380,
          child: EmptyState(icon: meta.icon, title: 'No ${meta.title.toLowerCase()} readings', message: ofType.isEmpty ? 'Log your first reading to start tracking trends.' : 'Nothing recorded in the last $_days days. Try a longer range or add a new reading.', actionLabel: 'Add reading', onAction: () => showAddVitalSheet(context, ref, initial: _type)),
        ),
      ];
    }

    final latest = list.last;
    final st = statusOf(latest);
    final prim = list.map((e) => e.value).toList();
    final mn = prim.reduce((a, b) => a < b ? a : b), mx = prim.reduce((a, b) => a > b ? a : b), avg = prim.reduce((a, b) => a + b) / prim.length;
    final bmi = latest.value / (kHeightM * kHeightM);

    return [
      // hero
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: AppRadius.rXl, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .28), blurRadius: 22, offset: const Offset(0, 10))]),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Latest · ${timeAgo(latest.date)}', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .85))),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisSize: MainAxisSize.min, children: [
                  Text(fmtValue(latest), style: context.tt.displayMedium!.copyWith(color: Colors.white)),
                  const SizedBox(width: 6),
                  Text(meta.unit, style: context.tt.titleSmall!.copyWith(color: Colors.white.withValues(alpha: .85))),
                ]),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                StatusChip(label: st.label, color: st.color(p), bg: Colors.white, icon: st.level == 0 ? Icons.check_circle_rounded : Icons.warning_amber_rounded),
                if (_type == VitalType.weight) StatusChip(label: 'BMI ${bmi.toStringAsFixed(1)}', color: AppColors.primaryDark, bg: Colors.white.withValues(alpha: .9)),
              ]),
            ]),
          ),
          Container(width: 58, height: 58, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle), child: Icon(meta.icon, color: Colors.white, size: 28)),
        ]),
      ).animate(key: ValueKey(_type)).fadeIn(duration: 300.ms).slideY(begin: .08, curve: Curves.easeOutCubic),
      const SizedBox(height: 18),
      // chart
      AppCard(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
        radius: AppRadius.xl,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(children: [
              Expanded(child: Text('${meta.title} trend', style: context.tt.titleMedium)),
              if (_type == VitalType.bp) ...[_dot(p.primary, 'SYS'), const SizedBox(width: 10), _dot(p.accent, 'DIA')],
            ]),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 220, child: list.length < 2 ? Center(child: Text('Add one more reading to see a trend line.', style: context.tt.bodySmall)) : VitalsChart(type: _type, entries: list)),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.only(left: 12), child: rangeChips),
        ]),
      ),
      const SizedBox(height: 18),
      // stats
      Row(children: [
        Expanded(child: _Stat(label: 'Min', value: fmtNum(mn), unit: _type == VitalType.bp ? 'SYS' : meta.unit, color: p.success)),
        const SizedBox(width: 10),
        Expanded(child: _Stat(label: 'Average', value: fmtNum(double.parse(avg.toStringAsFixed(1))), unit: _type == VitalType.bp ? 'SYS' : meta.unit, color: p.primary)),
        const SizedBox(width: 10),
        Expanded(child: _Stat(label: 'Max', value: fmtNum(mx), unit: _type == VitalType.bp ? 'SYS' : meta.unit, color: p.accent)),
      ]),
      const SizedBox(height: 22),
      Text('History', style: context.tt.titleLarge),
      const SizedBox(height: 12),
      for (var i = 0; i < list.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _HistoryRow(entry: list[list.length - 1 - i], unit: meta.unit, icon: meta.icon).animate(delay: (i * 35).ms).fadeIn(duration: 260.ms).slideX(begin: .05),
        ),
    ];
  }

  Widget _dot(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(t, style: context.tt.labelSmall),
      ]);
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.type, required this.onChanged});
  final VitalType type;
  final ValueChanged<VitalType> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const labels = {VitalType.bp: 'BP', VitalType.sugar: 'Sugar', VitalType.weight: 'Weight'};
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
      child: Row(children: [
        for (final m in vitalMetas)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(m.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(color: type == m.type ? p.surface : Colors.transparent, borderRadius: AppRadius.rSm, boxShadow: type == m.type ? [BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(0, 2))] : null),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(m.icon, size: 16, color: type == m.type ? p.primary : p.textTertiary),
                  const SizedBox(width: 6),
                  Text(labels[m.type]!, style: context.tt.labelMedium!.copyWith(color: type == m.type ? p.primary : p.textSecondary)),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.unit, required this.color});
  final String label, value, unit;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(label, style: context.tt.bodySmall)]),
        const SizedBox(height: 6),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: context.tt.titleLarge)),
        Text(unit, style: context.tt.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.unit, required this.icon});
  final VitalEntry entry;
  final String unit;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final st = statusOf(entry);
    return AppCard(
      padding: const EdgeInsets.all(12),
      radius: AppRadius.md,
      onTap: () => showAppSnack(context, '${fmtValue(entry)} $unit · ${st.label} on ${fmtDate(entry.date)}', icon: icon),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: st.soft(p), borderRadius: AppRadius.rSm), child: Icon(icon, size: 20, color: st.color(p))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${fmtValue(entry)} $unit', style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${fmtDate(entry.date)} · ${fmtTime(entry.date)}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        StatusChip(label: st.label, color: st.color(p), bg: st.soft(p), dense: true),
      ]),
    );
  }
}
