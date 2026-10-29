import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/fake_latency.dart';
import '../mock/mock_appointments.dart';
import '../mock/mock_doctors.dart';
import '../mock/mock_health.dart';
import '../mock/mock_patients.dart';
import '../mock/mock_specialties.dart';
import '../models/models.dart';
import 'slot_generator.dart';

export '../mock/mock_clinics.dart';
export '../mock/mock_doctors.dart';
export '../mock/mock_health.dart' show mockLabTests;
export '../mock/mock_patients.dart';
export '../mock/mock_specialties.dart';
export '../models/models.dart';

// ───────────────────────── App-level state ─────────────────────────

enum AppMode { patient, doctor }

final appModeProvider = StateProvider<AppMode>((_) => AppMode.patient);
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.light);
final languageProvider = StateProvider<String>((_) => 'English');

class SessionState {
  const SessionState({this.loggedIn = false, this.profile = const UserProfile(name: 'Amit Marthak', phone: '+91 98765 43210')});
  final bool loggedIn;
  final UserProfile profile;
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();
  void login(String phone) => state = SessionState(loggedIn: true, profile: state.profile.copyWith(phone: '+91 $phone'));
  void saveProfile(UserProfile p) => state = SessionState(loggedIn: true, profile: p);
  void logout() => state = const SessionState();
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

// ───────────────────────── Catalogue (read-only) ─────────────────────────

final specialtiesProvider = Provider<List<Specialty>>((_) => mockSpecialties);

final doctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  await fakeLatency();
  return mockDoctors;
});

/// Synchronous lookup (no latency) – use inside lists/cards.
final doctorProvider = Provider.family<Doctor, String>((ref, id) => doctorById(id));

/// With latency – use on detail screens to show shimmer.
final doctorDetailProvider = FutureProvider.family<Doctor, String>((ref, id) async {
  await fakeLatency(350, 600);
  return doctorById(id);
});

/// Key: (doctorId, date).
final slotsProvider = FutureProvider.family<List<Slot>, (String, DateTime)>((ref, key) async {
  await fakeLatency(300, 600);
  return generateSlots(key.$1, key.$2);
});

final labTestsProvider = FutureProvider<List<LabTest>>((ref) async {
  await fakeLatency();
  return mockLabTests;
});

// ───────────────────────── Mutable data (AsyncNotifiers) ─────────────────────────

class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    await fakeLatency();
    return buildMockAppointments();
  }

  List<Appointment> get _cur => state.valueOrNull ?? const [];

  /// Adds a new upcoming appointment and returns it.
  Appointment add({
    required String doctorId,
    required String clinicId,
    required DateTime dateTime,
    required ConsultType type,
    required String patientName,
    required String reason,
    required int fee,
    required PaymentMethod payment,
  }) {
    final a = Appointment(
      id: 'a${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctorId,
      clinicId: clinicId,
      dateTime: dateTime,
      type: type,
      status: AppointmentStatus.upcoming,
      patientName: patientName,
      reason: reason,
      fee: fee,
      payment: payment,
      paid: payment != PaymentMethod.payAtClinic,
    );
    state = AsyncData([a, ..._cur]);
    return a;
  }

  void cancel(String id, String reason) =>
      state = AsyncData([for (final a in _cur) a.id == id ? a.copyWith(status: AppointmentStatus.cancelled, cancelReason: reason) : a]);

  void reschedule(String id, DateTime newTime) => state = AsyncData([for (final a in _cur) a.id == id ? a.copyWith(dateTime: newTime) : a]);

  void markCompleted(String id) => state = AsyncData([for (final a in _cur) a.id == id ? a.copyWith(status: AppointmentStatus.completed) : a]);
}

final appointmentsProvider = AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(AppointmentsNotifier.new);

/// Next upcoming appointment (soonest first), or null.
final nextAppointmentProvider = Provider<Appointment?>((ref) {
  final list = ref.watch(appointmentsProvider).valueOrNull ?? const [];
  final up = list.where((a) => a.status == AppointmentStatus.upcoming).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return up.isEmpty ? null : up.first;
});

class FamilyNotifier extends AsyncNotifier<List<Patient>> {
  @override
  Future<List<Patient>> build() async {
    await fakeLatency(300, 500);
    return mockFamily;
  }

  void add(Patient p) => state = AsyncData([...(state.valueOrNull ?? const []), p]);
  void remove(String id) => state = AsyncData([for (final p in state.valueOrNull ?? const <Patient>[]) if (p.id != id) p]);
}

final familyProvider = AsyncNotifierProvider<FamilyNotifier, List<Patient>>(FamilyNotifier.new);

class PrescriptionsNotifier extends AsyncNotifier<List<Prescription>> {
  @override
  Future<List<Prescription>> build() async {
    await fakeLatency();
    return buildMockPrescriptions();
  }

  /// Used by the doctor's Rx builder ("Send to patient").
  void add(Prescription p) => state = AsyncData([p, ...(state.valueOrNull ?? const [])]);
}

