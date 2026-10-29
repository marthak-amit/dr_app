import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

/// Post-call summary: duration, star rating, actions.
class CallSummarySheet extends StatefulWidget {
  const CallSummarySheet({super.key, required this.duration, required this.doctorName, required this.onViewRx, required this.onDone});
  final String duration, doctorName;
  final VoidCallback onViewRx, onDone;

  @override
  State<CallSummarySheet> createState() => _CallSummarySheetState();
}

class _CallSummarySheetState extends State<CallSummarySheet> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(color: p.successSoft, shape: BoxShape.circle), child: Icon(Icons.call_end_rounded, color: p.success, size: 30)),
      const SizedBox(height: 14),
      Text('Call ended · ${widget.duration}', style: context.tt.titleLarge),
      const SizedBox(height: 4),
      Text('Your consultation with ${widget.doctorName} is complete.', style: context.tt.bodyMedium, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      Text('How was your consultation?', style: context.tt.titleSmall),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 1; i <= 5; i++)
          TapScale(
            onTap: () {
              setState(() => _stars = i);
              showAppSnack(context, 'Thanks for rating $i star${i > 1 ? 's' : ''}!', icon: Icons.star_rounded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, key: ValueKey(i <= _stars), size: 40, color: i <= _stars ? AppColors.star : p.textTertiary),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 24),
      AppButton(label: 'View prescription', icon: Icons.description_rounded, onPressed: widget.onViewRx),
      const SizedBox(height: 10),
      AppButton(label: 'Done', variant: AppButtonVariant.text, onPressed: widget.onDone),
    ]);
  }
}
