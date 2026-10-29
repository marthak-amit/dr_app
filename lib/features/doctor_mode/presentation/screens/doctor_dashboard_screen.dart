import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../providers/doctor_providers.dart';
import '../widgets/doctor_widgets.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  bool _showRevenue = false;

  Future<void> _refresh() async {
    ref.invalidate(doctorDashboardLoadProvider);
    await ref.read(doctorDashboardLoadProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final load = ref.watch(doctorDashboardLoadProvider);
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: p.primary,
          onRefresh: _refresh,
          child: load.when(
            loading: () => const _DashShimmer(),
            error: (_, __) => ListView(children: [SizedBox(height: 400, child: ErrorState(onRetry: _refresh))]),
            data: (_) => _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final p = context.pal;
    final doc = doctorById(kDoctorModeDoctorId);
    final q = ref.watch(queueProvider);
    final next = q.current ?? (q.waiting.isEmpty ? null : q.waiting.first);
    final done = q.doneCount;
    final revenue = done * doc.fee + (q.current != null ? 0 : 0);
    final avgWait = q.waiting.isEmpty ? 0 : (q.waiting.length * q.avgMinutes / 2).round() + 4;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            DoctorAvatar(doctor: doc, size: 52, radius: 18, hero: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greeting(), style: context.tt.bodySmall),
                Text(doc.name, style: context.tt.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                const DoctorModeChip(),
              ]),
            ),
            AppIconButton(icon: Icons.notifications_none_rounded, badge: true, onTap: () => showAppSnack(context, 'You have 3 new notifications', icon: Icons.notifications_active_rounded)),
          ]),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 20),
        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            Row(children: [
              Expanded(child: StatTile(icon: Icons.groups_rounded, label: "Today's patients", value: q.entries.length.toDouble(), color: p.primary, bg: p.primarySoft)),
              const SizedBox(width: 12),
              Expanded(child: StatTile(icon: Icons.currency_rupee_rounded, label: 'Revenue today', value: revenue.toDouble(), prefix: '₹', color: p.success, bg: p.successSoft)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatTile(icon: Icons.timer_outlined, label: 'Avg. wait', value: avgWait.toDouble(), suffix: ' min', color: p.warning, bg: p.warningSoft)),
              const SizedBox(width: 12),
              Expanded(child: StatTile(icon: Icons.star_rounded, label: 'Rating', value: doc.rating, isInt: false, fractionDigits: 1, color: p.accent, bg: p.accentSoft)),
            ]),
          ]),
        ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: .05, end: 0),
        const SizedBox(height: 24),
        SectionHeader(title: q.current != null ? 'Now consulting' : 'Next patient', subtitle: '${q.waiting.length} waiting · $done done'),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: animIn(_NextPatientCard(next: next, consulting: q.current != null), 2)),
        const SizedBox(height: 24),
        SectionHeader(title: 'This week', subtitle: _showRevenue ? 'Revenue (₹ thousands)' : 'Patients per day'),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: animIn(_WeekChart(showRevenue: _showRevenue, todayPatients: q.entries.length, todayRevenue: revenue / 1000, onToggle: (v) => setState(() => _showRevenue = v)), 3)),
        const SizedBox(height: 24),
        SectionHeader(title: 'Quick actions'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: _QuickAction(icon: Icons.edit_note_rounded, label: 'Write\nprescription', color: p.primary, bg: p.primarySoft, onTap: () => context.push(Routes.drRx((next ?? q.entries.first).patient.id)))),
            const SizedBox(width: 12),
            Expanded(child: _QuickAction(icon: Icons.groups_rounded, label: 'Manage\nqueue', color: p.accent, bg: p.accentSoft, onTap: () => context.go(Routes.drQueue))),
            const SizedBox(width: 12),
            Expanded(child: _QuickAction(icon: Icons.event_available_rounded, label: 'My\nschedule', color: p.success, bg: p.successSoft, onTap: () => context.go(Routes.drSchedule))),
          ]),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        SectionHeader(title: "Today's timeline", action: 'See queue', onAction: () => context.go(Routes.drQueue)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(children: [
              for (var i = 0; i < q.entries.length; i++) _TimelineRow(entry: q.entries[i], index: i, last: i == q.entries.length - 1),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text('${AppConfig.appName} · Doctor view', style: context.tt.bodySmall)),
      ],
    );
  }
}

