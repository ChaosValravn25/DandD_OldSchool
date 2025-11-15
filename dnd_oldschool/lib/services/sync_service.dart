// lib/services/sync_service.dart
import 'dart:convert';
import 'api_service.dart';
import 'image_downloader.dart';
import 'database_helper.dart';
import '../models/monster.dart';

class SyncService {
  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _isSyncing = false;
  int _totalMonsters = 0;
  int _syncedMonsters = 0;

  bool get isSyncing => _isSyncing;
  double get progress => _totalMonsters > 0 ? _syncedMonsters / _totalMonsters : 0.0;

  /// Sincroniza monstruos desde la API de D&D 5e
  Future<Map<String, dynamic>> syncMonsters({
    int? limit,
    Function(int current, int total)? onProgress,
  }) async {
    if (_isSyncing) {
      return {
        'success': false,
        'message': 'Ya hay una sincronización en progreso',
      };
    }

    _isSyncing = true;
    _syncedMonsters = 0;
    
    try {
      // Obtener lista de monstruos
      final data = await _api.get('monsters');
      final List results = data['results'] ?? [];
      
      _totalMonsters = limit ?? results.length;
      final monstersToSync = limit != null ? results.take(limit).toList() : results;

      print('📥 Sincronizando ${monstersToSync.length} monstruos...');

      int successCount = 0;
      int errorCount = 0;

      for (var i = 0; i < monstersToSync.length; i++) {
        try {
          final monsterRef = monstersToSync[i];
          final slug = monsterRef['index'];
          
          print('🔍 Obteniendo detalles de: $slug');
          
          // Obtener detalles completos
          final detail = await _api.get('monsters/$slug');
          
          // Parsear y crear monstruo
          final monster = await _parseMonster(detail);
          
          if (monster != null) {
            // Verificar si ya existe
            final existing = await _db.readMonster(monster.id);
            
            if (existing == null) {
              await _db.createMonster(monster);
              print('✅ Monstruo creado: ${monster.name}');
            } else {
              await _db.updateMonster(monster);
              print('🔄 Monstruo actualizado: ${monster.name}');
            }
            
            successCount++;
          } else {
            errorCount++;
            print('❌ Error parseando: $slug');
          }
          
          _syncedMonsters++;
          onProgress?.call(_syncedMonsters, _totalMonsters);
          
          // Pequeña pausa para no saturar la API
          await Future.delayed(const Duration(milliseconds: 200));
          
        } catch (e) {
          errorCount++;
          print('❌ Error con monstruo: $e');
        }
      }

      _isSyncing = false;
      
      return {
        'success': true,
        'total': monstersToSync.length,
        'synced': successCount,
        'errors': errorCount,
        'message': 'Sincronización completada: $successCount éxitos, $errorCount errores',
      };
      
    } catch (e) {
      _isSyncing = false;
      print('❌ Error en sincronización: $e');
      
      return {
        'success': false,
        'message': 'Error en sincronización: $e',
      };
    }
  }

