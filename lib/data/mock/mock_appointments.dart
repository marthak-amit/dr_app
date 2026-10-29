import '../models/models.dart';
import 'mock_patients.dart';

DateTime _at(int dayOffset, int h, [int m = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + dayOffset, h, m);
}

/// Today's appointment is always 2 hours from now (rounded) so the "live queue" card shows.
DateTime _soon() {
  final n = DateTime.now().add(const Duration(minutes: 40));
  return DateTime(n.year, n.month, n.day, n.hour, n.minute < 30 ? 0 : 30);
}

List<Appointment> buildMockAppointments() => [
      Appointment(id: 'a1', doctorId: 'd2', clinicId: 'c1', dateTime: _soon(), type: ConsultType.inClinic, status: AppointmentStatus.upcoming, patientName: 'Amit Marthak', reason: 'Blood pressure follow-up', fee: 1000, payment: PaymentMethod.upi, token: 6, paid: true),
      Appointment(id: 'a2', doctorId: 'd1', clinicId: 'c1', dateTime: _at(2, 11, 30), type: ConsultType.video, status: AppointmentStatus.upcoming, patientName: 'Pooja Marthak', reason: 'PCOS consultation', fee: 500, payment: PaymentMethod.card, paid: true),
      Appointment(id: 'a3', doctorId: 'd3', clinicId: 'c2', dateTime: _at(5, 17, 0), type: ConsultType.inClinic, status: AppointmentStatus.upcoming, patientName: 'Aarav Marthak', reason: 'Vaccination & growth check', fee: 600, payment: PaymentMethod.payAtClinic),
      Appointment(id: 'a4', doctorId: 'd7', clinicId: 'c4', dateTime: _at(-6, 12, 15), type: ConsultType.inClinic, status: AppointmentStatus.completed, patientName: 'Amit Marthak', reason: 'Fever & body ache', fee: 400, payment: PaymentMethod.upi, paid: true),
      Appointment(id: 'a5', doctorId: 'd11', clinicId: 'c3', dateTime: _at(-18, 14, 30), type: ConsultType.video, status: AppointmentStatus.completed, patientName: 'Sunita Marthak', reason: 'Diabetes review', fee: 650, payment: PaymentMethod.card, paid: true),
      Appointment(id: 'a6', doctorId: 'd5', clinicId: 'c2', dateTime: _at(-33, 18, 15), type: ConsultType.inClinic, status: AppointmentStatus.completed, patientName: 'Pooja Marthak', reason: 'Skin allergy', fee: 800, payment: PaymentMethod.upi, paid: true),
      Appointment(id: 'a7', doctorId: 'd8', clinicId: 'c4', dateTime: _at(-52, 15, 45), type: ConsultType.inClinic, status: AppointmentStatus.completed, patientName: 'Amit Marthak', reason: 'Dental cleaning', fee: 500, payment: PaymentMethod.payAtClinic, paid: true),
      Appointment(id: 'a8', doctorId: 'd4', clinicId: 'c3', dateTime: _at(-10, 10, 0), type: ConsultType.inClinic, status: AppointmentStatus.cancelled, patientName: 'Sunita Marthak', reason: 'Knee pain', fee: 900, payment: PaymentMethod.upi, cancelReason: 'Doctor unavailable'),
      Appointment(id: 'a9', doctorId: 'd10', clinicId: 'c2', dateTime: _at(-25, 19, 0), type: ConsultType.video, status: AppointmentStatus.cancelled, patientName: 'Amit Marthak', reason: 'Sinus congestion', fee: 450, payment: PaymentMethod.card, cancelReason: 'Schedule conflict'),
    ];

/// Queue shown in both the patient tracker and the doctor "Queue control" screen.
List<QueueEntry> buildMockQueue() {
  final p = mockQueuePatients;
  DateTime arr(int minsAgo) => DateTime.now().subtract(Duration(minutes: minsAgo));
  return [
    QueueEntry(id: 'e1', token: 1, patient: p[0], reason: 'BP review', status: QueueStatus.done, arrival: arr(75)),
    QueueEntry(id: 'e2', token: 2, patient: p[1], reason: 'Palpitations', status: QueueStatus.done, arrival: arr(62)),
    QueueEntry(id: 'e3', token: 3, patient: p[2], reason: 'Routine check', status: QueueStatus.inConsult, arrival: arr(50)),
    QueueEntry(id: 'e4', token: 4, patient: p[4], reason: 'AF follow-up', status: QueueStatus.waiting, arrival: arr(41)),
    QueueEntry(id: 'e5', token: 5, patient: p[5], reason: 'Chest tightness', status: QueueStatus.waiting, arrival: arr(33), type: ConsultType.inClinic),
    QueueEntry(id: 'e6', token: 6, patient: p[3], reason: 'Blood pressure follow-up', status: QueueStatus.waiting, arrival: arr(20), isMe: true),
    QueueEntry(id: 'e7', token: 7, patient: p[6], reason: 'Stress test report', status: QueueStatus.waiting, arrival: arr(12)),
    QueueEntry(id: 'e8', token: 8, patient: p[7], reason: 'Post-stent review', status: QueueStatus.waiting, arrival: arr(5)),
  ];
}
