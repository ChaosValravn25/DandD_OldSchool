// lib/services/share_service.dart
import 'package:share_plus/share_plus.dart';
import '../models/monster.dart';

/// Servicio para compartir contenido usando share_plus
class ShareService {
  /// Comparte texto simple
  static Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      throw Exception('Error al compartir: $e');
    }
  }

  /// Comparte la información de un monstruo formateada
  static Future<void> shareMonster(Monster monster) async {
    final text = _formatMonsterText(monster);
    await shareText(
      text: text,
      subject: 'D&D Old School - ${monster.name}',
    );
  }

  /// Comparte múltiples monstruos (lista)
  static Future<void> shareMonsterList(List<Monster> monsters) async {
    final buffer = StringBuffer();
    buffer.writeln('🐉 D&D OLD SCHOOL - BESTIARIO 🐉\n');
    buffer.writeln('Total de monstruos: ${monsters.length}\n');
    
    for (var monster in monsters) {
      buffer.writeln('─────────────────────');
      buffer.writeln('📛 ${monster.name}');
      buffer.writeln('📚 Edición: ${monster.edition}');
      if (monster.type != null) buffer.writeln('🏷️ Tipo: ${monster.type}');
      buffer.writeln('❤️ HP: ${monster.hp}');
      if (monster.ac != null) buffer.writeln('🛡️ AC: ${monster.ac}');
      buffer.writeln('');
    }
    
    buffer.writeln('─────────────────────');
    buffer.writeln('\nCompartido desde D&D Old School Compendium');
    
    await shareText(
      text: buffer.toString(),
      subject: 'D&D Old School - Mi Bestiario',
    );
  }

  /// Comparte solo los favoritos
  static Future<void> shareFavorites(List<Monster> favorites) async {
    final buffer = StringBuffer();
    buffer.writeln('⭐ MIS MONSTRUOS FAVORITOS ⭐\n');
    buffer.writeln('Total de favoritos: ${favorites.length}\n');
    
    for (var monster in favorites) {
      buffer.writeln('🐉 ${monster.name} (${monster.edition})');
      buffer.writeln('   HP: ${monster.hp}${monster.ac != null ? ' | AC: ${monster.ac}' : ''}');
      buffer.writeln('');
    }
    
    buffer.writeln('Compartido desde D&D Old School Compendium');
    
    await shareText(
      text: buffer.toString(),
      subject: 'Mis Monstruos Favoritos de D&D',
    );
  }

  /// Comparte estadísticas del bestiario
  static Future<void> shareStatistics(Map<String, int> stats, int totalMonsters, int favoriteCount) async {
    final buffer = StringBuffer();
    buffer.writeln('📊 ESTADÍSTICAS DEL BESTIARIO 📊\n');
    buffer.writeln('Total de monstruos: $totalMonsters');
    buffer.writeln('Monstruos favoritos: $favoriteCount\n');
    buffer.writeln('Por edición:');
    
    stats.forEach((edition, count) {
      buffer.writeln('  • $edition: $count monstruo(s)');
    });
    
    buffer.writeln('\nCompartido desde D&D Old School Compendium');
    
    await shareText(
      text: buffer.toString(),
      subject: 'Estadísticas de mi Bestiario D&D',
    );
  }

  /// Comparte información de una edición
  static Future<void> shareEdition(String edition, List<Monster> monsters) async {
    final buffer = StringBuffer();
    buffer.writeln('📚 D&D $edition 📚\n');
    buffer.writeln('Monstruos de esta edición: ${monsters.length}\n');
    
    for (var monster in monsters) {
      buffer.writeln('• ${monster.name} (HP: ${monster.hp}${monster.ac != null ? ', AC: ${monster.ac}' : ''})');
    }
    
    buffer.writeln('\nCompartido desde D&D Old School Compendium');
    
    await shareText(
      text: buffer.toString(),
      subject: 'D&D $edition - Monstruos',
    );
  }

  /// Comparte comparativa entre ediciones
  static Future<void> shareComparison(String edition1, String edition2, List<Monster> monsters1, List<Monster> monsters2) async {
    final buffer = StringBuffer();
    buffer.writeln('⚔️ COMPARATIVA DE EDICIONES ⚔️\n');
    buffer.writeln('$edition1 vs $edition2\n');
    buffer.writeln('$edition1: ${monsters1.length} monstruo(s)');
    buffer.writeln('$edition2: ${monsters2.length} monstruo(s)\n');
    buffer.writeln('Compartido desde D&D Old School Compendium');
    
    await shareText(
      text: buffer.toString(),
      subject: 'Comparativa D&D: $edition1 vs $edition2',
    );
  }

  /// Formatea la información de un monstruo para compartir
  static String _formatMonsterText(Monster monster) {
    final buffer = StringBuffer();
    
    buffer.writeln('🐉 ${monster.name} 🐉\n');
    buffer.writeln('═══════════════════════\n');
    
    // Información básica
    buffer.writeln('📚 Edición: ${monster.edition}');
    if (monster.type != null) buffer.writeln('🏷️ Tipo: ${monster.type}');
    if (monster.size != null) buffer.writeln('📏 Tamaño: ${monster.size}');
    buffer.writeln('');
    
    // Estadísticas de combate
    buffer.writeln('⚔️ ESTADÍSTICAS');
    buffer.writeln('❤️ Puntos de Vida (HP): ${monster.hp}');
    if (monster.ac != null) buffer.writeln('🛡️ Clase de Armadura (AC): ${monster.ac}');
    buffer.writeln('');
    
    // Descripción
    buffer.writeln('📖 DESCRIPCIÓN');
    buffer.writeln(monster.description);
    buffer.writeln('');
    
    // Habilidades
    if (monster.abilities != null && monster.abilities!.isNotEmpty) {
      buffer.writeln('⚡ HABILIDADES ESPECIALES');
      buffer.writeln(monster.abilities);
      buffer.writeln('');
    }
    
    // Favorito
    if (monster.isFavorite) {
      buffer.writeln('⭐ Marcado como favorito');
      buffer.writeln('');
    }
    
    buffer.writeln('═══════════════════════');
    buffer.writeln('Compartido desde D&D Old School Compendium');
    
    return buffer.toString();
  }

  /// Comparte con opciones adicionales (ejemplo avanzado)
  static Future<ShareResult?> shareWithOptions({
    required String text,
    String? subject,
    List<String>? files,
  }) async {
    try {
      if (files != null && files.isNotEmpty) {
        // Si hay archivos, usa shareXFiles
        final xFiles = files.map((path) => XFile(path)).toList();
        return await Share.shareXFiles(
          xFiles,
          text: text,
          subject: subject,
        );
      } else {
        // Solo texto
        return await Share.share(
          text,
          subject: subject,
        );
      }
    } catch (e) {
      throw Exception('Error al compartir con opciones: $e');
    }
  }

  /// Verifica si el dispositivo puede compartir
  static bool get canShare => true; // share_plus siempre está disponible en móviles
}