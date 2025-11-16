// lib/services/sync_service.dart

import 'dart:convert';
import 'dart:math' show min;
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

// === Typedef correcto ===
typedef SyncSectionFunction = Future<Map<String, dynamic>> Function({
  int? limit,
  required void Function(int current, int total) onProgress,
});

class SyncService {
  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  double progress = 0.0;

  // === MÉTODO AUXILIAR: Obtener índices ===
  Future<List<String>> _getIndexes(String section) async {
    final data = await _api.get(section);
    return (data['results'] as List<dynamic>)
        .map((e) => e['index'] as String)
        .toList();
  }

  // === 1. SINCRONIZAR MONSTRUOS ===
  Future<Map<String, dynamic>> syncMonsters({
    int? limit,
    required void Function(int current, int total) onProgress,
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
    int? limit,
    required void Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'classes',
      limit: limit,
      insert: (obj) => _db.insertClass(obj),
      fromJson: (json, img) => CharacterClass.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === 3. SINCRONIZAR RAZAS ===
  Future<Map<String, dynamic>> syncRaces({
    int? limit,
    required void Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'races',
      limit: limit,
      insert: (obj) => _db.insertRace(obj),
      fromJson: (json, img) => Race.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === 4. SINCRONIZAR HECHIZOS ===
  Future<Map<String, dynamic>> syncSpells({
    int? limit,
    required void Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'spells',
      limit: limit,
      insert: (obj) => _db.insertSpell(obj),
      fromJson: (json, img) => Spell.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === 5. SINCRONIZAR EQUIPO ===
  Future<Map<String, dynamic>> syncEquipment({
    int? limit,
    required void Function(int current, int total) onProgress,
  }) async {
    return await _syncSection(
      section: 'equipment',
      limit: limit,
      insert: (obj) => _db.insertEquipment(obj),
      fromJson: (json, img) => Equipment.fromJson(json, img),
      onProgress: onProgress,
    );
  }

  // === MÉTODO GENÉRICO PARA SINCRONIZAR ===
  Future<Map<String, dynamic>> _syncSection({
    required String section,
    int? limit,
    required Future<void> Function(dynamic) insert,
    required dynamic Function(Map<String, dynamic>, String?) fromJson,
    required void Function(int current, int total) onProgress,
  }) async {
    try {
      final indexes = await _getIndexes(section);
      final total = limit != null ? min(limit, indexes.length) : indexes.length;
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

  // === 6. SINCRONIZAR TODO (CORREGIDO) ===
  Future<Map<String, dynamic>> syncAll({
    required void Function(int current, int total) onProgress,
  }) async {
    // === Lista con tipo explícito ===
    final List<Map<String, Object>> sections = [
      {'name': 'monsters', 'sync': syncMonsters},
      {'name': 'classes', 'sync': syncClasses},
      {'name': 'races', 'sync': syncRaces},
      {'name': 'spells', 'sync': syncSpells},
      {'name': 'equipment', 'sync': syncEquipment},
    ];

    int totalItems = 0;
    int currentItem = 0;

    // === Calcular total de elementos ===
    for (final s in sections) {
      final indexes = await _getIndexes(s['name'] as String);
      totalItems += indexes.length; // ← length es int
    }

    final results = <String, Map<String, dynamic>>{};

    // === Sincronizar cada sección ===
    for (final s in sections) {
      final section = s['name'] as String;
      final SyncSectionFunction syncFn = s['sync'] as SyncSectionFunction; // ← Casteo seguro

      final result = await syncFn(
        limit: null,
        onProgress: (c, t) {
          currentItem += c; // ← c es int
          progress = currentItem / totalItems;
          onProgress(currentItem, totalItems);
        },
      );

      results[section] = result;
    }

    return {
      'success': true,
      'message': 'Sincronización completa',
      'details': results,
      'total': totalItems,
    };
  }

  // === ESTADÍSTICAS ===
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

  Future<void> clearSync() async {
    await _db.deleteApiMonsters();
  }

  void dispose() {}
}