final prescriptionsProvider = AsyncNotifierProvider<PrescriptionsNotifier, List<Prescription>>(PrescriptionsNotifier.new);

class RecordsNotifier extends AsyncNotifier<List<HealthRecord>> {
  @override
  Future<List<HealthRecord>> build() async {
    await fakeLatency();
    return buildMockRecords();
  }

  void add(HealthRecord r) => state = AsyncData([r, ...(state.valueOrNull ?? const [])]);
  void remove(String id) => state = AsyncData([for (final r in state.valueOrNull ?? const <HealthRecord>[]) if (r.id != id) r]);
}

final recordsProvider = AsyncNotifierProvider<RecordsNotifier, List<HealthRecord>>(RecordsNotifier.new);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    await fakeLatency(300, 500);
    return buildMockNotifications();
  }

  List<AppNotification> get _cur => state.valueOrNull ?? const [];
  void markRead(String id) => state = AsyncData([for (final n in _cur) n.id == id ? n.copyWith(read: true) : n]);
  void markAllRead() => state = AsyncData([for (final n in _cur) n.copyWith(read: true)]);
  void clear() => state = const AsyncData([]);
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(NotificationsNotifier.new);
final unreadCountProvider = Provider<int>((ref) => (ref.watch(notificationsProvider).valueOrNull ?? const []).where((n) => !n.read).length);

class RemindersNotifier extends AsyncNotifier<List<MedicineReminder>> {
  @override
  Future<List<MedicineReminder>> build() async {
    await fakeLatency(300, 500);
    return buildMockReminders();
  }

  List<MedicineReminder> get _cur => state.valueOrNull ?? const [];
  void toggle(String id) => state = AsyncData([for (final r in _cur) r.id == id ? r.copyWith(taken: !r.taken) : r]);
  void add(MedicineReminder r) {
    final l = [..._cur, r]..sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
    state = AsyncData(l);
  }

  void remove(String id) => state = AsyncData([for (final r in _cur) if (r.id != id) r]);
}

final remindersProvider = AsyncNotifierProvider<RemindersNotifier, List<MedicineReminder>>(RemindersNotifier.new);

class VitalsNotifier extends AsyncNotifier<List<VitalEntry>> {
  @override
  Future<List<VitalEntry>> build() async {
    await fakeLatency();
    return buildMockVitals();
  }

  void add(VitalEntry e) => state = AsyncData([...(state.valueOrNull ?? const []), e]);
}

final vitalsProvider = AsyncNotifierProvider<VitalsNotifier, List<VitalEntry>>(VitalsNotifier.new);

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => buildMockChat();

  bool typing = false;

  /// Sends a message and schedules a canned clinic reply.
  void send(String text) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = [...state, ChatMessage(id: id, text: text, fromMe: true, time: DateTime.now())];
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      state = [
        ...state,
        ChatMessage(id: '${id}r', text: 'Thanks for your message! Our front-desk team will get back to you in a few minutes. 🙏', fromMe: false, time: DateTime.now()),
      ];
    });
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

// ───────────────────────── Live queue (shared by patient + doctor) ─────────────────────────

class QueueNotifier extends Notifier<QueueState> {
  @override
  QueueState build() => QueueState(entries: buildMockQueue(), doctorStatus: DoctorStatus.inConsult);

  List<QueueEntry> get _e => state.entries;

  /// Finishes the current patient and calls the next waiting one.
  void callNext() {
    final list = [..._e];
    final curIdx = list.indexWhere((e) => e.status == QueueStatus.inConsult);
    if (curIdx >= 0) list[curIdx] = list[curIdx].copyWith(status: QueueStatus.done);
    final nextIdx = list.indexWhere((e) => e.status == QueueStatus.waiting);
    if (nextIdx >= 0) list[nextIdx] = list[nextIdx].copyWith(status: QueueStatus.inConsult);
    state = state.copyWith(entries: list, doctorStatus: nextIdx >= 0 ? DoctorStatus.inConsult : DoctorStatus.idle);
  }

  /// Marks the current patient as done (no one called next).
  void markDone(String id) {
    state = state.copyWith(entries: [for (final e in _e) e.id == id ? e.copyWith(status: QueueStatus.done) : e], doctorStatus: DoctorStatus.idle);
  }

  void skip(String id) {
    state = state.copyWith(entries: [for (final e in _e) e.id == id ? e.copyWith(status: QueueStatus.skipped) : e]);
  }

  void callPatient(String id) {
    final list = [for (final e in _e) e.status == QueueStatus.inConsult ? e.copyWith(status: QueueStatus.done) : e];
    state = state.copyWith(entries: [for (final e in list) e.id == id ? e.copyWith(status: QueueStatus.inConsult) : e], doctorStatus: DoctorStatus.inConsult);
  }

  void toggleBreak() {
    state = state.copyWith(doctorStatus: state.doctorStatus == DoctorStatus.onBreak ? DoctorStatus.idle : DoctorStatus.onBreak);
  }
}

final queueProvider = NotifierProvider<QueueNotifier, QueueState>(QueueNotifier.new);
