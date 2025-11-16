// lib/models/spell.dart
class Spell {
  final String id;
  final String name;
  final String edition;
  final int level;
  final String school;
  final String castingTime;
  final String spellRange;
  final String components;
  final String duration;
  final String description;
  final bool isFavorite;
  final DateTime? createdAt;
  final String? imageUrl;
  final String? imagePath;

  Spell({
    required this.id,
    required this.name,
    required this.edition,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.spellRange,
    required this.components,
    required this.duration,
    required this.description,
    this.isFavorite = false,
    this.createdAt,
    this.imageUrl,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'edition': edition,
      'level': level,
      'school': school,
      'casting_time': castingTime,
      'spell_range': spellRange,
      'components': components,
      'duration': duration,
      'description': description,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'image_url': imageUrl,
      'image_path': imagePath,
    };
  }

  factory Spell.fromMap(Map<String, dynamic> map) {
    return Spell(
      id: map['id'],
      name: map['name'],
      edition: map['edition'],
      level: map['level'],
      school: map['school'],
      castingTime: map['casting_time'],
      spellRange: map['spell_range'],
      components: map['components'],
      duration: map['duration'],
      description: map['description'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      imageUrl: map['image_url'],
      imagePath: map['image_path'],
    );
  }

  // === NUEVO: fromJson para API ===
  factory Spell.fromJson(Map<String, dynamic> json, String? localImage) {
    return Spell(
      id: json['index'],
      name: json['name'],
      edition: '5e',
      level: json['level'] ?? 0,
      school: json['school']?['name'] ?? '',
      castingTime: json['casting_time'] ?? '',
      spellRange: json['range'] ?? '',
      components: (json['components'] as List?)?.join(', ') ?? '',
      duration: json['duration'] ?? '',
      description: (json['desc'] as List?)?.join('\n') ?? '',
      imagePath: localImage,
      createdAt: DateTime.now(),
    );
  }


  static List<Spell> getSample() {
  return [
    Spell(
      id: 'fireball',
      name: 'Bola de Fuego',
      edition: '5e', // ← AÑADIDO
      level: 3,
      school: 'Evocación',
      castingTime: '1 acción',
      spellRange: '150 pies',
      components: 'V, S, M (guano de murciélago y azufre)',
      duration: 'Instantánea',
      description: 'Una raya brillante de fuego sale de tu dedo...',
      imageUrl: null,
      imagePath: null,
      isFavorite: false,
      createdAt: DateTime.now(),

    ),
    Spell(
      id: 'magic-missile',
      name: 'Proyectil Mágico',
      edition: '5e', // ← AÑADIDO
      level: 1,
      school: 'Evocación',
      castingTime: '1 acción',
      spellRange: '120 pies',
      components: 'V, S',
      duration: 'Instantánea',
      description: 'Creas tres dardos brillantes...',
      imageUrl: null,
      imagePath: null,
      isFavorite: true,
      createdAt: DateTime.now(),
    ),
  ];
}

 
  
}