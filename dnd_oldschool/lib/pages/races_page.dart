// lib/pages/races_page.dart
import 'package:flutter/material.dart';
import '../models/race.dart';

class RacesPage extends StatefulWidget {
  const RacesPage({super.key});

  @override
  State<RacesPage> createState() => _RacesPageState();
}

class _RacesPageState extends State<RacesPage> {
  late List<Race> races;

  @override
  void initState() {
    super.initState();
    races = Race.getSample();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razas'),
        backgroundColor: Colors.brown,
      ),
      body: races.isEmpty
          ? const Center(child: Text('No hay razas disponibles'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: races.length,
              itemBuilder: (context, index) {
                final race = races[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: race.color.withOpacity(0.2),
                      child: Icon(race.icon, color: race.color),
                    ),
                    title: Text(
                      race.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: race.abilityMods.isNotEmpty
                        ? Text(
                            race.abilityMods.entries
                                .map((e) => '${e.key} ${e.value > 0 ? '+' : ''}${e.value}')
                                .join(' • '),
                            style: const TextStyle(color: Colors.grey),
                          )
                        : const Text('Sin modificadores', style: TextStyle(color: Colors.grey)),
                    trailing: Icon(
                      race.isFavorite ? Icons.star : Icons.star_border,
                      color: race.isFavorite ? Colors.amber : null,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              race.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Habilidades Especiales:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            ...race.specialAbilities.map((ability) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: race.color),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ability,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
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