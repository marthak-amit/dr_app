import '../models/models.dart';

const mockClinics = <Clinic>[
  Clinic(id: 'c1', name: 'CityCare Clinic', address: '4th Floor, Shivalik Plaza, Ambawadi, Ahmedabad 380015', city: 'Ahmedabad', phone: '+91 98250 11234', image: 'assets/images/clinics/c1.jpg', distanceKm: 2.4, rating: 4.7),
  Clinic(id: 'c2', name: 'HealWell Multispeciality', address: '12, Satellite Road, Near Iscon Cross Roads, Ahmedabad 380054', city: 'Ahmedabad', phone: '+91 98791 45678', image: 'assets/images/clinics/c2.jpg', distanceKm: 5.1, rating: 4.6),
  Clinic(id: 'c3', name: 'LifeLine Hospital', address: 'B-21, Citylight Road, Athwa, Surat 395007', city: 'Surat', phone: '+91 97270 22345', image: 'assets/images/clinics/c3.jpg', distanceKm: 8.8, rating: 4.8),
  Clinic(id: 'c4', name: 'Sunrise Health Centre', address: '101, Vesu Main Road, Opp. Reliance Mart, Surat 395007', city: 'Surat', phone: '+91 99099 33456', image: 'assets/images/clinics/c4.jpg', distanceKm: 3.7, rating: 4.5),
];

Clinic clinicById(String id) => mockClinics.firstWhere((c) => c.id == id, orElse: () => mockClinics.first);
