class Spell {
  final String name;
  final String level;
  final String school;
  final String castingTime;
  final String range;
  final String components;
  final String duration;
  final String description;

  Spell({
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.duration,
    required this.description,
  });

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      school: json['school'] ?? '',
      castingTime: json['castingTime'] ?? '',
      range: json['range'] ?? '',
      components: json['components'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'school': school,
      'castingTime': castingTime,
      'range': range,
      'components': components,
      'duration': duration,
      'description': description,
    };
  }
}