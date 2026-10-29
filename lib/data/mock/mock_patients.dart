import '../models/models.dart';

DateTime _ago(int days) => DateTime.now().subtract(Duration(days: days));

final mockFamily = <Patient>[
  Patient(id: 'p0', name: 'Amit Marthak', age: 32, gender: Gender.male, phone: '+91 98765 43210', relation: 'Self', bloodGroup: 'B+', allergies: ['Penicillin'], conditions: ['Mild hypertension']),
  Patient(id: 'p1', name: 'Pooja Marthak', age: 29, gender: Gender.female, phone: '+91 98765 43211', relation: 'Spouse', bloodGroup: 'O+', allergies: [], conditions: ['PCOS']),
  Patient(id: 'p2', name: 'Aarav Marthak', age: 6, gender: Gender.male, phone: '+91 98765 43210', relation: 'Son', bloodGroup: 'B+', allergies: ['Dust'], conditions: []),
  Patient(id: 'p3', name: 'Sunita Marthak', age: 61, gender: Gender.female, phone: '+91 98765 43212', relation: 'Mother', bloodGroup: 'A+', allergies: ['Sulfa drugs'], conditions: ['Type 2 diabetes', 'Arthritis']),
];

/// Patients appearing in the doctor's queue / patient detail screens.
final mockQueuePatients = <Patient>[
  Patient(id: 'q1', name: 'Ramesh Chauhan', age: 58, gender: Gender.male, phone: '+91 98240 11122', bloodGroup: 'A+', allergies: ['Aspirin'], conditions: ['Hypertension', 'High cholesterol'], visits: [
    PastVisit(date: _ago(30), diagnosis: 'Hypertension – follow up', notes: 'BP 148/92. Amlodipine continued. Advised low-salt diet.', doctorName: 'Dr. Rakesh Patel'),
    PastVisit(date: _ago(120), diagnosis: 'Chest discomfort', notes: 'ECG normal. Started statin therapy.', doctorName: 'Dr. Rakesh Patel'),
  ]),
  Patient(id: 'q2', name: 'Sunil Vora', age: 45, gender: Gender.male, phone: '+91 98795 33445', bloodGroup: 'B+', conditions: ['Type 2 diabetes'], visits: [
    PastVisit(date: _ago(45), diagnosis: 'Palpitations', notes: 'Holter advised. Normal echo.', doctorName: 'Dr. Rakesh Patel'),
  ]),
  Patient(id: 'q3', name: 'Hina Sheikh', age: 36, gender: Gender.female, phone: '+91 97277 55667', bloodGroup: 'O+', allergies: ['Latex'], visits: [
    PastVisit(date: _ago(90), diagnosis: 'Routine cardiac check', notes: 'All parameters normal.', doctorName: 'Dr. Rakesh Patel'),
  ]),
  Patient(id: 'q4', name: 'Amit Marthak', age: 32, gender: Gender.male, phone: '+91 98765 43210', bloodGroup: 'B+', allergies: ['Penicillin'], conditions: ['Mild hypertension'], visits: [
    PastVisit(date: _ago(60), diagnosis: 'Borderline BP', notes: 'Lifestyle modification advised. Review in 2 months.', doctorName: 'Dr. Rakesh Patel'),
  ]),
  Patient(id: 'q5', name: 'Kiran Solanki', age: 67, gender: Gender.female, phone: '+91 98253 77889', bloodGroup: 'AB+', allergies: ['Sulfa drugs'], conditions: ['Atrial fibrillation', 'Diabetes'], visits: [
    PastVisit(date: _ago(21), diagnosis: 'AF – rate control', notes: 'On metoprolol + apixaban. INR stable.', doctorName: 'Dr. Rakesh Patel'),
    PastVisit(date: _ago(150), diagnosis: 'Dizziness', notes: 'Started anticoagulation.', doctorName: 'Dr. Rakesh Patel'),
  ]),
  Patient(id: 'q6', name: 'Nikhil Bhatt', age: 29, gender: Gender.male, phone: '+91 99099 88990', bloodGroup: 'B-', visits: []),
  Patient(id: 'q7', name: 'Dhara Parmar', age: 41, gender: Gender.female, phone: '+91 98980 12345', bloodGroup: 'A-', conditions: ['Thyroid'], visits: [
    PastVisit(date: _ago(75), diagnosis: 'Chest pain – noncardiac', notes: 'Stress test negative.', doctorName: 'Dr. Rakesh Patel'),
  ]),
  Patient(id: 'q8', name: 'Jayesh Modi', age: 52, gender: Gender.male, phone: '+91 98251 44556', bloodGroup: 'O+', conditions: ['CAD – stented 2022'], visits: [
    PastVisit(date: _ago(14), diagnosis: 'Post-stent review', notes: 'Asymptomatic. Continue DAPT.', doctorName: 'Dr. Rakesh Patel'),
  ]),
];
