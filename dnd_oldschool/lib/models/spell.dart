class Spell {
  final String id;
  final String name;
  final String edition;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String components;
  final String duration;
  final String description;
  final String? imageUrl;  // ← NUEVO: Para Unsplash
  final String? imagePath; // Local
  final bool isFavorite;
  final DateTime? createdAt;

  Spell({
    required this.id,
    required this.name,
    required this.edition,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.duration,
    required this.description,
    this.imageUrl,
    this.imagePath,
    this.isFavorite = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'edition': edition,
    'level': level,
    'school': school,
    'casting_time': castingTime,
    'spell_range': range,
    'components': components,
    'duration': duration,
    'description': description,
    'image_url': imageUrl,    // ← NUEVO
    'image_path': imagePath,
    'is_favorite': isFavorite ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
  };

  factory Spell.fromMap(Map<String, dynamic> map) => Spell(
    id: map['id'] as String,
    name: map['name'] as String,
    edition: map['edition'] as String,
    level: map['level'] as int? ?? 0,
    school: map['school'] as String? ?? '',
    castingTime: map['casting_time'] as String? ?? '',
    range: map['spell_range'] as String? ?? '',
    components: map['components'] as String? ?? '',
    duration: map['duration'] as String? ?? '',
    description: map['description'] as String? ?? '',
    imageUrl: map['image_url'] as String?,
    imagePath: map['image_path'] as String?,
    isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
  );

  static List<Spell> getSample() {
  return [
    Spell(
      id: 'fireball',
      name: 'Bola de Fuego',
      edition: '5e', // ← AÑADIDO
      level: 3,
      school: 'Evocación',
      castingTime: '1 acción',
      range: '150 pies',
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
      range: '120 pies',
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