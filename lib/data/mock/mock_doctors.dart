import '../models/models.dart';

const _rv = [
  Review(author: 'Hetal P.', rating: 5, text: 'Very patient and explains everything clearly. The clinic was clean and we were seen on time.', daysAgo: 3),
  Review(author: 'Mitesh D.', rating: 4.5, text: 'Great diagnosis and follow-up. Booking through the app was super smooth.', daysAgo: 12),
  Review(author: 'Sneha R.', rating: 5, text: 'Highly recommended. Felt completely at ease during the consultation.', daysAgo: 27),
  Review(author: 'Imran S.', rating: 4, text: 'Good experience overall. Waiting time was a bit long but worth it.', daysAgo: 41),
];

const mockDoctors = <Doctor>[
  Doctor(
    id: 'd1', name: 'Dr. Priya Shah', specialtyId: 'gyne', specialty: 'Gynecologist', gender: Gender.female,
    photo: 'assets/images/doctors/priya.png', rating: 4.9, reviewCount: 1284, experienceYears: 14, patients: 8200, fee: 700, videoFee: 500,
    about: 'Dr. Priya Shah is a senior gynecologist and obstetrician with 14 years of experience in high-risk pregnancy care, PCOS management and minimally invasive gynecologic surgery. She believes in a warm, unhurried consultation.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'MBBS, MD (OBG), FICOG', clinicId: 'c1', availableToday: true, nextAvailable: 'Today, 4:30 PM', reviews: _rv, isTop: true,
  ),
  Doctor(
    id: 'd2', name: 'Dr. Rakesh Patel', specialtyId: 'cardio', specialty: 'Cardiologist', gender: Gender.male,
    photo: 'assets/images/doctors/rakesh.png', rating: 4.8, reviewCount: 2150, experienceYears: 20, patients: 12400, fee: 1000, videoFee: 800,
    about: 'Dr. Rakesh Patel is an interventional cardiologist known for preventive cardiology and complex angioplasty. He has treated over 12,000 patients and leads the cardiac wellness programme at CityCare.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'MBBS, MD, DM (Cardiology)', clinicId: 'c1', availableToday: true, nextAvailable: 'Today, 11:30 AM', reviews: _rv, isTop: true,
  ),
  Doctor(
    id: 'd3', name: 'Dr. Anjali Mehta', specialtyId: 'pedia', specialty: 'Pediatrician', gender: Gender.female,
    photo: 'assets/images/doctors/anjali.png', rating: 4.9, reviewCount: 980, experienceYears: 11, patients: 6100, fee: 600, videoFee: 400,
    about: 'A friendly pediatrician specialising in newborn care, vaccinations, growth monitoring and childhood allergies. Parents love her calm approach with kids.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'MBBS, DCH, MD (Pediatrics)', clinicId: 'c2', availableToday: true, nextAvailable: 'Today, 5:00 PM', reviews: _rv, isTop: true,
  ),
  Doctor(
    id: 'd4', name: 'Dr. Vikram Desai', specialtyId: 'ortho', specialty: 'Orthopedic Surgeon', gender: Gender.male,
    photo: 'assets/images/doctors/vikram.png', rating: 4.7, reviewCount: 1560, experienceYears: 17, patients: 9300, fee: 900, videoFee: 650,
    about: 'Joint replacement and sports injury specialist with 17 years of experience. Focused on getting patients back on their feet with the least invasive option.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'MBBS, MS (Ortho), Fellowship Arthroplasty', clinicId: 'c3', availableToday: false, nextAvailable: 'Tomorrow, 10:00 AM', reviews: _rv, isTop: true,
  ),
  Doctor(
    id: 'd5', name: 'Dr. Neha Joshi', specialtyId: 'derma', specialty: 'Dermatologist', gender: Gender.female,
    photo: 'assets/images/doctors/neha.png', rating: 4.8, reviewCount: 1105, experienceYears: 9, patients: 5400, fee: 800, videoFee: 550,
    about: 'Specialist in acne, pigmentation, hair-fall and advanced skin care. Combines evidence-based treatment with practical lifestyle guidance.',
    languages: ['English', 'Hindi'], qualification: 'MBBS, MD (Dermatology)', clinicId: 'c2', availableToday: true, nextAvailable: 'Today, 6:15 PM', reviews: _rv, isTop: true,
  ),
  Doctor(
    id: 'd6', name: 'Dr. Arjun Nair', specialtyId: 'neuro', specialty: 'Neurologist', gender: Gender.male,
    photo: 'assets/images/doctors/arjun.png', rating: 4.8, reviewCount: 760, experienceYears: 15, patients: 4800, fee: 1200, videoFee: 900,
    about: 'Treats migraine, epilepsy, stroke recovery and movement disorders. Trained at NIMHANS with a keen interest in headache medicine.',
    languages: ['English', 'Hindi', 'Malayalam'], qualification: 'MBBS, MD, DM (Neurology)', clinicId: 'c3', availableToday: false, nextAvailable: 'Tomorrow, 12:00 PM', reviews: _rv,
  ),
  Doctor(
    id: 'd7', name: 'Dr. Kavita Trivedi', specialtyId: 'general', specialty: 'General Physician', gender: Gender.female,
    photo: 'assets/images/doctors/kavita.png', rating: 4.6, reviewCount: 2310, experienceYears: 12, patients: 15000, fee: 400, videoFee: 300,
    about: 'Family physician for fevers, infections, lifestyle diseases and preventive health check-ups. Your first stop for any health concern.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'MBBS, MD (General Medicine)', clinicId: 'c4', availableToday: true, nextAvailable: 'Today, 12:15 PM', reviews: _rv,
  ),
  Doctor(
    id: 'd8', name: 'Dr. Sanjay Gupta', specialtyId: 'dental', specialty: 'Dentist', gender: Gender.male,
    photo: 'assets/images/doctors/sanjay.png', rating: 4.7, reviewCount: 890, experienceYears: 16, patients: 7000, fee: 500, videoFee: 350,
    about: 'Cosmetic dentistry, root canals and smile makeovers using painless modern techniques. Gentle with kids and anxious patients.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'BDS, MDS (Prosthodontics)', clinicId: 'c4', availableToday: true, nextAvailable: 'Today, 3:45 PM', reviews: _rv,
  ),
  Doctor(
    id: 'd9', name: 'Dr. Meera Iyer', specialtyId: 'eye', specialty: 'Ophthalmologist', gender: Gender.female,
    photo: 'assets/images/doctors/meera.png', rating: 4.9, reviewCount: 640, experienceYears: 13, patients: 5200, fee: 700, videoFee: 500,
    about: 'Cataract and LASIK specialist. Also manages dry-eye, glaucoma and paediatric eye problems with the latest diagnostic technology.',
    languages: ['English', 'Hindi', 'Tamil'], qualification: 'MBBS, MS (Ophthalmology)', clinicId: 'c1', availableToday: false, nextAvailable: 'Tomorrow, 9:30 AM', reviews: _rv,
  ),
  Doctor(
    id: 'd10', name: 'Dr. Rohan Kulkarni', specialtyId: 'ent', specialty: 'ENT Specialist', gender: Gender.male,
    photo: 'assets/images/doctors/rohan.png', rating: 4.6, reviewCount: 520, experienceYears: 8, patients: 3600, fee: 600, videoFee: 450,
    about: 'Treats sinusitis, tonsillitis, hearing loss and sleep apnea. Offers endoscopic ENT procedures with quick recovery.',
    languages: ['English', 'Hindi', 'Marathi'], qualification: 'MBBS, MS (ENT)', clinicId: 'c2', availableToday: true, nextAvailable: 'Today, 7:00 PM', reviews: _rv,
  ),
  Doctor(
    id: 'd11', name: 'Dr. Farah Khan', specialtyId: 'endo', specialty: 'Endocrinologist', gender: Gender.female,
    photo: 'assets/images/doctors/farah.png', rating: 4.8, reviewCount: 710, experienceYears: 10, patients: 4300, fee: 900, videoFee: 650,
    about: 'Diabetes, thyroid and hormonal disorders expert. Builds personalised plans with diet, medication and continuous glucose monitoring.',
    languages: ['English', 'Hindi', 'Urdu', 'Gujarati'], qualification: 'MBBS, MD, DM (Endocrinology)', clinicId: 'c3', availableToday: true, nextAvailable: 'Today, 2:30 PM', reviews: _rv,
  ),
  Doctor(
    id: 'd12', name: 'Dr. Harsh Vyas', specialtyId: 'pulmo', specialty: 'Pulmonologist', gender: Gender.male,
    photo: 'assets/images/doctors/harsh.png', rating: 4.5, reviewCount: 430, experienceYears: 12, patients: 3100, fee: 800, videoFee: 600,
    about: 'Asthma, COPD, allergies and sleep-related breathing disorders. Runs a dedicated pulmonary rehabilitation programme.',
    languages: ['English', 'Hindi', 'Gujarati'], qualification: 'MBBS, MD (Pulmonary Medicine)', clinicId: 'c4', availableToday: false, nextAvailable: 'Tomorrow, 5:30 PM', reviews: _rv,
  ),
];

Doctor doctorById(String id) => mockDoctors.firstWhere((d) => d.id == id, orElse: () => mockDoctors.first);

/// The doctor whose view is shown in "Doctor mode".
const kDoctorModeDoctorId = 'd2';
