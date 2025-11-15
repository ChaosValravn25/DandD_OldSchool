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
  int get syncedCount => _syncedMonsters;
  int get totalCount => _totalMonsters;

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
      print('🔍 Consultando API de D&D 5e...');
      final data = await _api.get('monsters');
      final List results = data['results'] ?? [];
      
      _totalMonsters = limit ?? results.length;
      final monstersToSync = limit != null ? results.take(limit).toList() : results;

      print('📥 Sincronizando ${monstersToSync.length} monstruos...');

      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      for (var i = 0; i < monstersToSync.length; i++) {
        try {
          final monsterRef = monstersToSync[i];
          final slug = monsterRef['index'];
          final name = monsterRef['name'] ?? slug;
          
          print('🔍 [$i/${monstersToSync.length}] Obteniendo: $name');
          
          // Obtener detalles completos
          final detail = await _api.get('monsters/$slug');
          
          // Parsear y crear monstruo
          final monster = await _parseMonster(detail);
          
          if (monster != null) {
            // Verificar si ya existe
            final existing = await _db.readMonster(monster.id);
            
            if (existing == null) {
              await _db.createMonster(monster);
              print('✅ Creado: ${monster.name}');
            } else {
              await _db.updateMonster(monster);
              print('🔄 Actualizado: ${monster.name}');
            }
            
            successCount++;
          } else {
            errorCount++;
            errors.add('Error parseando: $name');
            print('❌ Error parseando: $slug');
          }
          
          _syncedMonsters++;
          onProgress?.call(_syncedMonsters, _totalMonsters);
          
          // Pequeña pausa para no saturar la API
          await Future.delayed(const Duration(milliseconds: 300));
          
        } catch (e) {
          errorCount++;
          final name = monstersToSync[i]['name'] ?? 'desconocido';
          errors.add('$name: $e');
          print('❌ Error con monstruo: $e');
        }
      }

      _isSyncing = false;
      
      return {
        'success': true,
        'total': monstersToSync.length,
        'synced': successCount,
        'errors': errorCount,
        'errorList': errors,
        'message': 'Sincronización completada:\n✅ $successCount exitosos\n❌ $errorCount errores',
      };
      
    } catch (e) {
      _isSyncing = false;
      print('❌ Error en sincronización: $e');
      
      return {
        'success': false,
        'message': 'Error en sincronización: $e',
        'total': 0,
        'synced': 0,
        'errors': 1,
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
        try {
          localPath = await ImageDownloader.downloadAndSave(imageUrl, name);
          if (localPath != null) {
            print('  📷 Imagen guardada');
          }
        } catch (e) {
          print('  ⚠️ Error descargando imagen: $e');
        }
      }

      // Convertir edición (5e → formato compatible)
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
    
    // Alineamiento
    if (data['alignment'] != null) {
      desc.writeln('Alineamiento: ${data['alignment']}');
      desc.writeln();
    }
    
    // Descripción básica
    if (data['desc'] != null && data['desc'].toString().isNotEmpty) {
      desc.writeln(data['desc']);
      desc.writeln();
    }
    
    // Habilidades especiales
    if (data['special_abilities'] != null) {
      final abilities = data['special_abilities'] as List;
      if (abilities.isNotEmpty) {
        desc.writeln('═══ HABILIDADES ESPECIALES ═══');
        for (var sa in abilities) {
          desc.writeln('• ${sa['name']}');
          desc.writeln('  ${sa['desc']}');
          desc.writeln();
        }
      }
    }

    // Acciones legendarias
    if (data['legendary_actions'] != null) {
      final legendary = data['legendary_actions'] as List;
      if (legendary.isNotEmpty) {
        desc.writeln('═══ ACCIONES LEGENDARIAS ═══');
        for (var la in legendary) {
          desc.writeln('• ${la['name']}');
          desc.writeln('  ${la['desc']}');
          desc.writeln();
        }
      }
    }
    
    return desc.toString().trim();
  }

  /// Formatea las habilidades/acciones del monstruo
  String _formatAbilities(Map<String, dynamic> data) {
    final abilities = StringBuffer();
    
    // Atributos
    if (data['strength'] != null) {
      abilities.writeln('═══ ATRIBUTOS ═══');
      abilities.writeln('FUE: ${data['strength']} | DES: ${data['dexterity']}');
      abilities.writeln('CON: ${data['constitution']} | INT: ${data['intelligence']}');
      abilities.writeln('SAB: ${data['wisdom']} | CAR: ${data['charisma']}');
      abilities.writeln();
    }
    
    // Velocidad
    if (data['speed'] != null && data['speed'] is Map) {
      abilities.writeln('═══ VELOCIDAD ═══');
      final speed = data['speed'] as Map<String, dynamic>;
      speed.forEach((key, value) {
        abilities.writeln('$key: $value');
      });
      abilities.writeln();
    }
    
    // Acciones
    if (data['actions'] != null) {
      final actions = data['actions'] as List;
      if (actions.isNotEmpty) {
        abilities.writeln('═══ ACCIONES ═══');
        for (var action in actions) {
          abilities.writeln('• ${action['name']}');
          abilities.writeln('  ${action['desc']}');
          abilities.writeln();
        }
      }
    }
    
    // Reacciones
    if (data['reactions'] != null) {
      final reactions = data['reactions'] as List;
      if (reactions.isNotEmpty) {
        abilities.writeln('═══ REACCIONES ═══');
        for (var reaction in reactions) {
          abilities.writeln('• ${reaction['name']}');
          abilities.writeln('  ${reaction['desc']}');
          abilities.writeln();
        }
      }
    }
    
    return abilities.toString().trim();
  }

  /// Obtiene URL de imagen desde diferentes fuentes
  String? _getImageUrl(Map<String, dynamic> data) {
    // Opción 1: Si la API proporciona imagen directamente
    if (data['image'] != null) {
      return 'https://www.dnd5eapi.co${data['image']}';
    }
    
    return null; // Sin imagen por defecto
  }

  /// Capitaliza la primera letra
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Cancela la sincronización en progreso
  void cancelSync() {
    if (_isSyncing) {
      _isSyncing = false;
      print('⚠️ Sincronización cancelada por el usuario');
    }
  }

  /// Limpia la caché de sincronización
  Future<void> clearSync() async {
    try {
      final monsters = await _db.readAllMonsters();
      final apiMonsters = monsters.where((m) => m.edition.contains('5e')).toList();
      
      for (var monster in apiMonsters) {
        await _db.deleteMonster(monster.id);
      }
      
      print('🗑️ Limpiados ${apiMonsters.length} monstruos de la API');
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
        'last_sync': null, // Podrías guardar esto en SharedPreferences
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Sincroniza un solo monstruo por su slug
  Future<Monster?> syncSingleMonster(String slug) async {
    try {
      print('🔍 Obteniendo monstruo: $slug');
      final detail = await _api.get('monsters/$slug');
      final monster = await _parseMonster(detail);
      
      if (monster != null) {
        final existing = await _db.readMonster(monster.id);
        if (existing == null) {
          await _db.createMonster(monster);
        } else {
          await _db.updateMonster(monster);
        }
        print('✅ Monstruo sincronizado: ${monster.name}');
      }
      
      return monster;
    } catch (e) {
      print('❌ Error sincronizando monstruo: $e');
      return null;
    }
  }

  void dispose() {
    _api.dispose();
  }
}