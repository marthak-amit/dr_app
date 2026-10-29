import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.doctorId, this.type, this.rescheduleId});
  final String doctorId;
  final String? type;
  final String? rescheduleId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('BookingScreen')), body: const Center(child: Text('TODO')));
}
