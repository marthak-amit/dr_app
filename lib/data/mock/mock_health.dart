import 'package:flutter/material.dart';
import '../models/models.dart';

DateTime _ago(int d, [int h = 0]) => DateTime.now().subtract(Duration(days: d, hours: h));

List<Prescription> buildMockPrescriptions() => [
      Prescription(
        id: 'rx1', doctorId: 'd7', patientName: 'Amit Marthak', date: _ago(6), diagnosis: 'Viral fever with body ache',
        medicines: const [
          Medicine(name: 'Paracetamol', strength: '650 mg', dosage: '1-1-1', duration: '5 days', instructions: 'After food'),
          Medicine(name: 'Cetirizine', strength: '10 mg', dosage: '0-0-1', duration: '5 days', instructions: 'At bedtime'),
          Medicine(name: 'ORS Sachet', strength: '', dosage: '1-0-1', duration: '3 days', instructions: 'Dissolve in 1L water'),
        ],
        advice: 'Plenty of fluids and rest. Avoid cold beverages. Review if fever persists beyond 3 days.', followUp: _ago(-1),
      ),
      Prescription(
        id: 'rx2', doctorId: 'd11', patientName: 'Sunita Marthak', date: _ago(18), diagnosis: 'Type 2 Diabetes Mellitus',
        medicines: const [
          Medicine(name: 'Metformin SR', strength: '500 mg', dosage: '1-0-1', duration: '30 days', instructions: 'After meals'),
          Medicine(name: 'Glimepiride', strength: '1 mg', dosage: '1-0-0', duration: '30 days', instructions: 'Before breakfast'),
          Medicine(name: 'Vitamin D3', strength: '60,000 IU', dosage: '1 weekly', duration: '8 weeks', instructions: 'After lunch'),
        ],
        advice: 'Low-GI diet, 30 min walk daily. HbA1c in 3 months.', followUp: _ago(-72),
      ),
      Prescription(
        id: 'rx3', doctorId: 'd5', patientName: 'Pooja Marthak', date: _ago(33), diagnosis: 'Allergic contact dermatitis',
        medicines: const [
          Medicine(name: 'Levocetirizine', strength: '5 mg', dosage: '0-0-1', duration: '7 days', instructions: 'At bedtime'),
          Medicine(name: 'Mometasone cream', strength: '0.1%', dosage: '0-1-1', duration: '10 days', instructions: 'Apply thin layer on affected area'),
        ],
        advice: 'Avoid harsh soaps and fragrances. Use a mild moisturiser.',
      ),
    ];

List<HealthRecord> buildMockRecords() => [
      HealthRecord(id: 'r1', title: 'Complete Blood Count (CBC)', kind: RecordKind.lab, date: _ago(6), sizeKb: 412, source: 'Thyrocare Labs'),
      HealthRecord(id: 'r2', title: 'Lipid Profile', kind: RecordKind.lab, date: _ago(20), sizeKb: 356, source: 'Dr. Lal PathLabs'),
      HealthRecord(id: 'r3', title: 'HbA1c & Fasting Sugar', kind: RecordKind.lab, date: _ago(35), sizeKb: 298, source: 'Metropolis'),
      HealthRecord(id: 'r4', title: 'Chest X-Ray (PA view)', kind: RecordKind.xray, date: _ago(48), sizeKb: 2480, source: 'CityCare Imaging', isPdf: false),
      HealthRecord(id: 'r5', title: 'Knee X-Ray (AP/Lateral)', kind: RecordKind.xray, date: _ago(95), sizeKb: 3120, source: 'LifeLine Radiology', isPdf: false),
      HealthRecord(id: 'r6', title: 'Rx – Viral fever', kind: RecordKind.prescription, date: _ago(6), sizeKb: 180, source: 'Dr. Kavita Trivedi'),
      HealthRecord(id: 'r7', title: 'Rx – Diabetes review', kind: RecordKind.prescription, date: _ago(18), sizeKb: 205, source: 'Dr. Farah Khan'),
      HealthRecord(id: 'r8', title: 'Thyroid Profile (T3, T4, TSH)', kind: RecordKind.lab, date: _ago(110), sizeKb: 264, source: 'Thyrocare Labs'),
    ];

List<AppNotification> buildMockNotifications() => [
      AppNotification(id: 'n1', title: 'Your turn is near!', body: 'You are #4 in line at CityCare Clinic. Estimated wait: 24 min.', time: _ago(0).subtract(const Duration(minutes: 5)), type: NotificationType.queue),
      AppNotification(id: 'n2', title: 'Appointment confirmed', body: 'Video consult with Dr. Priya Shah is confirmed for the day after tomorrow, 11:30 AM.', time: _ago(0, 2), type: NotificationType.appointment),
      AppNotification(id: 'n3', title: 'Time for Metformin 💊', body: 'Take 1 tablet of Metformin 500 mg after lunch.', time: _ago(0, 4), type: NotificationType.reminder, read: true),
      AppNotification(id: 'n4', title: 'Lab report ready', body: 'Your CBC report from Thyrocare is now available in Records.', time: _ago(1), type: NotificationType.report),
      AppNotification(id: 'n5', title: 'Flat 20% off on health checkups', body: 'Book a full-body checkup this week and save up to ₹800. Use code MEDIQ20.', time: _ago(2), type: NotificationType.offer, read: true),
      AppNotification(id: 'n6', title: 'Prescription received', body: 'Dr. Kavita Trivedi has shared a new prescription with you.', time: _ago(6), type: NotificationType.report, read: true),
      AppNotification(id: 'n7', title: 'Appointment reminder', body: 'You have a visit with Dr. Anjali Mehta in 5 days.', time: _ago(7), type: NotificationType.appointment, read: true),
    ];

