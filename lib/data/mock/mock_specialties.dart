import 'package:flutter/material.dart';
import '../models/models.dart';

const mockSpecialties = <Specialty>[
  Specialty(id: 'general', name: 'General', icon: 'stethoscope', color: Color(0xFF0E7C86), tint: Color(0xFFE2F2F3)),
  Specialty(id: 'cardio', name: 'Cardiologist', icon: 'heart-pulse', color: Color(0xFFE5484D), tint: Color(0xFFFDE9EA)),
  Specialty(id: 'pedia', name: 'Pediatrician', icon: 'baby', color: Color(0xFFF5A524), tint: Color(0xFFFFF3DB)),
  Specialty(id: 'gyne', name: 'Gynecologist', icon: 'flower-2', color: Color(0xFFD6409F), tint: Color(0xFFFDE8F5)),
  Specialty(id: 'derma', name: 'Dermatologist', icon: 'sparkles', color: Color(0xFF8E5CF7), tint: Color(0xFFF0E9FE)),
  Specialty(id: 'ortho', name: 'Orthopedic', icon: 'bone', color: Color(0xFF3B82F6), tint: Color(0xFFE6EFFE)),
  Specialty(id: 'neuro', name: 'Neurologist', icon: 'brain', color: Color(0xFF6C5CE7), tint: Color(0xFFECE9FD)),
  Specialty(id: 'eye', name: 'Eye Specialist', icon: 'eye', color: Color(0xFF14A38B), tint: Color(0xFFE0F6F1)),
  Specialty(id: 'ent', name: 'ENT', icon: 'ear', color: Color(0xFFFF6B4A), tint: Color(0xFFFFEDE8)),
  Specialty(id: 'dental', name: 'Dentist', icon: 'smile', color: Color(0xFF0EA5E9), tint: Color(0xFFE0F3FC)),
  Specialty(id: 'endo', name: 'Diabetes', icon: 'droplets', color: Color(0xFFEF6C00), tint: Color(0xFFFFEEDD)),
  Specialty(id: 'pulmo', name: 'Pulmonologist', icon: 'activity', color: Color(0xFF16A34A), tint: Color(0xFFE1F6E8)),
];

Specialty specialtyById(String id) => mockSpecialties.firstWhere((s) => s.id == id, orElse: () => mockSpecialties.first);
