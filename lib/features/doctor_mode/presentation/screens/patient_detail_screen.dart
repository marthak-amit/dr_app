import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('PatientDetailScreen')), body: const Center(child: Text('TODO')));
}
