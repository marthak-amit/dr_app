import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('OtpScreen')), body: const Center(child: Text('TODO')));
}
