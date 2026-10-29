import 'package:flutter/widgets.dart';

/// 8pt grid.
class AppSpacing {
  AppSpacing._();
  static const double x05 = 4;
  static const double x1 = 8;
  static const double x15 = 12;
  static const double x2 = 16;
  static const double x25 = 20;
  static const double x3 = 24;
  static const double x4 = 32;
  static const double x5 = 40;
  static const double x6 = 48;
  static const double screenH = 20; // horizontal screen padding
}

/// `Gap.v(8)` / `Gap.h(8)` — fixed gaps.
class Gap {
  Gap._();
  static SizedBox v(double h) => SizedBox(height: h);
  static SizedBox h(double w) => SizedBox(width: w);
}
