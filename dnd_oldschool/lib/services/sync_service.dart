// lib/services/sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dnd_oldschool/services/api_service.dart';
import 'package:dnd_oldschool/services/image_downloader.dart';
import 'package:dnd_oldschool/services/database_helper.dart';
import 'package:dnd_oldschool/models/monster.dart';
import 'package:dnd_oldschool/models/spell.dart';
import 'package:dnd_oldschool/models/character_class.dart';
import 'package:dnd_oldschool/models/race.dart';
import 'package:dnd_oldschool/models/equipment.dart';
import 'package:flutter/material.dart';

class SyncService {
  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  double progress = 0.0;

  // === MÉTODO AUXILIAR: Obtener índices ===
  Future<List<String>> _getIndexes(String section) async {
    final data = await _api.get(section);
    return (data['results'] as List).map((e) => e['index'] as String).toList();
  }

  // === 1. SINCRONIZAR MONSTRUOS (con límite opcional) ===
  Future<Map<String, dynamic>> syncMonsters({
    int? limit,
    required Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'monsters',
      limit: limit,
      insert: (obj) => _db.insertMonster(obj),
      fromJson: (json, img) => Monster.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === 2. SINCRONIZAR CLASES ===
  Future<Map<String, dynamic>> syncClasses({
    required Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'classes',
      insert: (obj) => _db.insertClass(obj),
      fromJson: (json, img) => CharacterClass.fromJson(json, img),
      onProgress: onProgress,
    );
  }
  

  // === 3. SINCRONIZAR RAZAS ===
  Future<Map<String, dynamic>> syncRaces({
    required Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'races',
      insert: (obj) => _db.insertRace(obj),
      fromJson: (json, img) => Race.fromJson(json, img),
      onProgress: onProgress,
    );
  }
  
  // === 4. SINCRONIZAR HECHIZOS ===
  Future<Map<String, dynamic>> syncSpells({
    required Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'spells',
      insert: (obj) => _db.insertSpell(obj),
      fromJson: (json, img) => Spell.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === 5. SINCRONIZAR EQUIPO ===
  Future<Map<String, dynamic>> syncEquipment({
    required Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'equipment',
      insert: (obj) => _db.insertEquipment(obj),
      fromJson: (json, img) => Equipment.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === MÉTODO GENÉRICO DE SINCRONIZACIÓN (REUTILIZABLE) ===
  Future<Map<String, dynamic>> _syncSection({
    required String section,
    int? limit,
    required Future<void> Function(dynamic) insert,
    required dynamic Function(Map<String, dynamic>, String?) fromJson,
    required Function(int current, int total) onProgress,
  }) async {
    try {
      final indexes = await _getIndexes(section);
      final total = limit != null ? limit.clamp(0, indexes.length) : indexes.length;
      final toSync = limit != null ? indexes.take(total).toList() : indexes;

      int synced = 0;
      int errors = 0;
      List<String> errorList = [];

      for (int i = 0; i < toSync.length; i++) {
        final index = toSync[i];
        try {
          final json = await _api.get('$section/$index');
          final localImage = await ImageDownloader.downloadFromMultipleSources(
            section, json['name'], json['index'],
          );
          final obj = fromJson(json, localImage);
          await insert(obj);
          synced++;
        } catch (e) {
          errors++;
          errorList.add('$index: $e');
        }
        onProgress(i + 1, toSync.length);
      }

      return {
        'success': true,
        'synced': synced,
        'errors': errors,
        'total': toSync.length,
        'message': '$section sincronizados: $synced/${toSync.length}',
        'errorList': errorList,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error en $section: $e'};
    }
  }

  // === 6. SINCRONIZAR TODO (PROGRESO GLOBAL) ===
  Future<Map<String, dynamic>> syncAll({
    required Function(int current, int total) onProgress,
  }) async {
    final sections = [
      {'name': 'monsters', 'sync': syncMonsters},
      {'name': 'classes', 'sync': syncClasses},
      {'name': 'races', 'sync': syncRaces},
      {'name': 'spells', 'sync': syncSpells},
      {'name': 'equipment', 'sync': syncEquipment},
    ];

    int totalItems = 0;
    int currentItem = 0;

    // Contar total
    for (var s in sections) {
      final indexes = await _getIndexes(s['name'] as String);
      totalItems += indexes.length;
    }

    final results = <String, Map<String, dynamic>>{};

    for (var s in sections) {
      final section = s['name'] as String;
      final syncFn = s['sync'] as Future<Map<String, dynamic>> Function({
        int? limit,
        required Function(int, int) onProgress,
      });

      final result = await syncFn(onProgress: (c, t) {
        currentItem += c;
        progress = currentItem / totalItems;
        onProgress(currentItem, totalItems);
      });

      results[section] = result;
    }

    return {
      'success': true,
      'message': 'Sincronización completa',
      'details': results,
      'total': totalItems,
    };
  }

  // === ESTADÍSTICAS DE SINCRONIZACIÓN ===
  Future<Map<String, dynamic>> getSyncStats() async {
    final totalMonsters = await _db.getMonsterCount();
    final apiMonsters = await _db.getApiMonsterCount();
    final localMonsters = totalMonsters - apiMonsters;

    return {
      'total_monsters': totalMonsters,
      'synced_from_api': apiMonsters,
      'local_only': localMonsters,
    };
  }

  // === LIMPIAR MONSTRUOS DE API ===
  Future<void> clearSync() async {
    await _db.deleteApiMonsters();
  }

  void dispose() {}
}