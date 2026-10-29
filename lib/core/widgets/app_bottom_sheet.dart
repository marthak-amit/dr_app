import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows a styled modal bottom sheet. [builder] gets the sheet context (use it to `Navigator.pop(ctx, value)`).
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  bool scrollable = true,
  bool fullHeight = false,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 4, 20, 24),
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .45),
    builder: (ctx) => AppBottomSheet(title: title, scrollable: scrollable, fullHeight: fullHeight, padding: padding, child: builder(ctx)),
  );
}

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child, this.title, this.scrollable = true, this.fullHeight = false, this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 24)});
  final Widget child;
  final String? title;
  final bool scrollable, fullHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final kb = MediaQuery.of(context).viewInsets.bottom;
    final body = Padding(padding: padding, child: child);
    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * (fullHeight ? .94 : .88)),
        decoration: BoxDecoration(color: p.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(width: 44, height: 5, decoration: BoxDecoration(color: p.border, borderRadius: AppRadius.rPill)),
          const SizedBox(height: 14),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(children: [
                Expanded(child: Text(title!, style: context.tt.titleLarge)),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.close_rounded, color: p.textSecondary)),
              ]),
            ),
          Flexible(fit: fullHeight ? FlexFit.tight : FlexFit.loose, child: scrollable ? SingleChildScrollView(child: body) : body),
        ]),
      ),
    );
  }
}

/// Confirm dialog in the app style. Returns true when confirmed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final r = await showAppBottomSheet<bool>(
    context,
    builder: (ctx) {
      final p = ctx.pal;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: destructive ? p.dangerSoft : p.primarySoft, shape: BoxShape.circle),
          child: Icon(icon, color: destructive ? p.danger : p.primary, size: 30),
        ),
        const SizedBox(height: 16),
        Text(title, style: ctx.tt.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, style: ctx.tt.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _SheetBtn(label: cancelLabel, onTap: () => Navigator.pop(ctx, false), filled: false)),
          const SizedBox(width: 12),
          Expanded(child: _SheetBtn(label: confirmLabel, onTap: () => Navigator.pop(ctx, true), filled: true, destructive: destructive)),
        ]),
      ]);
    },
  );
  return r ?? false;
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({required this.label, required this.onTap, required this.filled, this.destructive = false});
  final String label;
  final VoidCallback onTap;
  final bool filled, destructive;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = destructive ? p.danger : p.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: filled ? c : Colors.transparent, borderRadius: AppRadius.rMd, border: filled ? null : Border.all(color: p.border, width: 1.4)),
        child: Text(label, style: context.tt.labelLarge!.copyWith(color: filled ? Colors.white : p.textPrimary)),
      ),
    );
  }
}
