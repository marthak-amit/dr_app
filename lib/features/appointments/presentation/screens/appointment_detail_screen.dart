import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('AppointmentDetailScreen')), body: const Center(child: Text('TODO')));
}