List<MedicineReminder> buildMockReminders() => const [
      MedicineReminder(id: 'm1', medicine: 'Amlodipine 5 mg', dose: '1 tablet', time: TimeOfDay(hour: 8, minute: 0), note: 'After breakfast', taken: true),
      MedicineReminder(id: 'm2', medicine: 'Vitamin D3', dose: '1 capsule', time: TimeOfDay(hour: 9, minute: 30), note: 'With milk', taken: true),
      MedicineReminder(id: 'm3', medicine: 'Metformin 500 mg', dose: '1 tablet', time: TimeOfDay(hour: 13, minute: 30), note: 'After lunch'),
      MedicineReminder(id: 'm4', medicine: 'Omega-3', dose: '1 softgel', time: TimeOfDay(hour: 17, minute: 0), note: 'After snacks'),
      MedicineReminder(id: 'm5', medicine: 'Amlodipine 5 mg', dose: '1 tablet', time: TimeOfDay(hour: 21, minute: 0), note: 'After dinner'),
      MedicineReminder(id: 'm6', medicine: 'Cetirizine 10 mg', dose: '1 tablet', time: TimeOfDay(hour: 22, minute: 0), note: 'At bedtime'),
    ];

const mockLabTests = <LabTest>[
  LabTest(id: 'l1', name: 'Full Body Checkup', description: 'Comprehensive 85-parameter health screening incl. CBC, lipid, liver, kidney & thyroid.', price: 1499, mrp: 2999, testsCount: 85, reportIn: '24 hrs', icon: 'shield-check', fasting: true, popular: true),
  LabTest(id: 'l2', name: 'Diabetes Care Package', description: 'HbA1c, fasting & post-prandial sugar, urine microalbumin, lipid profile.', price: 799, mrp: 1399, testsCount: 22, reportIn: '12 hrs', icon: 'droplets', fasting: true, popular: true),
  LabTest(id: 'l3', name: 'Thyroid Profile', description: 'T3, T4 and TSH to assess thyroid function.', price: 349, mrp: 600, testsCount: 3, reportIn: '12 hrs', icon: 'activity'),
  LabTest(id: 'l4', name: 'Heart Health Package', description: 'Lipid profile, hs-CRP, ECG, Apo-B & homocysteine.', price: 1299, mrp: 2200, testsCount: 18, reportIn: '24 hrs', icon: 'heart-pulse', fasting: true),
  LabTest(id: 'l5', name: 'Vitamin Profile', description: 'Vitamin D (25-OH), B12 and folate levels.', price: 899, mrp: 1500, testsCount: 4, reportIn: '24 hrs', icon: 'pill'),
  LabTest(id: 'l6', name: 'Complete Blood Count', description: 'Hemoglobin, RBC, WBC, platelets and indices.', price: 249, mrp: 400, testsCount: 24, reportIn: '6 hrs', icon: 'test-tube-diagonal'),
];

List<VitalEntry> buildMockVitals() {
  final out = <VitalEntry>[];
  final bpSys = [128, 132, 126, 135, 130, 124, 129, 133, 127, 125];
  final bpDia = [84, 86, 82, 88, 85, 80, 83, 87, 82, 81];
  final sugar = [104, 112, 98, 118, 109, 101, 115, 106, 99, 108];
  final weight = [76.4, 76.2, 76.0, 75.8, 75.9, 75.5, 75.3, 75.2, 75.0, 74.8];
  for (var i = 0; i < 10; i++) {
    final d = DateTime.now().subtract(Duration(days: (9 - i) * 3));
    out.add(VitalEntry(type: VitalType.bp, date: d, value: bpSys[i].toDouble(), value2: bpDia[i].toDouble()));
    out.add(VitalEntry(type: VitalType.sugar, date: d, value: sugar[i].toDouble()));
    out.add(VitalEntry(type: VitalType.weight, date: d, value: weight[i]));
  }
  return out;
}

List<ChatMessage> buildMockChat() {
  DateTime t(int m) => DateTime.now().subtract(Duration(minutes: m));
  return [
    ChatMessage(id: 'c1', text: 'Hello! Welcome to CityCare Clinic 👋 How can we help you today?', fromMe: false, time: t(42)),
    ChatMessage(id: 'c2', text: 'Hi, I have an appointment with Dr. Patel today. Can I reach 15 minutes late?', fromMe: true, time: t(40)),
    ChatMessage(id: 'c3', text: 'Sure, no problem. Your token is #6 and there are 3 patients ahead of you, so you should be fine.', fromMe: false, time: t(38)),
    ChatMessage(id: 'c4', text: 'Great, thank you! Should I bring my old reports?', fromMe: true, time: t(36)),
    ChatMessage(id: 'c5', text: 'Yes please — latest ECG and blood pressure log would help the doctor. 🙂', fromMe: false, time: t(35)),
  ];
}
