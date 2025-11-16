/// Modelo de datos para monstruos de D&D Old School
class Monster {
  final String id;
  final String name;
  final String edition;
  final String? type;
  final String? size;
  final int hp;
  final int? ac;
  final String description;
  final String? abilities;
  final String? imagePath;
  final bool isFavorite;
  final DateTime? createdAt;
  final String? imageUrl;

  Monster({
    required this.id,
    required this.name,
    required this.edition,
    this.type,
    this.size,
    required this.hp,
    this.ac,
    required this.description,
    this.abilities,
    this.imagePath,
    this.isFavorite = false,
    this.createdAt,
    this.imageUrl,
  });

  /// Constructor para crear una copia con algunos campos modificados
  Monster copyWith({
    String? id,
    String? name,
    String? edition,
    String? type,
    String? size,
    int? hp,
    int? ac,
    String? description,
    String? abilities,
    String? imagePath,
    bool? isFavorite,
    DateTime? createdAt,
    String? imageUrl,
    
  }) {
    return Monster(
      id: id ?? this.id,
      name: name ?? this.name,
      edition: edition ?? this.edition,
      type: type ?? this.type,
      size: size ?? this.size,
      hp: hp ?? this.hp,
      ac: ac ?? this.ac,
      description: description ?? this.description,
      abilities: abilities ?? this.abilities,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Convierte el monstruo a un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'edition': edition,
      'type': type,
      'size': size,
      'hp': hp,
      'ac': ac,
      'description': description,
      'abilities': abilities,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'image_url': imageUrl,

    };
  }
  
  static Monster fromMap(Map<String, dynamic> map) {
  return Monster(
    id: map['id'],
    name: map['name'],
    edition: map['edition'],
    type: map['type'] ?? '',
    size: map['size'] ?? '',
    hp: map['hp'],
    ac: map['ac'],
    description: map['description'] ?? '',
    abilities: map['abilities'] ?? '',
    imagePath: map['image_path'],
    isFavorite: (map['is_favorite'] ?? 0) == 1,
    createdAt: DateTime.parse(map['created_at']),
    imageUrl: map['image_url'],
  );
}

  factory Monster.fromJson(Map<String, dynamic> json, String? localImage) {
  return Monster(
    id: json['index'],
    name: json['name'],
    edition: '5e',
    type: json['type'],
    size: json['size'],
    hp: json['hit_points'] ?? 0,
    ac: json['armor_class'] ?? 0,
    description: 'Monstruo de D&D 5e importado desde API.',
    abilities: json['special_abilities']?.map((a) => a['name']).join(', '),
    imagePath: localImage,
    createdAt: DateTime.now(),
  );
}

  /// Convierte a JSON
  Map<String, dynamic> toJson() => toMap();

  /// Crea desde JSON
  

  /// Datos de ejemplo mejorados
  static List<Monster> sample() => [
        Monster(
          id: 'm1',
          name: 'Giant Rat',
          edition: 'OD&D',
          type: 'Animal',
          size: 'Small',
          hp: 4,
          ac: 7,
          description:
              'Rata gigante, común en mazmorras antiguas. Hostil y voraz. Viaja en manadas de 5-20 individuos.',
          abilities: 'Ataque con mordisco (1d3 daño), 5% chance de enfermedad',
          imagePath: 'assets/images/Rat.png',
          isFavorite: false,
        ),
        Monster(
          id: 'm2',
          name: 'Skeleton',
          edition: 'AD&D 1e',
          type: 'Undead',
          size: 'Medium',
          hp: 8,
          ac: 7,
          description:
              'Esqueleto reanimado por magia oscura. Vulnerable a daño contundente (-2 AC vs armas contundentes). Inmune a venenos, enfermedades y efectos mentales.',
          abilities:
              'Ataque con espada o arco (1d6 daño), Inmunidad a flechas no mágicas (mitad de daño)',
          imagePath: 'assets/images/Skeleton1e.png',
          isFavorite: false,
        ),
        Monster(
          id: 'm3',
          name: 'Orc',
          edition: 'AD&D 1e',
          type: 'Humanoid',
          size: 'Medium',
          hp: 7,
          ac: 6,
          description:
              'Guerrero salvaje y brutal. Prefiere la oscuridad y sufre penalizaciones bajo la luz del sol (-1 a ataques). Viven en tribus agresivas.',
          abilities:
              'Ataque con hacha o lanza (1d8 daño), Infravisión 60 pies, -1 a ataques bajo luz solar',
          imagePath: 'assets/images/orc.png',
          isFavorite: false,
        ),
        Monster(
          id: 'm4',
          name: 'Goblin',
          edition: 'OD&D',
          type: 'Humanoid',
          size: 'Small',
          hp: 5,
          ac: 6,
          description:
              'Criatura pequeña y cobarde, pero astuta en grupo. Prefieren emboscadas y tácticas de guerrilla. Odian a los enanos.',
          abilities:
              'Ataque con daga o arco corto (1d6 daño), Infravisión 60 pies, -1 a moral bajo luz solar',
          imagePath: 'assets/images/goblin.png',
          isFavorite: false,
        ),
        Monster(
          id: 'm5',
          name: 'Gelatinous Cube',
          edition: 'AD&D 2e',
          type: 'Ooze',
          size: 'Large',
          hp: 20,
          ac: 8,
          description:
              'Cubo transparente de gelatina que llena un pasillo de 10x10 pies. Prácticamente invisible cuando está quieto. Digiere lentamente a sus víctimas.',
          abilities:
              'Parálisis al contacto (salvación vs paralización), Disuelve materia orgánica, Inmune a frío y electricidad',
          imagePath: 'assets/images/cube.png',
          isFavorite: false,
        ),
        Monster(
          id: 'm6',
          name: 'Owlbear',
          edition: '3.5e',
          type: 'Magical Beast',
          size: 'Large',
          hp: 52,
          ac: 15,
          description:
              'Híbrido monstruoso entre oso y búho. Extremadamente territorial y agresivo. Creado por magia antigua, posiblemente por algún mago loco.',
          abilities:
              '2 garras (1d6 cada una) y pico (1d8), Abrazo (2d8 adicionales si ambas garras impactan), Visión en penumbra',
          imagePath: 'assets/images/owlbear.png',
          isFavorite: false,
        ),
        Monster(
          id: 'm7',
          name: 'Beholder',
          edition: 'AD&D 1e',
          type: 'Aberration',
          size: 'Large',
          hp: 45,
          ac: 0,
          description:
              'Aberración flotante con un gran ojo central y múltiples ojos en tentáculos. Una de las criaturas más temidas de las mazmorras. Altamente inteligente y paranoico.',
          abilities:
              'Ojo central (rayo anti-magia), 10 ojos menores (diferentes efectos mágicos: desintegración, petrificación, muerte, etc.), Levitación natural',
          imagePath: 'assets/images/beholder.png',
          isFavorite: true,
        ),
        Monster(
          id: 'm8',
          name: 'Kobold',
          edition: 'OD&D',
          type: 'Humanoid',
          size: 'Small',
          hp: 3,
          ac: 7,
          description:
              'Pequeños reptilianos cobardes que compensan su debilidad con números abrumadores y trampas ingeniosas. Sirvientes de dragones cuando es posible.',
          abilities:
              'Ataque con lanza o honda (1d4 daño), Visión en penumbra, -1 a ataques bajo luz solar, +1 a ataques si superan 3:1 al enemigo',
          imagePath: 'assets/images/kobold.png',
          isFavorite: false,
        ),
      ];

  @override
  String toString() {
    return 'Monster{id: $id, name: $name, edition: $edition, hp: $hp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Monster && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}