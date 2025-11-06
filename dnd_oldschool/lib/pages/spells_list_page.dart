import 'package:flutter/material.dart';

class SpellsListPage extends StatelessWidget {
  const SpellsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells List'),
      ),
      body: ListView.builder(
        itemCount: 0, // Replace with your spells list length
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Spell Name'), // Replace with actual spell name
            subtitle: Text('Level 1'), // Replace with actual spell level
            onTap: () {
              // Handle spell selection
            },
          );
        },
      ),
    );
  }
}