class _DashShimmer extends StatelessWidget {
  const _DashShimmer();
  @override
  Widget build(BuildContext context) {
    return ListView(physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(20), children: [
      Row(children: const [ShimmerBox(width: 52, height: 52, radius: 18), SizedBox(width: 12), ShimmerBox(width: 160, height: 40)]),
      const SizedBox(height: 24),
      Row(children: const [Expanded(child: ShimmerBox(height: 110, radius: 20)), SizedBox(width: 12), Expanded(child: ShimmerBox(height: 110, radius: 20))]),
      const SizedBox(height: 12),
      Row(children: const [Expanded(child: ShimmerBox(height: 110, radius: 20)), SizedBox(width: 12), Expanded(child: ShimmerBox(height: 110, radius: 20))]),
      const SizedBox(height: 24),
      const ShimmerBox(height: 170, radius: 24),
      const SizedBox(height: 24),
      const ShimmerBox(height: 200, radius: 24),
    ]);
  }
}

class _NextPatientCard extends ConsumerWidget {
  const _NextPatientCard({required this.next, required this.consulting});
  final QueueEntry? next;
  final bool consulting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    if (next == null) {
      return AppCard(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: p.successSoft, shape: BoxShape.circle), child: Icon(Icons.check_rounded, color: p.success)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Queue cleared 🎉', style: context.tt.titleMedium), Text('No patients waiting right now.', style: context.tt.bodySmall)])),
        ]),
      );
    }
    final pt = next!.patient;
    final fg = Colors.white;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: AppRadius.rXl, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 22, offset: const Offset(0, 10))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle),
            child: Text(pt.initials, style: TextStyle(fontFamily: AppTypography.fontFamily, color: fg, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pt.name, style: context.tt.titleMedium!.copyWith(color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${pt.age} yrs · ${pt.gender == Gender.male ? 'Male' : 'Female'} · ${pt.bloodGroup}', style: context.tt.bodySmall!.copyWith(color: fg.withValues(alpha: .85))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: AppRadius.rSm),
            child: Text('#${next!.token}', style: context.tt.titleMedium!.copyWith(color: fg)),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.assignment_outlined, size: 16, color: fg.withValues(alpha: .85)),
          const SizedBox(width: 6),
          Expanded(child: Text(next!.reason, style: context.tt.bodyMedium!.copyWith(color: fg), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        if (pt.allergies.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.rPill),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(child: Text('Allergy: ${pt.allergies.join(', ')}', style: context.tt.labelSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: _HeroBtn(
              label: consulting ? 'Finish & next' : 'Start consult',
              icon: Icons.play_arrow_rounded,
              filled: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                final q = ref.read(queueProvider);
                ref.read(queueProvider.notifier).callNext();
                final nxt = ref.read(queueProvider).current;
                showAppSnack(context, nxt != null ? 'Token #${nxt.token} · ${nxt.patient.name} is in consult' : (q.waiting.isEmpty ? 'Queue complete' : 'Called next patient'), icon: Icons.campaign_rounded);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _HeroBtn(label: 'View history', icon: Icons.history_rounded, filled: false, onTap: () => context.push(Routes.drPatient(pt.id)))),
        ]),
      ]),
    );
  }
}

