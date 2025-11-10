import 'package:flutter/material.dart';
import '../models/race.dart';
class RacesPage extends StatefulWidget {
  const RacesPage({super.key});

  @override
  State<RacesPage> createState() => _RacesPageState();
}

class _RacesPageState extends State<RacesPage> {
  @override
  Widget build(BuildContext context) {
    final races = Race.getSample();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Razas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: races.length,
        itemBuilder: (context, index) {
          final race = races[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: race.color.withOpacity(0.2),
                child: Icon(race.icon, color: race.color),
              ),
              title: Text(
                race.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: race.abilityMods.isNotEmpty
                  ? Text(
                      race.abilityMods.entries
                          .map((e) => '${e.key} ${e.value > 0 ? '+' : ''}${e.value}')
                          .join(', '),
                    )
                  : const Text('Sin modificadores'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(race.description),
                      const SizedBox(height: 12),
                      const Text(
                        'Habilidades Especiales:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...race.specialAbilities.map((ability) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: race.color),
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