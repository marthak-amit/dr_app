import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.step, required this.labels});
  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                decoration: BoxDecoration(color: i <= step ? p.primary : p.border, borderRadius: AppRadius.rPill),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Step ${step + 1} of ${labels.length}  ·  ', style: context.tt.bodySmall),
          TextSpan(text: labels[step], style: context.tt.labelMedium!.copyWith(color: p.primary)),
        ])),
      ]),
    );
  }
}
