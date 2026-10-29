import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/providers.dart';

class VitalStatus {
  const VitalStatus(this.label, this.level);
  final String label;
  final int level; // 0 normal · 1 elevated · 2 high

  Color color(AppPalette p) => switch (level) { 0 => p.success, 1 => p.warning, _ => p.danger };
  Color soft(AppPalette p) => switch (level) { 0 => p.successSoft, 1 => p.warningSoft, _ => p.dangerSoft };
}

const double kHeightM = 1.72;

VitalStatus statusOf(VitalEntry e) {
  switch (e.type) {
    case VitalType.bp:
      final s = e.value, d = e.value2 ?? 0;
      if (s >= 140 || d >= 90) return const VitalStatus('High', 2);
      if (s >= 130 || d >= 85) return const VitalStatus('Elevated', 1);
      return const VitalStatus('Normal', 0);
    case VitalType.sugar:
      if (e.value >= 126) return const VitalStatus('High', 2);
      if (e.value >= 100) return const VitalStatus('Elevated', 1);
      return const VitalStatus('Normal', 0);
    case VitalType.weight:
      final bmi = e.value / (kHeightM * kHeightM);
      if (bmi >= 30) return const VitalStatus('Obese', 2);
      if (bmi >= 25) return const VitalStatus('Overweight', 1);
      if (bmi < 18.5) return const VitalStatus('Underweight', 1);
      return const VitalStatus('Normal', 0);
  }
}

class VitalMeta {
  const VitalMeta(this.type, this.title, this.unit, this.icon);
  final VitalType type;
  final String title, unit;
  final IconData icon;
}

const vitalMetas = <VitalMeta>[
  VitalMeta(VitalType.bp, 'Blood pressure', 'mmHg', Icons.favorite_rounded),
  VitalMeta(VitalType.sugar, 'Blood sugar', 'mg/dL', Icons.water_drop_rounded),
  VitalMeta(VitalType.weight, 'Weight', 'kg', Icons.monitor_weight_rounded),
];

VitalMeta vitalMeta(VitalType t) => vitalMetas.firstWhere((m) => m.type == t);

String fmtNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String fmtValue(VitalEntry e) => e.type == VitalType.bp ? '${fmtNum(e.value)}/${fmtNum(e.value2 ?? 0)}' : fmtNum(e.value);
