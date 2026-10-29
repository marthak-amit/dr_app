import 'package:flutter/material.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('BookingSuccessScreen')), body: const Center(child: Text('TODO')));
}
