import 'package:flutter/material.dart';

class SpellDetailPage extends StatelessWidget {
  const SpellDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spell Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Add spell details widgets here
            const Text('Spell Name'),
            const SizedBox(height: 8),
            const Text('Level:'),
            const SizedBox(height: 8),
            const Text('School:'),
            const SizedBox(height: 8),
            const Text('Casting Time:'),
            const SizedBox(height: 8),
            const Text('Range:'),
            const SizedBox(height: 8),
            const Text('Components:'),
            const SizedBox(height: 8),
            const Text('Duration:'),
            const SizedBox(height: 16),
            const Text('Description:'),
          ],
        ),
      ),
    );
  }
}