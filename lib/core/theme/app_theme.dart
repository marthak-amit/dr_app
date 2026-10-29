import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_radius.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: p.primary,
      secondary: p.accent,
      onSecondary: Colors.white,
      secondaryContainer: p.accentSoft,
      onSecondaryContainer: p.accent,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: p.surfaceAlt,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.border,
      shadow: p.shadow,
    );
    final tt = AppTypography.textTheme(p.textPrimary, p.textSecondary);
    final overlay = b == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      fontFamily: AppTypography.fontFamily,
      textTheme: tt,
      primaryTextTheme: tt,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: p.textPrimary,
        titleTextStyle: tt.titleLarge,
        systemOverlayStyle: overlay.copyWith(statusBarColor: Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: tt.bodyMedium!.copyWith(color: p.textTertiary),
        labelStyle: tt.bodyMedium,
        border: OutlineInputBorder(borderRadius: AppRadius.rMd, borderSide: BorderSide(color: p.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.rMd, borderSide: BorderSide(color: p.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.rMd, borderSide: BorderSide(color: p.primary, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.rMd, borderSide: BorderSide(color: p.danger)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark ? p.surfaceAlt : const Color(0xFF10303A),
        contentTextStyle: tt.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : p.textTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.primary : p.surfaceAlt),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.primary : Colors.transparent),
        side: BorderSide(color: p.textTertiary, width: 1.5),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: tt.labelLarge,
        unselectedLabelStyle: tt.labelLarge!.copyWith(fontWeight: FontWeight.w600),
        labelColor: p.primary,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: p.primary,
        dividerColor: p.border,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
