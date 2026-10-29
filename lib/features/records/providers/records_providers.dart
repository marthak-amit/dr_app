import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/providers.dart';

/// Presentation metadata for a vault folder / record kind.
class KindMeta {
  const KindMeta(this.kind, this.key, this.title, this.icon);
  final RecordKind kind;
  final String key; // route key: lab | xray | prescription
  final String title;
  final String icon; // svg name

  Color color(AppPalette p) => switch (kind) {
        RecordKind.lab => p.primary,
        RecordKind.xray => p.warning,
        RecordKind.prescription => p.accent,
      };

  Color tint(AppPalette p) => switch (kind) {
        RecordKind.lab => p.primarySoft,
        RecordKind.xray => p.warningSoft,
        RecordKind.prescription => p.accentSoft,
      };
}

const kindMetas = <KindMeta>[
  KindMeta(RecordKind.lab, 'lab', 'Lab reports', 'test-tube-diagonal'),
  KindMeta(RecordKind.xray, 'xray', 'X-ray & scans', 'scan-line'),
  KindMeta(RecordKind.prescription, 'prescription', 'Prescriptions', 'pill'),
];

KindMeta metaOf(RecordKind k) => kindMetas.firstWhere((m) => m.kind == k);
KindMeta metaOfKey(String key) => kindMetas.firstWhere((m) => m.key == key, orElse: () => kindMetas.first);

/// "Updated 6d ago" for the newest record in [list].
String lastUpdatedLabel(List<HealthRecord> list) {
  if (list.isEmpty) return 'Empty';
  final newest = list.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
  return timeAgo(newest);
}

bool matchesQuery(HealthRecord r, String q) {
  final s = q.trim().toLowerCase();
  if (s.isEmpty) return true;
  return r.title.toLowerCase().contains(s) || r.source.toLowerCase().contains(s);
}
