import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('VideoCallScreen')), body: const Center(child: Text('TODO')));
}
