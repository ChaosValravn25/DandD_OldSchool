import 'package:flutter/material.dart';
import '../models/monster.dart';

// MonsterDetailPage: muestra detalles completos de un monstruo específico
class MonsterDetailPage extends StatelessWidget {
  final String? id;
  final String? monsterName;

  const MonsterDetailPage({super.key, this.id, this.monsterName});

  @override
  Widget build(BuildContext context) {
    final monster = Monster.sample().firstWhere(
      (m) => m.id == id,
      orElse: () => Monster.sample().first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(monsterName ?? monster.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              monster.imagePath ?? 'assets/default_image.png', // <-- ahora usa la imagen del modelo
              width: double.infinity,
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              monster.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Edición: ${monster.edition} • HP: ${monster.hp}'),
            const SizedBox(height: 12),
            Text(monster.description),
          ],
        ),
      ),
    );
  }
}