// lib/services/sync_service.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'image_downloader.dart';
import 'database_helper.dart';
import '../models/monster.dart';
import '../models/spell.dart';
import '../models/character_class.dart';
import '../models/race.dart';
import '../models/equipment.dart';

class SyncService {
  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _isSyncing = false;
  int _totalItems = 0;
  int _syncedItems = 0;

  bool get isSyncing => _isSyncing;
  double get progress => _totalItems > 0 ? _syncedItems / _totalItems : 0.0;
  int get syncedCount => _syncedItems;
  int get totalCount => _totalItems;

  // === SINCRONIZACIÓN COMPLETA ===
  Future<Map<String, dynamic>> syncAll({Function(int, int)? onProgress}) async {
    if (_isSyncing) return {'success': false, 'message': 'Sincronización en progreso'};

    _isSyncing = true;
    _totalItems = 0;
    _syncedItems = 0;

    final results = <String, Map>{};
    final List<String> sections = ['monsters', 'spells', 'classes', 'races', 'equipment'];

    try {
      for (var section in sections) {
        final data = await _api.get(section);
        _totalItems += (data['count'] ?? 0) as int;
      }

      onProgress?.call(0, _totalItems);

      for (var section in sections) {
        final result = await _syncSection(section, onProgress: (c, t) {
          _syncedItems = c;
          onProgress?.call(_syncedItems, _totalItems);
        });
        results[section] = result;
      }

      _isSyncing = false;
      return {'success': true, 'message': 'Sincronización completa', 'details': results};
    } catch (e) {
      _isSyncing = false;
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // === SINCRONIZACIÓN POR SECCIÓN ===
  Future<Map<String, dynamic>> _syncSection(
    String section, {
    int? limit,
    Function(int, int)? onProgress,
  }) async {
    int success = 0, errors = 0;
    List<String> errorList = [];

    try {
      final data = await _api.get(section);
      final List results = data['results'] ?? [];
      final itemsToSync = limit != null ? results.take(limit).toList() : results;

      for (var i = 0; i < itemsToSync.length; i++) {
        final item = itemsToSync[i];
        final slug = item['index'];
        final name = item['name'] ?? slug;

        try {
          final detail = await _api.get('$section/$slug');
          await _parseAndSave(section, detail, name, slug);
          success++;
        } catch (e) {
          errors++;
          errorList.add('$name: $e');
        }

        _syncedItems++;
        onProgress?.call(_syncedItems, _totalItems);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      errors++;
      errorList.add('Error en $section: $e');
    }

    return {'success': success, 'errors': errors, 'errorList': errorList};
  }

  // === PARSE Y GUARDAR ===
  Future<void> _parseAndSave(
    String section,
    Map<String, dynamic> data,
    String name,
    String id,
  ) async {
    try {
      final localPath = await ImageDownloader.downloadFromMultipleSources(name, id);
      final imageUrl = localPath != null ? 'file://$localPath' : null;

      switch (section) {
        case 'monsters':
          final monster = _parseMonster(data, imageUrl: imageUrl, imagePath: localPath);
          if (monster != null) {
            final existing = await _db.readMonster(monster.id);
            existing == null
                ? await _db.createMonster(monster)
                : await _db.updateMonster(monster);
          }
          break;

        case 'spells':
          final spell = _parseSpell(data, imageUrl: imageUrl, imagePath: localPath);
          final existing = await _db.readSpell(spell.id);
          existing == null
              ? await _db.createSpell(spell)
              : await _db.rawUpdate('spells', spell.toMap(), 'id = ?', [spell.id]);
          break;

        case 'classes':
          final cls = _parseClass(data, imageUrl: imageUrl, imagePath: localPath);
          final existing = await _db.readClass(cls.id);
          existing == null
              ? await _db.createClass(cls)
              : await _db.rawUpdate('character_classes', cls.toMap(), 'id = ?', [cls.id]);
          break;

        case 'races':
          final race = _parseRace(data, imageUrl: imageUrl, imagePath: localPath);
          final existing = await _db.readRace(race.id);
          existing == null
              ? await _db.createRace(race)
              : await _db.rawUpdate('races', race.toMap(), 'id = ?', [race.id]);
          break;

        case 'equipment':
          final eq = _parseEquipment(data, imageUrl: imageUrl, imagePath: localPath);
          final existing = await _db.readEquipment(eq.id);
          existing == null
              ? await _db.createEquipment(eq)
              : await _db.rawUpdate('equipment', eq.toMap(), 'id = ?', [eq.id]);
          break;
      }
    } catch (e) {
      print('Error parseando $section: $e');
    }
  }

  // === PARSERS ===

  Monster? _parseMonster(Map data, {String? imageUrl, String? imagePath}) {
    try {
      return Monster(
        id: data['index'],
        name: data['name'],
        edition: '5e',
        type: data['type'] ?? '',
        size: data['size'] ?? '',
        hp: data['hit_points'] ?? 0,
        ac: data['armor_class']?[0]?['value'] ?? 10,
        description: (data['desc'] ?? '') + '\n' + _formatActions(data),
        abilities: _formatStats(data),
        imageUrl: imageUrl,
        imagePath: imagePath,
        isFavorite: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parseando monstruo: $e');
      return null;
    }
  }

  Spell _parseSpell(Map data, {String? imageUrl, String? imagePath}) {
    return Spell(
      id: data['index'],
      name: data['name'],
      edition: '5e',
      level: data['level'] ?? 0,
      school: data['school']?['name'] ?? 'Unknown',
      castingTime: data['casting_time'] ?? '—',
      range: data['range'] ?? '—',
      components: (data['components'] as List?)?.join(', ') ?? '—',
      duration: data['duration'] ?? '—',
      description: (data['desc'] as List?)?.join('\n\n') ?? 'Sin descripción',
      imageUrl: imageUrl,
      imagePath: imagePath,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  CharacterClass _parseClass(Map data, {String? imageUrl, String? imagePath}) {
    final hitDie = data['hit_die'] ?? 10;
    final proficiencies = data['proficiencies'] as List? ?? [];
    final savingThrows = data['saving_throws'] as List? ?? [];
    
    return CharacterClass(
      id: data['index'],
      name: data['name'],
      edition: '5e',
      hitDie: '1d$hitDie',
      primeRequisite: savingThrows.isNotEmpty ? savingThrows[0]['name'] : '—',
      allowedWeapons: proficiencies
          .where((p) => p['name'].toString().toLowerCase().contains('weapon'))
          .map((p) => p['name'])
          .join(', '),
      allowedArmor: proficiencies
          .where((p) => p['name'].toString().toLowerCase().contains('armor'))
          .map((p) => p['name'])
          .join(', '),
      description: data['desc'] ?? 'Sin descripción',
      abilities: [
        'Lanzamiento de Hechizos',
        'Subclase en nivel 3',
        'Mejora de Puntuación de Habilidad',
      ],
      color: _getClassColor(data['index']),
      icon: _getClassIcon(data['index']),
      imageUrl: imageUrl,
      imagePath: imagePath,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  Race _parseRace(Map data, {String? imageUrl, String? imagePath}) {
    final abilityMods = <String, int>{};
    if (data['ability_bonuses'] != null) {
      for (var bonus in data['ability_bonuses']) {
        final abilityName = bonus['ability_score']?['name'] ?? 'Unknown';
        abilityMods[abilityName] = bonus['bonus'] ?? 0;
      }
    }

    final specialAbilities = <String>[];
    if (data['traits'] != null) {
      for (var trait in data['traits']) {
        specialAbilities.add(trait['name'] ?? 'Unknown trait');
      }
    }

    return Race(
      id: data['index'],
      name: data['name'],
      edition: '5e',
      abilityMods: abilityMods,
      specialAbilities: specialAbilities,
      description: data['desc'] ?? 'Sin descripción',
      color: _getRaceColor(data['index']),
      icon: _getRaceIcon(data['index']),
      imageUrl: imageUrl,
      imagePath: imagePath,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  Equipment _parseEquipment(Map data, {String? imageUrl, String? imagePath}) {
    final cost = data['cost'];
    final ac = data['armor_class'];
    
    return Equipment(
      id: data['index'],
      name: data['name'],
      edition: '5e',
      type: data['equipment_category']?['name'] ?? 'Unknown',
      cost: cost != null ? '${cost['quantity']} ${cost['unit']}' : '—',
      weight: data['weight']?.toString() ?? '—',
      damage: data['damage']?['damage_dice'],
      damageDice: _extractDice(data['damage']?['damage_dice']),
      damageType: data['damage']?['damage_type']?['name'],
      acBonus: ac?['base'],
      strengthRequirement: ac?['strength_minimum']?.toString(),
      stealthDisadvantage: ac?['stealth_disadvantage'] == true,
      description: (data['desc'] as List?)?.join('\n') ?? 'Sin descripción',
      imageUrl: imageUrl,
      imagePath: imagePath,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  // === UTILIDADES ===

  int? _extractDice(String? dice) {
    if (dice == null) return null;
    final match = RegExp(r'(\d+)d').firstMatch(dice);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  String _formatStats(Map data) {
    return '''
FUE: ${data['strength']}  DES: ${data['dexterity']}
CON: ${data['constitution']}  INT: ${data['intelligence']}
SAB: ${data['wisdom']}  CAR: ${data['charisma']}
''';
  }

  String _formatActions(Map data) {
    final buf = StringBuffer();
    if (data['actions'] != null) {
      for (var a in data['actions']) {
        buf.writeln('• ${a['name']}: ${a['desc']}');
      }
    }
    return buf.toString();
  }

  Color _getClassColor(String index) {
    switch (index) {
      case 'fighter': return Colors.red;
      case 'wizard': return Colors.purple;
      case 'rogue': return Colors.grey;
      case 'cleric': return Colors.yellow;
      case 'paladin': return Colors.blue;
      case 'ranger': return Colors.green;
      case 'barbarian': return Colors.orange;
      case 'bard': return Colors.pink;
      case 'druid': return Colors.brown;
      case 'monk': return Colors.teal;
      case 'sorcerer': return Colors.deepPurple;
      case 'warlock': return Colors.indigo;
      default: return Colors.blueGrey;
    }
  }

  IconData _getClassIcon(String index) {
    switch (index) {
      case 'fighter': return Icons.shield;
      case 'wizard': return Icons.auto_awesome;
      case 'rogue': return Icons.visibility_off;
      case 'cleric': return Icons.healing;
      case 'paladin': return Icons.security;
      case 'ranger': return Icons.nature;
      case 'barbarian': return Icons.fitness_center;
      case 'bard': return Icons.music_note;
      case 'druid': return Icons.eco;
      case 'monk': return Icons.self_improvement;
      case 'sorcerer': return Icons.bolt;
      case 'warlock': return Icons.dark_mode;
      default: return Icons.person;
    }
  }

  Color _getRaceColor(String index) {
    switch (index) {
      case 'human': return Colors.brown;
      case 'elf': return Colors.green;
      case 'dwarf': return Colors.orange;
      case 'halfling': return Colors.lightGreen;
      case 'dragonborn': return Colors.red;
      case 'gnome': return Colors.purple;
      case 'half-elf': return Colors.teal;
      case 'half-orc': return Colors.grey;
      case 'tiefling': return Colors.deepOrange;
      default: return Colors.blueGrey;
    }
  }

  IconData _getRaceIcon(String index) {
    switch (index) {
      case 'human': return Icons.person;
      case 'elf': return Icons.auto_awesome;
      case 'dwarf': return Icons.engineering;
      case 'halfling': return Icons.child_friendly;
      case 'dragonborn': return Icons.whatshot;
      case 'gnome': return Icons.lightbulb;
      case 'half-elf': return Icons.people;
      case 'half-orc': return Icons.fitness_center;
      case 'tiefling': return Icons.local_fire_department;
      default: return Icons.groups;
    }
  }

  // === MÉTODOS PÚBLICOS INDIVIDUALES ===

  Future<Map<String, dynamic>> syncMonsters({
    int? limit,
    Function(int current, int total)? onProgress,
  }) async {
    if (_isSyncing) {
      return {'success': false, 'message': 'Sincronización en progreso'};
    }

    _isSyncing = true;
    _totalItems = 0;
    _syncedItems = 0;

    try {
      final data = await _api.get('monsters');
      final List results = data['results'] ?? [];
      final itemsToSync = limit != null ? results.take(limit).toList() : results;
      
      _totalItems = itemsToSync.length;

      int success = 0, errors = 0;
      List<String> errorList = [];

      for (var i = 0; i < itemsToSync.length; i++) {
        final item = itemsToSync[i];
        final slug = item['index'];
        final name = item['name'] ?? slug;

        try {
          final detail = await _api.get('monsters/$slug');
          await _parseAndSave('monsters', detail, name, slug);
          success++;
        } catch (e) {
          errors++;
          errorList.add('$name: $e');
        }

        _syncedItems++;
        onProgress?.call(_syncedItems, _totalItems);
        await Future.delayed(const Duration(milliseconds: 200));
      }

      _isSyncing = false;
      return {
        'success': true,
        'total': itemsToSync.length,
        'synced': success,
        'errors': errors,
        'errorList': errorList,
        'message': 'Sincronización completada',
      };
    } catch (e) {
      _isSyncing = false;
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> syncSpells({int? limit}) async {
    await _syncSection('spells', limit: limit);
  }

  Future<void> syncClasses() async {
    await _syncSection('classes');
  }

  Future<void> syncRaces() async {
    await _syncSection('races');
  }

  Future<void> syncEquipment({int? limit}) async {
    await _syncSection('equipment', limit: limit);
  }

  // === OTROS MÉTODOS ===

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
      return {'error': e.toString()};
    }
  }

  Future<void> clearSync() async {
    try {
      final monsters = await _db.readAllMonsters();
      final apiMonsters = monsters.where((m) => m.edition.contains('5e')).toList();
      
      for (var monster in apiMonsters) {
        await _db.deleteMonster(monster.id);
      }
      
      print('Limpiados ${apiMonsters.length} monstruos de la API');
    } catch (e) {
      print('Error limpiando: $e');
    }
  }

  void cancelSync() => _isSyncing = false;
  void dispose() => _api.dispose();
}