class _HeroBtn extends StatelessWidget {
  const _HeroBtn({required this.label, required this.icon, required this.filled, required this.onTap});
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: filled ? Colors.white : Colors.white.withValues(alpha: .16), borderRadius: AppRadius.rMd),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: filled ? AppColors.primary : Colors.white),
          const SizedBox(width: 4),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium!.copyWith(color: filled ? AppColors.primary : Colors.white, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.bg, required this.onTap});
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rMd), child: Icon(icon, color: color)),
        const SizedBox(height: 10),
        Text(label, textAlign: TextAlign.center, style: context.tt.labelMedium!.copyWith(height: 1.25), maxLines: 2),
      ]),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.index, required this.last});
  final QueueEntry entry;
  final int index;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final (label, c, bg) = switch (entry.status) {
      QueueStatus.done => ('Done', p.success, p.successSoft),
      QueueStatus.inConsult => ('In consult', p.primary, p.primarySoft),
      QueueStatus.skipped => ('Skipped', p.danger, p.dangerSoft),
      QueueStatus.waiting => ('Waiting', p.warning, p.warningSoft),
    };
    final time = fmtTime(DateTime.now().subtract(Duration(minutes: 70 - index * 9)));
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 20,
          child: Column(children: [
            const SizedBox(height: 6),
            Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: c, border: Border.all(color: bg, width: 3))),
            if (!last) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: p.border)),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.patient.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('$time · ${entry.reason}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(width: 8),
              StatusChip(label: label, color: c, bg: bg, dense: true),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.showRevenue, required this.todayPatients, required this.todayRevenue, required this.onToggle});
  final bool showRevenue;
  final int todayPatients;
  final double todayRevenue;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final todayIdx = DateTime.now().weekday - 1;
    final patients = [...kWeekPatients]..[todayIdx] = todayPatients.toDouble();
    final revenue = [...kWeekRevenue]..[todayIdx] = todayRevenue;
    final data = showRevenue ? revenue : patients;
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.25).ceilToDouble();

    final titles = FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (v, _) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(days[v.toInt()], style: context.tt.labelSmall!.copyWith(color: v.toInt() == todayIdx ? p.primary : p.textTertiary, fontWeight: v.toInt() == todayIdx ? FontWeight.w800 : FontWeight.w600)),
          ),
        ),
      ),
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(showRevenue ? '₹${data.reduce((a, b) => a + b).toStringAsFixed(1)}K this week' : '${data.reduce((a, b) => a + b).round()} patients this week', style: context.tt.titleSmall)),
          _Toggle(showRevenue: showRevenue, onChanged: onToggle),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 170,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: showRevenue
                ? LineChart(
                    key: const ValueKey('line'),
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      minX: 0,
                      maxX: 6,
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4, getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 4])),
                      borderData: FlBorderData(show: false),
                      titlesData: titles,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => p.textPrimary,
                          getTooltipItems: (s) => [for (final t in s) LineTooltipItem('₹${t.y.toStringAsFixed(1)}K', TextStyle(color: p.surface, fontWeight: FontWeight.w700, fontFamily: AppTypography.fontFamily))],
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [for (var i = 0; i <= todayIdx.clamp(0, 6); i++) FlSpot(i.toDouble(), data[i])],
                          isCurved: true,
                          color: p.accent,
                          barWidth: 3.5,
                          dotData: FlDotData(show: true, getDotPainter: (a, b, c, d) => FlDotCirclePainter(radius: 4, color: p.surface, strokeWidth: 3, strokeColor: p.accent)),
                          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [p.accent.withValues(alpha: .25), p.accent.withValues(alpha: 0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                        ),
                      ],
                    ),
                  )
                : BarChart(
                    key: const ValueKey('bar'),
                    BarChartData(
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4, getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 4])),
                      borderData: FlBorderData(show: false),
                      titlesData: titles,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => p.textPrimary,
                          getTooltipItem: (g, gi, r, ri) => BarTooltipItem('${r.toY.round()} pts', TextStyle(color: p.surface, fontWeight: FontWeight.w700, fontFamily: AppTypography.fontFamily)),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < 7; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: data[i],
                              width: 18,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              color: i == todayIdx ? p.primary : p.primary.withValues(alpha: .28),
                            ),
                          ]),
                      ],
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.showRevenue, required this.onChanged});
  final bool showRevenue;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget seg(String l, bool sel, VoidCallback t) => GestureDetector(
          onTap: t,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: sel ? p.surface : Colors.transparent, borderRadius: AppRadius.rPill, boxShadow: sel ? [BoxShadow(color: p.shadow, blurRadius: 6)] : null),
            child: Text(l, style: context.tt.labelSmall!.copyWith(color: sel ? p.primary : p.textSecondary, fontWeight: FontWeight.w700)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rPill),
      child: Row(mainAxisSize: MainAxisSize.min, children: [seg('Patients', !showRevenue, () => onChanged(false)), seg('Revenue', showRevenue, () => onChanged(true))]),
    );
  }
}
