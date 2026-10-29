import 'package:flutter/material.dart';

enum Gender { male, female }

enum ConsultType { inClinic, video }

enum SlotPeriod { morning, afternoon, evening }

enum AppointmentStatus { upcoming, completed, cancelled }

enum PaymentMethod { upi, card, payAtClinic }

enum DoctorStatus { inConsult, onBreak, idle }

enum QueueStatus { waiting, inConsult, done, skipped }

enum NotificationType { appointment, reminder, report, offer, queue }

enum RecordKind { lab, xray, prescription }

enum VitalType { bp, sugar, weight }

class Specialty {
  const Specialty({required this.id, required this.name, required this.icon, required this.color, required this.tint});
  final String id;
  final String name;
  final String icon; // assets/icons/<icon>.svg
  final Color color;
  final Color tint;
}

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.image,
    required this.distanceKm,
    required this.rating,
    this.openHours = '9:00 AM – 8:00 PM',
  });
  final String id, name, address, city, phone, image, openHours;
  final double distanceKm, rating;
}

class Review {
  const Review({required this.author, required this.rating, required this.text, required this.daysAgo});
  final String author, text;
  final double rating;
  final int daysAgo;
}

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.specialty,
    required this.gender,
    required this.photo,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.patients,
    required this.fee,
    required this.videoFee,
    required this.about,
    required this.languages,
    required this.qualification,
    required this.clinicId,
    required this.availableToday,
    required this.nextAvailable,
    required this.reviews,
    this.isTop = false,
  });
  final String id, name, specialtyId, specialty, photo, about, qualification, clinicId, nextAvailable;
  final Gender gender;
  final double rating;
  final int reviewCount, experienceYears, patients, fee, videoFee;
  final List<String> languages;
  final bool availableToday, isTop;
  final List<Review> reviews;

  String get shortName => name.replaceFirst('Dr. ', '');
  String get heroTag => 'doctor-$id';
  int feeFor(ConsultType t) => t == ConsultType.video ? videoFee : fee;
}

class Slot {
  const Slot({required this.time, required this.period, required this.available});
  final DateTime time;
  final SlotPeriod period;
  final bool available;
}

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.relation = 'Self',
    this.bloodGroup = 'B+',
    this.allergies = const [],
    this.conditions = const [],
    this.visits = const [],
  });
  final String id, name, phone, relation, bloodGroup;
  final int age;
  final Gender gender;
  final List<String> allergies, conditions;
  final List<PastVisit> visits;

  String get initials => name.split(' ').where((e) => e.isNotEmpty).take(2).map((e) => e[0]).join().toUpperCase();
}

class PastVisit {
  const PastVisit({required this.date, required this.diagnosis, required this.notes, required this.doctorName});
  final DateTime date;
  final String diagnosis, notes, doctorName;
}

class Appointment {
  const Appointment({
    required this.id,
    required this.doctorId,
    required this.clinicId,
    required this.dateTime,
    required this.type,
    required this.status,
    required this.patientName,
    required this.reason,
    required this.fee,
    required this.payment,
    this.token,
    this.cancelReason,
    this.paid = false,
  });
  final String id, doctorId, clinicId, patientName, reason;
  final DateTime dateTime;
  final ConsultType type;
  final AppointmentStatus status;
  final int fee;
  final PaymentMethod payment;
  final int? token;
  final String? cancelReason;
  final bool paid;

  bool get isToday {
    final n = DateTime.now();
    return dateTime.year == n.year && dateTime.month == n.month && dateTime.day == n.day;
  }

  Appointment copyWith({DateTime? dateTime, AppointmentStatus? status, String? cancelReason, int? token}) => Appointment(
        id: id,
        doctorId: doctorId,
        clinicId: clinicId,
        dateTime: dateTime ?? this.dateTime,
        type: type,
        status: status ?? this.status,
        patientName: patientName,
        reason: reason,
        fee: fee,
        payment: payment,
        token: token ?? this.token,
        cancelReason: cancelReason ?? this.cancelReason,
        paid: paid,
      );
}

class Medicine {
  const Medicine({required this.name, required this.dosage, required this.duration, required this.instructions, this.strength = ''});
  final String name, dosage, duration, instructions, strength; // dosage like "1-0-1"
}

