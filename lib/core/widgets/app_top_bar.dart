import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import 'app_button.dart';

/// Standard top bar for pushed screens: round back button + title + optional actions.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.actions, this.showBack = true, this.bottom, this.onBack});
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: showBack ? 8 : AppSpacing.screenH,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: AppIconButton(
                  icon: Icons.arrow_back_rounded,
                  size: 42,
                  onTap: onBack ?? () => context.canPop() ? context.pop() : context.go('/home'),
                ),
              ),
            )
          : null,
      leadingWidth: showBack ? 58 : 0,
      title: Text(title, style: context.tt.titleLarge),
      actions: [...?actions, const SizedBox(width: 16)],
      bottom: bottom,
    );
  }
}
