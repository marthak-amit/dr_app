import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Styled floating feedback toast. Every "dead" tap should call this.
void showAppSnack(BuildContext context, String message, {IconData? icon, bool error = false, SnackBarAction? action}) {
  final p = context.pal;
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Row(children: [
      Icon(icon ?? (error ? Icons.error_outline_rounded : Icons.check_circle_rounded), size: 20, color: error ? p.danger : const Color(0xFF5EEAC0)),
      const SizedBox(width: 12),
      Expanded(child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis)),
    ]),
    action: action,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: const Duration(milliseconds: 2400),
  ));
}
