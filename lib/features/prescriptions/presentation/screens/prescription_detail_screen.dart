import 'package:flutter/material.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  const PrescriptionDetailScreen({super.key, required this.prescriptionId});
  final String prescriptionId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('PrescriptionDetailScreen')), body: const Center(child: Text('TODO')));
}
