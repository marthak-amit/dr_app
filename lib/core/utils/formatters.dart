import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _inr = NumberFormat.decimalPattern('en_IN');

/// 1500 -> ₹1,500
String rupees(num v) => '₹${_inr.format(v)}';

String fmtDate(DateTime d) => DateFormat('EEE, d MMM').format(d); // Tue, 4 Nov
String fmtDateLong(DateTime d) => DateFormat('d MMMM yyyy').format(d);
String fmtDateShort(DateTime d) => DateFormat('d MMM yyyy').format(d);
String fmtTime(DateTime d) => DateFormat('h:mm a').format(d);
String fmtTimeOfDay(TimeOfDay t) => fmtTime(DateTime(2000, 1, 1, t.hour, t.minute));

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// "Today", "Tomorrow", or "Tue, 4 Nov".
String relativeDay(DateTime d) {
  final now = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return fmtDate(d);
}

/// "Today, 4:30 PM"
String fmtWhen(DateTime d) => '${relativeDay(d)}, ${fmtTime(d)}';

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return fmtDateShort(d);
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String fmtFileSize(int kb) => kb >= 1024 ? '${(kb / 1024).toStringAsFixed(1)} MB' : '$kb KB';
