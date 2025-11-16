// lib/models/race.dart
import 'package:flutter/material.dart';

class Race {
  final String id;
  final String name;
  final String edition;
  final Map<String, int> abilityMods;
  final List<String> specialAbilities;
  final String description;
  final Color color;
  final IconData icon;
  final String? imageUrl;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  Race({
    required this.id,
    required this.name,
    required this.edition,
    required this.abilityMods,
    required this.specialAbilities,
    required this.description,
    required this.color,
    required this.icon,
    this.imageUrl,
    this.imagePath,
    this.isFavorite = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'edition': edition,
      'ability_adjustments': abilityMods.entries
          .map((e) => '${e.key}:${e.value}')
          .join(','),
      'special_abilities': specialAbilities.join('|'),
      'description': description,
      'image_url': imageUrl,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static Race fromMap(Map<String, dynamic> map) {
    final mods = <String, int>{};
    if (map['ability_adjustments'] != null) {
      final parts = (map['ability_adjustments'] as String).split(',');
      for (var part in parts) {
        final kv = part.split(':');
        if (kv.length == 2) {
          mods[kv[0]] = int.tryParse(kv[1]) ?? 0;
        }
      }
    }

    final abilities = <String>[];
    if (map['special_abilities'] != null) {
      abilities.addAll((map['special_abilities'] as String).split('|'));
    }

    return Race(
      id: map['id'],
      name: map['name'],
      edition: map['edition'],
      abilityMods: mods,
      specialAbilities: abilities,
      description: map['description'] ?? '',
      color: _parseColor(map['color'] ?? 'brown'),
      icon: _parseIcon(map['icon'] ?? 'person'),
      imageUrl: map['image_url'],
      imagePath: map['image_path'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  static Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      default: return Colors.brown;
    }
  }

  static IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'shield': return Icons.shield;
      case 'auto_awesome': return Icons.auto_awesome;
      case 'groups': return Icons.groups;
      case 'backpack': return Icons.backpack;
      default: return Icons.person;
    }
  }

  // === GET SAMPLE ===
  static List<Race> getSample() {
    return [
      Race(
        id: 'human',
        name: 'Humano',
        edition: '5e',
        abilityMods: {'FUE': 1, 'DES': 1, 'CON': 1, 'INT': 1, 'SAB': 1, 'CAR': 1},
        specialAbilities: ['Versátil', 'Idiomas adicionales'],
        description: 'Los humanos son adaptables, ambiciosos y versátiles.',
        color: Colors.brown,
        icon: Icons.person,
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      Race(
        id: 'elf',
        name: 'Elfo',
        edition: '5e',
        abilityMods: {'DES': 2},
        specialAbilities: ['Visión en la oscuridad', 'Percepción aguda', 'Entrenamiento élfico'],
        description: 'Elegantes y longevos, con afinidad por la magia.',
        color: Colors.green,
        icon: Icons.auto_awesome,
        isFavorite: true,
        createdAt: DateTime.now(),
      ),
      Race(
        id: 'dwarf',
        name: 'Enano',
        edition: '5e',
        abilityMods: {'CON': 2},
        specialAbilities: ['Resistencia enana', 'Visión en la oscuridad', 'Entrenamiento con herramientas'],
        description: 'Fuertes, resistentes y hábiles artesanos.',
        color: Colors.orange,
        icon: Icons.engineering,
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}