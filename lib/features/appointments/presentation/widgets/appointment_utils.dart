import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories/providers.dart';

/// Token shown on tickets. Mock appointments carry one; new in-clinic bookings get a derived one.
int? tokenFor(Appointment a) {
  if (a.token != null) return a.token;
  if (a.type == ConsultType.video) return null;
  return 9 + (a.id.hashCode.abs() % 14);
}

String paymentLabel(PaymentMethod m) => switch (m) {
      PaymentMethod.upi => 'UPI',
      PaymentMethod.card => 'Credit / Debit card',
      PaymentMethod.payAtClinic => 'Pay at clinic',
    };

IconData paymentIcon(PaymentMethod m) => switch (m) {
      PaymentMethod.upi => Icons.account_balance_wallet_rounded,
      PaymentMethod.card => Icons.credit_card_rounded,
      PaymentMethod.payAtClinic => Icons.storefront_rounded,
    };

String typeLabel(ConsultType t) => t == ConsultType.video ? 'Video consult' : 'In-clinic';

({String label, Color fg, Color bg, IconData icon}) statusStyle(BuildContext context, AppointmentStatus s) {
  final p = context.pal;
  return switch (s) {
    AppointmentStatus.upcoming => (label: 'Upcoming', fg: p.primary, bg: p.primarySoft, icon: Icons.schedule_rounded),
    AppointmentStatus.completed => (label: 'Completed', fg: p.success, bg: p.successSoft, icon: Icons.check_circle_rounded),
    AppointmentStatus.cancelled => (label: 'Cancelled', fg: p.danger, bg: p.dangerSoft, icon: Icons.cancel_rounded),
  };
}

const platformFee = 29;
int gstOn(int platform) => (platform * 0.18).round();

String bookingCode(Appointment a) {
  final s = a.id.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '').padLeft(6, '0');
  return 'MQ${s.substring(s.length - 6)}';
}
