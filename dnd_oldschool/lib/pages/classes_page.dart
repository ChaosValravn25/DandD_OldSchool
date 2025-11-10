import 'package:flutter/material.dart';
import 'package:dnd_oldschool/models/character_class.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = CharacterClass.getSample();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases de Personaje'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final charClass = classes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: charClass.color.withOpacity(0.2),
                child: Icon(charClass.icon, color: charClass.color),
              ),
              title: Text(
                charClass.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Dado de Golpe: ${charClass.hitDie}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(charClass.description),
                      const SizedBox(height: 12),
                      const Text(
                        'Habilidades:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...charClass.abilities.map((ability) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check, size: 16, color: charClass.color),
                              const SizedBox(width: 8),
                              Expanded(child: Text(ability)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}