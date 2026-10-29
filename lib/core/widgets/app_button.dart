import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tap_scale.dart';

enum AppButtonVariant { primary, accent, secondary, outline, text, danger }

enum AppButtonSize { large, medium, small }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final disabled = onPressed == null && !loading;
    Color bg, fg;
    Border? border;
    Gradient? grad;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = p.primary;
        fg = p.onPrimary;
        grad = p.isDark ? null : AppColors.gradientPrimary;
      case AppButtonVariant.accent:
        bg = p.accent;
        fg = Colors.white;
        grad = AppColors.gradientAccent;
      case AppButtonVariant.secondary:
        bg = p.primarySoft;
        fg = p.primary;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = p.primary;
        border = Border.all(color: p.primary.withValues(alpha: .5), width: 1.4);
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = p.primary;
      case AppButtonVariant.danger:
        bg = p.dangerSoft;
        fg = p.danger;
    }
    if (disabled) {
      bg = p.surfaceAlt;
      fg = p.textTertiary;
      grad = null;
      border = null;
    }
    final h = switch (size) { AppButtonSize.large => 54.0, AppButtonSize.medium => 46.0, AppButtonSize.small => 38.0 };
    final fs = switch (size) { AppButtonSize.large => 16.0, AppButtonSize.medium => 15.0, AppButtonSize.small => 13.0 };
    final hasShadow = !disabled && (variant == AppButtonVariant.primary || variant == AppButtonVariant.accent);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        else ...[
          if (icon != null) ...[Icon(icon, size: fs + 4, color: fg), const SizedBox(width: 8)],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: fs, fontWeight: FontWeight.w700, color: fg)),
          ),
          if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: fs + 4, color: fg)],
        ],
      ],
    );

    return TapScale(
      onTap: (disabled || loading) ? null : onPressed,
      scale: .97,
      haptic: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: h,
        padding: EdgeInsets.symmetric(horizontal: size == AppButtonSize.small ? 16 : 24),
        decoration: BoxDecoration(
          color: grad == null ? bg : null,
          gradient: grad,
          borderRadius: BorderRadius.circular(size == AppButtonSize.small ? 14 : AppRadius.md),
          border: border,
          boxShadow: hasShadow
              ? [BoxShadow(color: (variant == AppButtonVariant.accent ? p.accent : p.primary).withValues(alpha: .28), blurRadius: 16, offset: const Offset(0, 6))]
              : null,
        ),
        child: Center(widthFactor: expand ? null : 1, child: content),
      ),
    );
  }
}

/// Round icon button used in app bars / overlays.
class AppIconButton extends StatelessWidget {
  const AppIconButton({super.key, required this.icon, required this.onTap, this.size = 44, this.color, this.bg, this.badge = false, this.tooltip});
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color, bg;
  final bool badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final w = TapScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg ?? p.surface, shape: BoxShape.circle, border: Border.all(color: p.border)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: size * .5, color: color ?? p.textPrimary),
            if (badge) Positioned(right: size * .22, top: size * .22, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle, border: Border.all(color: p.surface, width: 1.5)))),
          ],
        ),
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}
