import '../models/monster.dart';

class MonsterMapper {
  /// Convierte JSON de la API 5e al modelo Monster Old School
  static Monster fromDndApi(Map<String, dynamic> json, String? imagePath) {
    return Monster(
      id: json["index"],
      name: json["name"],
      edition: "5e SRD",
      type: json["type"],
      size: json["size"],
      hp: json["hit_points"] ?? 0,
      ac: json["armor_class"] is List 
          ? json["armor_class"].first["value"] 
          : json["armor_class"],
      description: _buildDescription(json),
      abilities: _buildAbilities(json),
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
  }

  static String _buildDescription(Map<String, dynamic> json) {
    final buffer = StringBuffer();

    buffer.writeln("⚔️ Descripción automática (API 5e):");
    buffer.writeln("Tipo: ${json["type"]}");
    buffer.writeln("Tamaño: ${json["size"]}");
    buffer.writeln("Alineamiento: ${json["alignment"]}");
    buffer.writeln("");

    buffer.writeln("📘 Estadísticas:");
    buffer.writeln("HP: ${json["hit_points"]}");
    buffer.writeln("Velocidad: ${json["speed"]}");
    buffer.writeln("");

    return buffer.toString();
  }

  static String _buildAbilities(Map<String, dynamic> json) {
    final buffer = StringBuffer();

    if (json["special_abilities"] is List) {
      for (var ability in json["special_abilities"]) {
        buffer.writeln("• ${ability["name"]}: ${ability["desc"]}");
      }
    }

    if (json["actions"] is List) {
      buffer.writeln("\n🗡️ Acciones:");
      for (var action in json["actions"]) {
        buffer.writeln("• ${action["name"]}: ${action["desc"]}");
      }
    }

    return buffer.toString();
  }
}
