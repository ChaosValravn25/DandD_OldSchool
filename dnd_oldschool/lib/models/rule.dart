// lib/models/rule.dart
// Estructura básica para un modelo "Rule" (regla) en la app DnD OldSchool.

class Rule {
  final String id;
  final String title;
  final String description;
  final String? source; // libro, suplemento, nota, etc.
  final List<String> tags;
  final DateTime createdAt;
  final bool isFavorite;

  Rule({
    required this.id,
    required this.title,
    required this.description,
    this.source,
    List<String>? tags,
    DateTime? createdAt,
    this.isFavorite = false,
  })  : tags = tags ?? const [],
        createdAt = createdAt ?? DateTime.now();

  /// Crea una regla con un id generado simple (timestamp).
  factory Rule.create({
    required String title,
    required String description,
    String? source,
    List<String>? tags,
    bool isFavorite = false,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return Rule(
      id: id,
      title: title,
      description: description,
      source: source,
      tags: tags,
      createdAt: DateTime.now(),
      isFavorite: isFavorite,
    );
  }

  /// Convierte desde un Map (por ejemplo, JSON decode).
  factory Rule.fromMap(Map<String, dynamic> map) {
    return Rule(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      source: map['source'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  /// Convierte a Map (para persistencia / JSON encode).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source': source,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  /// Copia inmutable con modificaciones.
  Rule copyWith({
    String? id,
    String? title,
    String? description,
    String? source,
    List<String>? tags,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Rule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      tags: tags ?? List<String>.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'Rule(id: $id, title: $title, source: $source, tags: $tags, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rule &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.source == source &&
        _listEquals(other.tags, tags) &&
        other.createdAt == createdAt &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        (source?.hashCode ?? 0) ^
        tags.join('|').hashCode ^
        createdAt.hashCode ^
        isFavorite.hashCode;
  }

  // Pequeña utilidad para comparar listas de strings.
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}