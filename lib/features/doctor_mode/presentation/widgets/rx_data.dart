/// Local formulary used by the Rx builder autocomplete.
class DrugEntry {
  const DrugEntry(this.name, this.strength, this.form);
  final String name, strength, form;
  String get label => strength.isEmpty ? name : '$name $strength';
}

const kFormulary = <DrugEntry>[
  DrugEntry('Paracetamol', '500 mg', 'Tablet'),
  DrugEntry('Paracetamol', '650 mg', 'Tablet'),
  DrugEntry('Amlodipine', '5 mg', 'Tablet'),
  DrugEntry('Atorvastatin', '10 mg', 'Tablet'),
  DrugEntry('Atorvastatin', '20 mg', 'Tablet'),
  DrugEntry('Rosuvastatin', '10 mg', 'Tablet'),
  DrugEntry('Metformin', '500 mg', 'Tablet'),
  DrugEntry('Pantoprazole', '40 mg', 'Tablet'),
  DrugEntry('Omeprazole', '20 mg', 'Capsule'),
  DrugEntry('Azithromycin', '500 mg', 'Tablet'),
  DrugEntry('Amoxicillin', '500 mg', 'Capsule'),
  DrugEntry('Cefixime', '200 mg', 'Tablet'),
  DrugEntry('Cetirizine', '10 mg', 'Tablet'),
  DrugEntry('Levocetirizine', '5 mg', 'Tablet'),
  DrugEntry('Montelukast', '10 mg', 'Tablet'),
  DrugEntry('Telmisartan', '40 mg', 'Tablet'),
  DrugEntry('Losartan', '50 mg', 'Tablet'),
  DrugEntry('Aspirin', '75 mg', 'Tablet'),
  DrugEntry('Ecosprin', '75 mg', 'Tablet'),
  DrugEntry('Clopidogrel', '75 mg', 'Tablet'),
  DrugEntry('Metoprolol', '25 mg', 'Tablet'),
  DrugEntry('Metoprolol', '50 mg', 'Tablet'),
  DrugEntry('Vitamin D3', '60,000 IU', 'Sachet'),
  DrugEntry('Vitamin B12', '1500 mcg', 'Tablet'),
  DrugEntry('ORS', '', 'Sachet'),
  DrugEntry('Ibuprofen', '400 mg', 'Tablet'),
  DrugEntry('Diclofenac', '50 mg', 'Tablet'),
  DrugEntry('Ondansetron', '4 mg', 'Tablet'),
  DrugEntry('Domperidone', '10 mg', 'Tablet'),
  DrugEntry('Ranitidine', '150 mg', 'Tablet'),
  DrugEntry('Glimepiride', '1 mg', 'Tablet'),
  DrugEntry('Furosemide', '40 mg', 'Tablet'),
  DrugEntry('Ramipril', '5 mg', 'Capsule'),
  DrugEntry('Calcium + D3', '500 mg', 'Tablet'),
  DrugEntry('Folic acid', '5 mg', 'Tablet'),
  DrugEntry('Doxycycline', '100 mg', 'Capsule'),
  DrugEntry('Salbutamol', '2 mg', 'Tablet'),
  DrugEntry('Prednisolone', '10 mg', 'Tablet'),
  DrugEntry('Isosorbide mononitrate', '20 mg', 'Tablet'),
  DrugEntry('Ciprofloxacin', '500 mg', 'Tablet'),
];

const kDosages = ['1-0-1', '1-1-1', '1-0-0', '0-0-1', '0-1-0', '1-1-0', 'SOS'];
const kDurations = [3, 5, 7, 10, 15, 30];
const kInstructions = ['Before food', 'After food', 'With food', 'Bedtime'];
const kAdviceChips = ['Plenty of fluids', 'Low-salt diet', 'Avoid oily food', '30 min daily walk', 'Complete bed rest', 'Avoid cold drinks', 'Monitor BP daily', 'Review with reports'];

class RxItem {
  RxItem({required this.drug, this.dosage = '1-0-1', this.days = 5, this.instruction = 'After food'});
  final DrugEntry drug;
  String dosage;
  int days;
  String instruction;
}
