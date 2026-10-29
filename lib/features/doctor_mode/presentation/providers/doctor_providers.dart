import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fake_latency.dart';
import '../../../../data/repositories/providers.dart';

/// Simulated network load for the doctor dashboard.
final doctorDashboardLoadProvider = FutureProvider<bool>((ref) async {
  await fakeLatency();
  return true;
});

/// Weekly patients (Mon–Sat) used by the dashboard chart. Last entry for "today" is filled in by the UI.
const kWeekPatients = <double>[26, 31, 29, 36, 33, 22, 0];
const kWeekRevenue = <double>[24.5, 29, 27.5, 34, 31, 20, 0]; // in ₹ thousands

String slotKey(DateTime t) => '${t.year}-${t.month}-${t.day} ${t.hour}:${t.minute}';
String dayKey(DateTime t) => '${t.year}-${t.month}-${t.day}';

class LeaveRange {
  const LeaveRange({required this.from, required this.to, required this.reason});
  final DateTime from, to;
  final String reason;
  bool covers(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return !x.isBefore(DateTime(from.year, from.month, from.day)) && !x.isAfter(DateTime(to.year, to.month, to.day));
  }
}

class ScheduleState {
  const ScheduleState({this.blocked = const {}, this.leaves = const [], this.workingDays = const {1, 2, 3, 4, 5, 6}});
  final Map<String, String> blocked; // slotKey -> reason
  final List<LeaveRange> leaves;
  final Set<int> workingDays; // DateTime.weekday values

  bool onLeave(DateTime d) => leaves.any((l) => l.covers(d));
  bool isWorking(DateTime d) => workingDays.contains(d.weekday);

  ScheduleState copyWith({Map<String, String>? blocked, List<LeaveRange>? leaves, Set<int>? workingDays}) =>
      ScheduleState(blocked: blocked ?? this.blocked, leaves: leaves ?? this.leaves, workingDays: workingDays ?? this.workingDays);
}

class ScheduleNotifier extends Notifier<ScheduleState> {
  @override
  ScheduleState build() => const ScheduleState();

  void block(Iterable<DateTime> slots, String reason) {
    final m = {...state.blocked};
    for (final s in slots) {
      m[slotKey(s)] = reason;
    }
    state = state.copyWith(blocked: m);
  }

  void unblock(DateTime slot) {
    final m = {...state.blocked}..remove(slotKey(slot));
    state = state.copyWith(blocked: m);
  }

  void addLeave(LeaveRange l) => state = state.copyWith(leaves: [...state.leaves, l]);
  void removeLeave(LeaveRange l) => state = state.copyWith(leaves: [for (final x in state.leaves) if (x != l) x]);

  void toggleDay(int weekday) {
    final s = {...state.workingDays};
    if (!s.add(weekday)) s.remove(weekday);
    state = state.copyWith(workingDays: s);
  }
}

final scheduleProvider = NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);

/// Looks up a patient by id from the doctor's patients, then family, else first mock patient.
Patient findPatient(String id) {
  for (final p in mockQueuePatients) {
    if (p.id == id) return p;
  }
  for (final p in mockFamily) {
    if (p.id == id) return p;
  }
  return mockQueuePatients.first;
}
