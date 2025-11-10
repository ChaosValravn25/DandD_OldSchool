import 'package:flutter/material.dart';
import 'package:dnd_oldschool/models/spell.dart';
import 'spell_detail_page.dart';
class SpellsListPage extends StatelessWidget {
  const SpellsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spells = Spell.getSample();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hechizos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: spells.length,
        itemBuilder: (context, index) {
          final spell = spells[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${spell.level}'),
              ),
              title: Text(spell.name),
              subtitle: Text('${spell.school} • ${spell.range}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpellDetailPage(spell: spell),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}