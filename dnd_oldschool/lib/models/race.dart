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

  // === TO MAP (SQLite) ===
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
      'color': _colorToString(color),
      'icon': _iconToString(icon),
      'image_url': imageUrl,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // === FROM MAP (SQLite) ===
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

  // === FROM JSON (API + Imagen local) ===
  factory Race.fromJson(Map<String, dynamic> json, String? localImage) {
    final mods = <String, int>{};
    if (json['ability_bonuses'] != null) {
      for (var bonus in json['ability_bonuses']) {
        final stat = bonus['ability_score']['name']
            .toString()
            .toUpperCase()
            .substring(0, 3);
        final value = bonus['bonus'] as int;
        mods[stat] = value;
      }
    }

    final abilities = <String>[];
    if (json['traits'] != null) {
      abilities.addAll((json['traits'] as List).map((t) => t['name'] as String));
    }
    if (json['starting_proficiencies'] != null) {
      abilities.addAll((json['starting_proficiencies'] as List)
          .map((p) => 'Prof: ${p['name']}'));
    }
    if (json['languages'] != null) {
      abilities.add('Idiomas: ${(json['languages'] as List).length}+');
    }

    return Race(
      id: json['index'],
      name: json['name'],
      edition: '5e',
      abilityMods: mods,
      specialAbilities: abilities,
      description: 'Raza de D&D 5e importada desde API oficial.',
      color: _getRandomColor(),
      icon: _getRandomIcon(),
      imagePath: localImage,
      createdAt: DateTime.now(),
    );
  }

  get speed => null;

  // === MÉTODOS AUXILIARES ===
  static Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  static IconData _getRandomIcon() {
    final icons = [
      Icons.person,
      Icons.auto_awesome,
      Icons.shield,
      Icons.engineering,
      Icons.groups,
      Icons.backpack,
      Icons.psychology,
      Icons.whatshot,
    ];
    return icons[DateTime.now().millisecond % icons.length];
  }

  static Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      case 'teal': return Colors.teal;
      case 'indigo': return Colors.indigo;
      default: return Colors.brown;
    }
  }

  static IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'person': return Icons.person;
      case 'auto_awesome': return Icons.auto_awesome;
      case 'shield': return Icons.shield;
      case 'engineering': return Icons.engineering;
      case 'groups': return Icons.groups;
      case 'backpack': return Icons.backpack;
      case 'psychology': return Icons.psychology;
      case 'whatshot': return Icons.whatshot;
      default: return Icons.person;
    }
  }

  static String _colorToString(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.indigo) return 'indigo';
    return 'brown';
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.person) return 'person';
    if (icon == Icons.auto_awesome) return 'auto_awesome';
    if (icon == Icons.shield) return 'shield';
    if (icon == Icons.engineering) return 'engineering';
    if (icon == Icons.groups) return 'groups';
    if (icon == Icons.backpack) return 'backpack';
    if (icon == Icons.psychology) return 'psychology';
    if (icon == Icons.whatshot) return 'whatshot';
    return 'person';
  }

  // === DATOS DE EJEMPLO ===
  static List<Race> getSample() {
    return [
      Race(
        id: 'human',
        name: 'Humano',
        edition: '5e',
        abilityMods: {'FUE': 1, 'DES': 1, 'CON': 1, 'INT': 1, 'SAB': 1, 'CAR': 1},
        specialAbilities: ['Versátil', 'Idiomas adicionales', 'Habilidad extra'],
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
        specialAbilities: [
          'Visión en la oscuridad',
          'Percepción aguda',
          'Entrenamiento élfico',
          'Trance'
        ],
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
        specialAbilities: [
          'Resistencia enana',
          'Visión en la oscuridad',
          'Entrenamiento con herramientas',
          'Resistencia al veneno'
        ],
        description: 'Fuertes, resistentes y hábiles artesanos.',
        color: Colors.orange,
        icon: Icons.engineering,
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}