  /// Parsea los datos de la API a un modelo Monster
  Future<Monster?> _parseMonster(Map<String, dynamic> data) async {
    try {
      final name = data['name'] ?? 'Unknown';
      final id = data['index'] ?? name.toLowerCase().replaceAll(' ', '-');

      // Buscar imagen
      final imageUrl = _getImageUrl(data);
      String? localPath;
      
      if (imageUrl != null) {
        print('📷 Descargando imagen de: $name');
        localPath = await ImageDownloader.downloadAndSave(imageUrl, name);
        if (localPath != null) {
          print('✅ Imagen guardada: $localPath');
        } else {
          print('⚠️ No se pudo descargar imagen para: $name');
        }
      }

      // Convertir edición (5e → formato Old School para mostrar)
      final edition = '5e (2014)';

      return Monster(
        id: id,
        name: name,
        edition: edition,
        type: _capitalizeFirst(data['type'] ?? 'Unknown'),
        size: _capitalizeFirst(data['size'] ?? 'Medium'),
        hp: data['hit_points'] ?? 0,
        ac: _extractAC(data['armor_class']),
        description: _formatDesc(data),
        abilities: _formatAbilities(data),
        imagePath: localPath,
        isFavorite: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parseando monstruo: $e');
      return null;
    }
  }

  /// Extrae el AC del formato de la API
  int? _extractAC(dynamic armorClass) {
    if (armorClass == null) return null;
    
    if (armorClass is int) return armorClass;
    
    if (armorClass is List && armorClass.isNotEmpty) {
      final first = armorClass[0];
      if (first is Map && first.containsKey('value')) {
        return first['value'] as int?;
      }
    }
    
    return null;
  }

  /// Formatea la descripción del monstruo
  String _formatDesc(Map<String, dynamic> data) {
    final desc = StringBuffer();
    
    // Descripción básica
    if (data['desc'] != null && data['desc'].toString().isNotEmpty) {
      desc.writeln(data['desc']);
      desc.writeln();
    }
    
    // Habilidades especiales
    if (data['special_abilities'] != null) {
      final abilities = data['special_abilities'] as List;
      if (abilities.isNotEmpty) {
        desc.writeln('Habilidades Especiales:');
        for (var sa in abilities) {
          desc.writeln('• ${sa['name']}: ${sa['desc']}');
        }
      }
    }
    
    return desc.toString().trim();
  }

  /// Formatea las habilidades/acciones del monstruo
  String _formatAbilities(Map<String, dynamic> data) {
    final abilities = StringBuffer();
    
    // Acciones
    if (data['actions'] != null) {
      final actions = data['actions'] as List;
      if (actions.isNotEmpty) {
        for (var action in actions) {
          abilities.writeln('${action['name']}: ${action['desc']}');
          abilities.writeln();
        }
      }
    }
    
    // Reacciones
    if (data['reactions'] != null) {
      final reactions = data['reactions'] as List;
      if (reactions.isNotEmpty) {
        abilities.writeln('Reacciones:');
        for (var reaction in reactions) {
          abilities.writeln('${reaction['name']}: ${reaction['desc']}');
        }
      }
    }
    
    return abilities.toString().trim();
  }

  /// Obtiene URL de imagen desde diferentes fuentes
  String? _getImageUrl(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    
    // Opción 1: Si la API proporciona imagen directamente
    if (data['image'] != null) {
      return 'https://www.dnd5eapi.co${data['image']}';
    }
    
    // Opción 2: D&D Beyond (las mejores imágenes)
    // Nota: Estas URLs son ejemplos, necesitas verificar que funcionen
    final slug = data['index'] ?? name.toLowerCase().replaceAll(' ', '-');
    
    // Intenta varias fuentes
    final sources = [
      // D&D Beyond avatars
      'https://www.dndbeyond.com/avatars/thumbnails/monsters/$slug.png',
      // Roll20 tokens
      'https://roll20.net/compendium/dnd5e/$slug/avatar.png',
      // Unsplash como último recurso (imágenes genéricas)
      'https://source.unsplash.com/400x400/?dragon,fantasy,$slug',
    ];
    
    // Por ahora retorna la primera, pero podrías validar cuál funciona
    return sources[0];
  }

  /// Capitaliza la primera letra
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Limpia la caché de sincronización
  Future<void> clearSync() async {
    try {
      // Aquí podrías eliminar monstruos sincronizados si quieres
      print('🗑️ Limpieza de sincronización completada');
    } catch (e) {
      print('❌ Error limpiando sincronización: $e');
    }
  }

  /// Obtiene estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final monsters = await _db.readAllMonsters();
      final syncedMonsters = monsters.where((m) => m.edition.contains('5e')).length;
      
      return {
        'total_monsters': monsters.length,
        'synced_from_api': syncedMonsters,
        'local_only': monsters.length - syncedMonsters,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}