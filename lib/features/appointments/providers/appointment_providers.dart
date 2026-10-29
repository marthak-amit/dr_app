import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/providers.dart';

/// Lookup of a single appointment by id (null while loading / unknown).
final appointmentByIdProvider = Provider.family<Appointment?, String>((ref, id) {
  final list = ref.watch(appointmentsProvider).valueOrNull ?? const <Appointment>[];
  for (final a in list) {
    if (a.id == id) return a;
  }
  return null;
});

/// Appointments of a given status, sorted (upcoming ascending, others newest first).
final appointmentsByStatusProvider = Provider.family<List<Appointment>, AppointmentStatus>((ref, status) {
  final list = (ref.watch(appointmentsProvider).valueOrNull ?? const <Appointment>[]).where((a) => a.status == status).toList();
  list.sort((a, b) => status == AppointmentStatus.upcoming ? a.dateTime.compareTo(b.dateTime) : b.dateTime.compareTo(a.dateTime));
  return list;
});
