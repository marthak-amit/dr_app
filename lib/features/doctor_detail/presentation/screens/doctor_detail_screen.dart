import 'package:flutter/material.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctorId, this.heroSuffix = ''});
  final String doctorId;
  final String heroSuffix;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('DoctorDetailScreen')), body: const Center(child: Text('TODO')));
}
