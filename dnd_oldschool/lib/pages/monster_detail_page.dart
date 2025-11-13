import 'package:flutter/material.dart';
import '../models/monster.dart';
import 'dart:io';

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
            // IMAGEN LOCAL
            if (monster.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(monster.imagePath!),
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/default_image.png',
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              )
            else
              Image.asset(
                'assets/default_image.png',
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