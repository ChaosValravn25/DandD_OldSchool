// lib/models/character_class.dart
import 'package:flutter/material.dart';
class CharacterClass {
  final String id;
  final String name;
  final String edition;
  final String hitDie;
  final String primeRequisite;
  final String allowedWeapons;
  final String allowedArmor;
  final String description;
  final List<String> abilities;
  final Color color;     // ← AÑADIDO
  final IconData icon;   // ← AÑADIDO
  final String? imageUrl;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  CharacterClass({
    required this.id,
    required this.name,
    required this.edition,
    required this.hitDie,
    required this.primeRequisite,
    required this.allowedWeapons,
    required this.allowedArmor,
    required this.description,
    required this.abilities,
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
      'hit_die': hitDie,
      'prime_requisite': primeRequisite,
      'allowed_weapons': allowedWeapons,
      'allowed_armor': allowedArmor,
      'description': description,
      'abilities': abilities.join('|'),
      'color': _colorToString(color),
      'icon': _iconToString(icon),
      'image_url': imageUrl,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static CharacterClass fromMap(Map<String, dynamic> map) {
    return CharacterClass(
      id: map['id'],
      name: map['name'],
      edition: map['edition'],
      hitDie: map['hit_die'] ?? '—',
      primeRequisite: map['prime_requisite'] ?? '—',
      allowedWeapons: map['allowed_weapons'] ?? '—',
      allowedArmor: map['allowed_armor'] ?? '—',
      description: map['description'] ?? '',
      abilities: (map['abilities'] as String?)?.split('|') ?? [],
      color: _parseColor(map['color'] ?? 'red'),
      icon: _parseIcon(map['icon'] ?? 'shield'),
      imageUrl: map['image_url'],
      imagePath: map['image_path'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  // === AGREGAR EN CharacterClass ===
factory CharacterClass.fromJson(Map<String, dynamic> json, String? localImage) {
  final abilities = <String>[];
  if (json['proficiencies'] != null) {
    abilities.addAll((json['proficiencies'] as List).map((p) => p['name'] as String));
  }
  if (json['saving_throws'] != null) {
    abilities.addAll((json['saving_throws'] as List).map((s) => 'Salvación: ${s['name']}'));
  }

  return CharacterClass(
    id: json['index'],
    name: json['name'],
    edition: '5e',
    hitDie: json['hit_die'].toString(),
    primeRequisite: '—',
    allowedWeapons: 'Varía',
    allowedArmor: 'Varía',
    description: 'Clase de D&D 5e importada desde API.',
    abilities: abilities,
    color: _getRandomColor(),
    icon: _getRandomIcon(),
    imagePath: localImage,
    createdAt: DateTime.now(),
  );
}

static Color _getRandomColor() {
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.teal];
  return colors[DateTime.now().millisecond % colors.length];
}

static IconData _getRandomIcon() {
  final icons = [
    Icons.shield,
    Icons.auto_awesome,
    Icons.sports_martial_arts,
    Icons.psychology,
    Icons.whatshot,
    Icons.healing,
  ];
  return icons[DateTime.now().millisecond % icons.length];
}

  static Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      default: return Colors.red;
    }
  }

  static IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'shield': return Icons.shield;
      case 'auto_awesome': return Icons.auto_awesome;
      case 'sports_martial_arts': return Icons.sports_martial_arts;
      default: return Icons.shield;
    }
  }

  static String _colorToString(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.purple) return 'purple';
    return 'red';
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.shield) return 'shield';
    if (icon == Icons.auto_awesome) return 'auto_awesome';
    if (icon == Icons.sports_martial_arts) return 'sports_martial_arts';
    return 'shield';
  }

  // === GET SAMPLE ===
  static List<CharacterClass> getSample() {
    return [
      CharacterClass(
        id: 'fighter',
        name: 'Guerrero',
        edition: '5e',
        hitDie: '1d10',
        primeRequisite: 'Fuerza',
        allowedWeapons: 'Todas',
        allowedArmor: 'Todas',
        description: 'Un maestro del combate y las armas.',
        abilities: ['Estilo de Combate', 'Segundo Aliento', 'Oleada de Acción'],
        color: Colors.red,
        icon: Icons.shield,
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      CharacterClass(
        id: 'wizard',
        name: 'Mago',
        edition: '5e',
        hitDie: '1d6',
        primeRequisite: 'Inteligencia',
        allowedWeapons: 'Daga, bastón',
        allowedArmor: 'Ninguna',
        description: 'Un lanzador de hechizos arcano.',
        abilities: ['Lanzamiento de Hechizos', 'Recuperación Arcana'],
        color: Colors.purple,
        icon: Icons.auto_awesome,
        isFavorite: true,
        createdAt: DateTime.now(),
      ),
    ];
  }
}