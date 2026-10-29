import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/vitals_logic.dart';

/// Premium line chart for one vital type. [entries] must be sorted ascending.
class VitalsChart extends StatelessWidget {
  const VitalsChart({super.key, required this.type, required this.entries});
  final VitalType type;
  final List<VitalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final n = entries.length;
    final sys = [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), entries[i].value)];
    final dia = type == VitalType.bp ? [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), entries[i].value2 ?? 0)] : <FlSpot>[];

    final all = [...sys, ...dia].map((s) => s.y);
    var lo = all.reduce((a, b) => a < b ? a : b);
    var hi = all.reduce((a, b) => a > b ? a : b);
    if (type == VitalType.sugar) {
      lo = lo < 70 ? lo : 70;
      hi = hi > 140 ? hi : 140;
    }
    final pad = type == VitalType.weight ? 1.0 : (hi - lo) * .15 + 4;
    final minY = (lo - pad).floorToDouble();
    final maxY = (hi + pad).ceilToDouble();
    final interval = type == VitalType.weight ? ((maxY - minY) / 4).clamp(.5, 5).toDouble() : ((maxY - minY) / 4).ceilToDouble().clamp(5, 50).toDouble();
    final labelEvery = (n / 4).ceil().clamp(1, 99);

    final primary = type == VitalType.bp ? p.primary : (type == VitalType.sugar ? p.accent : p.success);

    LineChartBarData line(List<FlSpot> spots, Color c, {bool area = true}) => LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          curveSmoothness: .28,
          color: c,
          barWidth: 3.2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: n <= 16,
            getDotPainter: (s, pct, bar, i) => FlDotCirclePainter(radius: 4.2, color: p.surface, strokeWidth: 2.6, strokeColor: c),
          ),
          belowBarData: BarAreaData(
            show: area,
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.withValues(alpha: .26), c.withValues(alpha: 0)]),
          ),
        );

    final bars = type == VitalType.bp ? [line(sys, primary), line(dia, p.accent, area: false)] : [line(sys, primary)];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (n - 1).clamp(1, 9999).toDouble(),
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: interval, getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1, dashArray: [4, 4])),
        rangeAnnotations: type == VitalType.sugar
            ? RangeAnnotations(horizontalRangeAnnotations: [HorizontalRangeAnnotation(y1: 70, y2: 100, color: p.success.withValues(alpha: .1))])
            : (type == VitalType.bp
                ? RangeAnnotations(horizontalRangeAnnotations: [HorizontalRangeAnnotation(y1: 80, y2: 120, color: p.success.withValues(alpha: .08))])
                : null),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: interval,
              getTitlesWidget: (v, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(fmtNum(v), style: context.tt.labelSmall!.copyWith(color: p.textTertiary))),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.round();
                if ((v - i).abs() > .01 || i < 0 || i >= n || i % labelEvery != 0) return const SizedBox.shrink();
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('d MMM').format(entries[i].date), style: context.tt.labelSmall!.copyWith(color: p.textTertiary)));
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => p.isDark ? p.surfaceAlt : const Color(0xFF10303A),
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) {
              if (spots.isEmpty) return [];
              final i = spots.first.spotIndex.clamp(0, n - 1);
              final e = entries[i];
              final meta = vitalMeta(type);
              return [
                for (var k = 0; k < spots.length; k++)
                  LineTooltipItem(
                    k == 0 ? '${type == VitalType.bp ? '${fmtNum(e.value)}/${fmtNum(e.value2 ?? 0)}' : fmtNum(e.value)} ${meta.unit}\n' : '',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, fontFamily: AppTypography.fontFamily),
                    children: k == 0 ? [TextSpan(text: DateFormat('EEE, d MMM').format(e.date), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 11))] : null,
                  ),
              ];
            },
          ),
        ),
        lineBarsData: bars,
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }
}
