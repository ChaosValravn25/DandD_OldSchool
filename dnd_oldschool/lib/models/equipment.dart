
// lib/models/equipment.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Equipment {
  final String id;
  final String name;
  final String edition;
  final String type; // ← AÑADIDO
  final String cost;
  final String weight;
  final String? damage;
  final int? damageDice;
  final String? damageType;
  final int? acBonus;
  final String? strengthRequirement;
  final bool stealthDisadvantage;
  final String description;
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
      'image_url': imageUrl,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

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
      imageUrl: map['image_url'],
      imagePath: map['image_path'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  // === GET SAMPLE ===
  static List<Equipment> getSample() {
    return [
      Equipment(
        id: 'longsword',
        name: 'Espada Larga',
        edition: '5e',
        type: 'Arma',
        cost: '15 po',
        weight: '3 lb',
        damage: '1d8 cortante',
        damageDice: 8,
        damageType: 'cortante',
        description: 'Una espada versátil de una mano.',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      Equipment(
        id: 'plate-armor',
        name: 'Armadura de Placas',
        edition: '5e',
        type: 'Armadura',
        cost: '1500 po',
        weight: '65 lb',
        acBonus: 18,
        strengthRequirement: '15',
        stealthDisadvantage: true,
        description: 'La mejor protección disponible.',
        isFavorite: true,
        createdAt: DateTime.now(),
      ),
      Equipment(
        id: 'potion-healing',
        name: 'Poción de Curación',
        edition: '5e',
        type: 'Objeto',
        cost: '50 po',
        weight: '0.5 lb',
        description: 'Restaura 2d4+2 puntos de vida.',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}