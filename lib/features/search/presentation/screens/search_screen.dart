import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.specialtyId, this.autofocus = false});
  final String? specialtyId;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('SearchScreen')), body: const Center(child: Text('TODO')));
}
