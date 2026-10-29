import 'package:flutter/material.dart';

class RecordPreviewScreen extends StatelessWidget {
  const RecordPreviewScreen({super.key, required this.recordId});
  final String recordId;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('RecordPreviewScreen')), body: const Center(child: Text('TODO')));
}
