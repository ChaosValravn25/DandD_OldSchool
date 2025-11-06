import 'package:flutter/material.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Classes'),
        backgroundColor: Colors.red[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // TODO: Add class cards or list items here
        ],
      ),
    );
  }
}