class Prescription {
  const Prescription({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.date,
    required this.diagnosis,
    required this.medicines,
    this.advice = '',
    this.followUp,
  });
  final String id, doctorId, patientName, diagnosis, advice;
  final DateTime date;
  final List<Medicine> medicines;
  final DateTime? followUp;
}

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.title,
    required this.kind,
    required this.date,
    required this.sizeKb,
    required this.source,
    this.isPdf = true,
  });
  final String id, title, source;
  final RecordKind kind;
  final DateTime date;
  final int sizeKb;
  final bool isPdf;
}

class AppNotification {
  const AppNotification({required this.id, required this.title, required this.body, required this.time, required this.type, this.read = false});
  final String id, title, body;
  final DateTime time;
  final NotificationType type;
  final bool read;
  AppNotification copyWith({bool? read}) => AppNotification(id: id, title: title, body: body, time: time, type: type, read: read ?? this.read);
}

class MedicineReminder {
  const MedicineReminder({required this.id, required this.medicine, required this.dose, required this.time, required this.note, this.taken = false});
  final String id, medicine, dose, note;
  final TimeOfDay time;
  final bool taken;
  MedicineReminder copyWith({bool? taken}) =>
      MedicineReminder(id: id, medicine: medicine, dose: dose, time: time, note: note, taken: taken ?? this.taken);
}

class LabTest {
  const LabTest({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.mrp,
    required this.testsCount,
    required this.reportIn,
    required this.icon,
    this.fasting = false,
    this.popular = false,
  });
  final String id, name, description, reportIn, icon;
  final int price, mrp, testsCount;
  final bool fasting, popular;
  int get discountPct => (((mrp - price) / mrp) * 100).round();
}

class VitalEntry {
  const VitalEntry({required this.type, required this.date, required this.value, this.value2});
  final VitalType type;
  final DateTime date;
  final double value; // systolic / sugar mg/dL / weight kg
  final double? value2; // diastolic
}

class ChatMessage {
  const ChatMessage({required this.id, required this.text, required this.fromMe, required this.time});
  final String id, text;
  final bool fromMe;
  final DateTime time;
}

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.token,
    required this.patient,
    required this.reason,
    required this.status,
    required this.arrival,
    this.isMe = false,
    this.type = ConsultType.inClinic,
  });
  final String id, reason;
  final int token;
  final Patient patient;
  final QueueStatus status;
  final DateTime arrival;
  final bool isMe;
  final ConsultType type;
  QueueEntry copyWith({QueueStatus? status}) =>
      QueueEntry(id: id, token: token, patient: patient, reason: reason, status: status ?? this.status, arrival: arrival, isMe: isMe, type: type);
}

class QueueState {
  const QueueState({required this.entries, required this.doctorStatus, this.avgMinutes = 8});
  final List<QueueEntry> entries;
  final DoctorStatus doctorStatus;
  final int avgMinutes;

  QueueEntry? get current => entries.where((e) => e.status == QueueStatus.inConsult).firstOrNull;
  List<QueueEntry> get waiting => entries.where((e) => e.status == QueueStatus.waiting).toList();
  QueueEntry? get me => entries.where((e) => e.isMe).firstOrNull;
  int get doneCount => entries.where((e) => e.status == QueueStatus.done).length;

  /// Number of patients ahead of me (waiting before my token + the one in consult).
  int get aheadOfMe {
    final m = me;
    if (m == null || m.status != QueueStatus.waiting) return 0;
    final w = waiting.where((e) => e.token < m.token).length;
    return w + (current != null ? 1 : 0);
  }

  int get estimatedWaitMinutes => aheadOfMe * avgMinutes;
  int get myPosition => aheadOfMe + 1;

  QueueState copyWith({List<QueueEntry>? entries, DoctorStatus? doctorStatus}) =>
      QueueState(entries: entries ?? this.entries, doctorStatus: doctorStatus ?? this.doctorStatus, avgMinutes: avgMinutes);
}

class UserProfile {
  const UserProfile({required this.name, required this.phone, this.age = 32, this.gender = Gender.male, this.bloodGroup = 'B+', this.email = ''});
  final String name, phone, bloodGroup, email;
  final int age;
  final Gender gender;
  UserProfile copyWith({String? name, String? phone, int? age, Gender? gender, String? bloodGroup, String? email}) => UserProfile(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        email: email ?? this.email,
      );
}
