import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

/// Visualises a "1-0-1" dosage as morning / afternoon / night dots.
class DosageView extends StatelessWidget {
  const DosageView({super.key, required this.dosage});
  final String dosage;

  @override
  Widget build(BuildContext context) {
    final parts = dosage.split('-');
    final p = context.pal;
    if (parts.length != 3) {
      return StatusChip(label: dosage, color: p.primary, bg: p.primarySoft, icon: Icons.schedule_rounded);
    }
    const icons = [Icons.wb_twilight_rounded, Icons.wb_sunny_rounded, Icons.nightlight_round];
    const labels = ['Morning', 'Noon', 'Night'];
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < 3; i++) ...[
        Tooltip(
          message: '${labels[i]}: ${parts[i]}',
          child: Container(
            width: 34,
            height: 34,
            margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
            decoration: BoxDecoration(
              color: parts[i] != '0' ? p.primary : p.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: parts[i] != '0' ? p.primary : p.border),
            ),
            child: Stack(alignment: Alignment.center, children: [
              Icon(icons[i], size: 17, color: parts[i] != '0' ? p.onPrimary : p.textTertiary),
              if (parts[i] != '0' && parts[i] != '1')
                Positioned(right: 2, top: 0, child: Text(parts[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: p.onPrimary))),
            ]),
          ),
        ),
      ],
    ]);
  }
}
