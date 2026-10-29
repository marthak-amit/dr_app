import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.subtitle, this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screenH)});
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: padding,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: context.tt.titleLarge),
            if (subtitle != null) Text(subtitle!, style: context.tt.bodySmall),
          ]),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Text(action!, style: context.tt.labelMedium!.copyWith(color: p.primary)),
            ),
          ),
      ]),
    );
  }
}
