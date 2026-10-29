import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';

/// Designed empty state: layered illustration disc + title + message + optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction, this.color});
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = color ?? p.primary;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(alignment: Alignment.center, children: [
              Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: .08))),
              Container(width: 108, height: 108, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: .14))),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface, boxShadow: [BoxShadow(color: c.withValues(alpha: .25), blurRadius: 20, offset: const Offset(0, 8))]),
                child: Icon(icon, size: 32, color: c),
              ),
              Positioned(right: 16, top: 20, child: Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent.withValues(alpha: .9)))),
              Positioned(left: 14, bottom: 28, child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: p.warning))),
            ]),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(.85, .85), curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(title, style: context.tt.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, style: context.tt.bodyMedium, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 24),
            AppButton(label: actionLabel!, onPressed: onAction, expand: false, size: AppButtonSize.medium),
          ],
        ]),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.message = 'We couldn\'t load this right now. Please check your connection and try again.', this.onRetry, this.title = 'Something went wrong'});
  final String title, message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(icon: Icons.cloud_off_rounded, title: title, message: message, actionLabel: 'Try again', onAction: onRetry, color: context.pal.accent);
  }
}
