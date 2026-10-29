import 'package:flutter/material.dart';

/// Brand constants (mode independent).
class AppColors {
  AppColors._();
  static const primary = Color(0xFF0E7C86);
  static const primaryDark = Color(0xFF0A5C64);
  static const primaryLight = Color(0xFF3CC4CF);
  static const accent = Color(0xFFFF6B4A); // coral – CTAs / alerts
  static const success = Color(0xFF1F9D6B);
  static const warning = Color(0xFFF5A524);
  static const danger = Color(0xFFE5484D);
  static const star = Color(0xFFFFB400);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF0E7C86), Color(0xFF17A2AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientAccent = LinearGradient(
    colors: [Color(0xFFFF6B4A), Color(0xFFFF8F6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Mode-aware palette exposed via `context.pal`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.shadow,
    required this.isDark,
  });

  final Color bg, surface, surfaceAlt, border;
  final Color textPrimary, textSecondary, textTertiary;
  final Color primary, primarySoft, onPrimary;
  final Color accent, accentSoft;
  final Color success, successSoft, warning, warningSoft, danger, dangerSoft;
  final Color shadow;
  final bool isDark;

  static const light = AppPalette(
    bg: Color(0xFFF4F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF4F6),
    border: Color(0xFFE2EAEE),
    textPrimary: Color(0xFF10303A),
    textSecondary: Color(0xFF5B727C),
    textTertiary: Color(0xFF8DA0A8),
    primary: AppColors.primary,
    primarySoft: Color(0xFFE2F2F3),
    onPrimary: Colors.white,
    accent: AppColors.accent,
    accentSoft: Color(0xFFFFEDE8),
    success: AppColors.success,
    successSoft: Color(0xFFE3F6EE),
    warning: Color(0xFFD98A00),
    warningSoft: Color(0xFFFFF3DB),
    danger: AppColors.danger,
    dangerSoft: Color(0xFFFDE9EA),
    shadow: Color(0x1A0E3A44),
    isDark: false,
  );

  static const dark = AppPalette(
    bg: Color(0xFF0A1317),
    surface: Color(0xFF121E24),
    surfaceAlt: Color(0xFF1A2A32),
    border: Color(0xFF243842),
    textPrimary: Color(0xFFE9F2F4),
    textSecondary: Color(0xFF9DB3BB),
    textTertiary: Color(0xFF6C838C),
    primary: Color(0xFF3CC4CF),
    primarySoft: Color(0xFF123A40),
    onPrimary: Color(0xFF04262A),
    accent: Color(0xFFFF7D5E),
    accentSoft: Color(0xFF3B2019),
    success: Color(0xFF3DD598),
    successSoft: Color(0xFF123626),
    warning: Color(0xFFFFB84D),
    warningSoft: Color(0xFF3A2C10),
    danger: Color(0xFFFF6B70),
    dangerSoft: Color(0xFF3B1A1C),
    shadow: Color(0x66000000),
    isDark: true,
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      t < .5 ? this : (other as AppPalette? ?? this);
}

extension PaletteX on BuildContext {
  AppPalette get pal => Theme.of(this).extension<AppPalette>()!;
}
