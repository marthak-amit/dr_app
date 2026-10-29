import 'package:flutter/material.dart';

class RecordFolderScreen extends StatelessWidget {
  const RecordFolderScreen({super.key, required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('RecordFolderScreen')), body: const Center(child: Text('TODO')));
}
