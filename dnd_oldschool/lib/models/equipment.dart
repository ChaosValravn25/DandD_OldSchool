// lib/models/equipment.dart
import 'package:flutter/material.dart';

class Equipment {
  final String id;
  final String name;
  final String edition;
  final String type;
  final String cost;
  final String weight;
  final String? damage;
  final int? damageDice;
  final String? damageType;
  final int? acBonus;
  final String? strengthRequirement;
  final bool stealthDisadvantage;
  final String description;
  final Color? color;
  final IconData? icon;
  final String? imageUrl;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  Equipment({
    required this.id,
    required this.name,
    required this.edition,
    required this.type,
    required this.cost,
    required this.weight,
    this.damage,
    this.damageDice,
    this.damageType,
    this.acBonus,
    this.strengthRequirement,
    this.stealthDisadvantage = false,
    required this.description,
    this.color,
    this.icon,
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
      'equipment_category': type,
      'cost': cost,
      'weight': weight,
      'damage': damage,
      'damage_dice': damageDice,
      'damage_type': damageType,
      'ac_bonus': acBonus,
      'strength_requirement': strengthRequirement,
      'stealth_disadvantage': stealthDisadvantage ? 1 : 0,
      'description': description,
      'color': color != null ? _colorToString(color!) : null,
      'icon': icon != null ? _iconToString(icon!) : null,
      'image_url': imageUrl,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // === FROM MAP (SQLite) ===
  static Equipment fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'],
      name: map['name'],
      edition: map['edition'],
      type: map['equipment_category'] ?? 'Objeto',
      cost: map['cost'] ?? '—',
      weight: map['weight'] ?? '—',
      damage: map['damage'],
      damageDice: map['damage_dice'],
      damageType: map['damage_type'],
      acBonus: map['ac_bonus'],
      strengthRequirement: map['strength_requirement'],
      stealthDisadvantage: (map['stealth_disadvantage'] ?? 0) == 1,
      description: map['description'] ?? '',
      color: map['color'] != null ? _parseColor(map['color']) : null,
      icon: map['icon'] != null ? _parseIcon(map['icon']) : null,
      imageUrl: map['image_url'],
      imagePath: map['image_path'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  // === FROM JSON (API + Imagen local) ===
  factory Equipment.fromJson(Map<String, dynamic> json, String? localImage) {
    final category = json['equipment_category']?['name'] ?? 'Objeto';
    final cost = json['cost'] != null 
        ? '${json['cost']['quantity']} ${json['cost']['unit']}' 
        : '—';
    final weight = json['weight']?.toString() ?? '—';

    // === ARMAS ===
    String? damage;
    int? damageDice;
    String? damageType;
    if (json['damage'] != null) {
      final dice = json['damage']['damage_dice'] as String;
      damage = '$dice ${json['damage']['damage_type']['name']}';
      final parts = dice.split('d');
      if (parts.length == 2) {
        damageDice = int.tryParse(parts[1]);
      }
      damageType = json['damage']['damage_type']['name'];
    }

    // === ARMADURAS ===
    int? acBonus;
    String? strengthRequirement;
    bool stealthDisadvantage = false;
    if (json['armor_category'] != null) {
      acBonus = json['armor_class']?['base'];
      strengthRequirement = json['str_minimum']?.toString();
      stealthDisadvantage = json['stealth_disadvantage'] == true;
    }

    // === COLOR E ÍCONO ALEATORIO POR TIPO ===
    Color? color;
    IconData? icon;
    if (category.contains('Weapon') || category.contains('Arma')) {
      color = Colors.redAccent;
      icon = Icons.gavel;
    } else if (category.contains('Armor') || category.contains('Armadura')) {
      color = Colors.blueGrey;
      icon = Icons.security;
    } else {
      color = Colors.amber;
      icon = Icons.inventory;
    }

    return Equipment(
      id: json['index'],
      name: json['name'],
      edition: '5e',
      type: category,
      cost: cost,
      weight: weight,
      damage: damage,
      damageDice: damageDice,
      damageType: damageType,
      acBonus: acBonus,
      strengthRequirement: strengthRequirement,
      stealthDisadvantage: stealthDisadvantage,
      description: 'Equipo de D&D 5e importado desde API oficial.',
      color: color,
      icon: icon,
      imagePath: localImage,
      createdAt: DateTime.now(),
    );
  }

  // === MÉTODOS AUXILIARES ===
  static Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.redAccent;
      case 'blue': return Colors.blueGrey;
      case 'amber': return Colors.amber;
      default: return Colors.amber;
    }
  }

  static IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'gavel': return Icons.gavel;
      case 'security': return Icons.security;
      case 'inventory': return Icons.inventory;
      default: return Icons.inventory;
    }
  }

  static String _colorToString(Color color) {
    if (color == Colors.redAccent) return 'red';
    if (color == Colors.blueGrey) return 'blue';
    if (color == Colors.amber) return 'amber';
    return 'amber';
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.gavel) return 'gavel';
    if (icon == Icons.security) return 'security';
    if (icon == Icons.inventory) return 'inventory';
    return 'inventory';
  }

  // === DATOS DE EJEMPLO ===
  static List<Equipment> getSample() {
    return [
      Equipment(
        id: 'longsword',
        name: 'Espada Larga',
        edition: '5e',
        type: 'Arma Marcial',
        cost: '15 po',
        weight: '3 lb',
        damage: '1d8 cortante',
        damageDice: 8,
        damageType: 'cortante',
        description: 'Una espada versátil de una mano.',
        color: Colors.redAccent,
        icon: Icons.gavel,
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      Equipment(
        id: 'plate-armor',
        name: 'Armadura de Placas',
        edition: '5e',
        type: 'Armadura Pesada',
        cost: '1500 po',
        weight: '65 lb',
        acBonus: 18,
        strengthRequirement: '15',
        stealthDisadvantage: true,
        description: 'La mejor protección disponible.',
        color: Colors.blueGrey,
        icon: Icons.security,
        isFavorite: true,
        createdAt: DateTime.now(),
      ),
      Equipment(
        id: 'potion-healing',
        name: 'Poción de Curación',
        edition: '5e',
        type: 'Objeto Maravilloso',
        cost: '50 po',
        weight: '0.5 lb',
        description: 'Restaura 2d4+2 puntos de vida.',
        color: Colors.amber,
        icon: Icons.inventory,
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}