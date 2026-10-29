import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();
  static const fontFamily = 'PlusJakartaSans';

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle s(double size, FontWeight w, {double h = 1.3, double ls = 0, Color? c}) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          height: h,
          letterSpacing: ls,
          color: c ?? primary,
        );
    return TextTheme(
      displayLarge: s(36, FontWeight.w800, h: 1.15, ls: -0.8),
      displayMedium: s(30, FontWeight.w800, h: 1.2, ls: -0.6),
      displaySmall: s(26, FontWeight.w700, h: 1.2, ls: -0.4),
      headlineLarge: s(24, FontWeight.w700, h: 1.25, ls: -0.3),
      headlineMedium: s(22, FontWeight.w700, h: 1.25, ls: -0.2),
      headlineSmall: s(20, FontWeight.w700, h: 1.3),
      titleLarge: s(18, FontWeight.w700, h: 1.3),
      titleMedium: s(16, FontWeight.w600, h: 1.35),
      titleSmall: s(14, FontWeight.w600, h: 1.35),
      bodyLarge: s(16, FontWeight.w400, h: 1.5),
      bodyMedium: s(14, FontWeight.w400, h: 1.5, c: secondary),
      bodySmall: s(12, FontWeight.w400, h: 1.45, c: secondary),
      labelLarge: s(15, FontWeight.w700, h: 1.2, ls: .1),
      labelMedium: s(13, FontWeight.w600, h: 1.2),
      labelSmall: s(11, FontWeight.w600, h: 1.2, ls: .2, c: secondary),
    );
  }
}

extension TextX on BuildContext {
  TextTheme get tt => Theme.of(this).textTheme;
}
