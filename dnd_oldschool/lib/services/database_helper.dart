// lib/services/database_helper.dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart'; // ← AÑADIDO para Sqflite.firstIntValue

import '../models/monster.dart';
import '../models/character_class.dart';
import '../models/race.dart';
import '../models/equipment.dart';
import '../models/spell.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('dnd_oldschool.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER DEFAULT 0';

    // === MONSTRUOS ===
    await db.execute('''
      CREATE TABLE monsters (
        id $idType,
        name $textType,
        edition $textType,
        type TEXT,
        size TEXT,
        hp $intType,
        ac INTEGER,
        description TEXT,
        abilities TEXT,
        image_path TEXT,
        is_favorite $boolType,
        created_at TEXT,
        image_url TEXT
      )
    ''');

    // === HECHIZOS ===
    await db.execute('''
      CREATE TABLE spells (
        id $idType,
        name $textType,
        edition $textType,
        level INTEGER,
        school TEXT,
        casting_time TEXT,
        spell_range TEXT,
        components TEXT,
        duration TEXT,
        description TEXT,
        is_favorite $boolType,
        created_at TEXT,
        image_url TEXT,
        image_path TEXT
      )
    ''');

    // === CLASES ===
    await db.execute('''
      CREATE TABLE character_classes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        edition TEXT,
        hit_die TEXT,
        prime_requisite TEXT,
        allowed_weapons TEXT,
        allowed_armor TEXT,
        description TEXT,
        abilities TEXT,
        color TEXT,
        icon TEXT,
        image_url TEXT,        
        image_path TEXT,       
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // === RAZAS ===
    await db.execute('''
      CREATE TABLE races (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        edition TEXT,
        ability_adjustments TEXT,
        special_abilities TEXT,
        level_limits TEXT,
        description TEXT,
        color TEXT,
        icon TEXT,
        image_url TEXT,       
        image_path TEXT,       
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // === EQUIPAMIENTO ===
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        edition TEXT,
        equipment_category TEXT,
        cost TEXT,
        weight TEXT,
        damage TEXT,
        damage_dice INTEGER,
        damage_type TEXT,
        ac_bonus INTEGER,
        armor_class TEXT,
        strength_requirement TEXT,
        stealth_disadvantage INTEGER,
        description TEXT,
        image_url TEXT,           
        image_path TEXT,          
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // === EDICIONES, REGLAS, NOTAS ===
    await db.execute('''
      CREATE TABLE editions (
        id $idType,
        name $textType,
        full_name TEXT,
        year INTEGER,
        publisher TEXT,
        description TEXT,
        key_features TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rules (
        id $idType,
        edition $textType,
        category TEXT,
        title $textType,
        description TEXT,
        page_reference TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT,
        entity_id TEXT,
        note TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tables = ['character_classes', 'races'];
      for (var table in tables) {
        try { await db.execute('ALTER TABLE $table ADD COLUMN abilities TEXT'); } catch (_) {}
        try { await db.execute('ALTER TABLE $table ADD COLUMN color TEXT DEFAULT "red"'); } catch (_) {}
        try { await db.execute('ALTER TABLE $table ADD COLUMN icon TEXT DEFAULT "shield"'); } catch (_) {}
      }
    }
  }

  // === CRUD MONSTRUOS ===
  Future<Monster> createMonster(Monster monster) async {
    final db = await database;
    await db.insert('monsters', monster.toMap());
    return monster;
  }

  Future<Monster?> readMonster(String id) async {
    final db = await database;
    final maps = await db.query('monsters', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Monster.fromMap(maps.first) : null;
  }

  Future<List<Monster>> readAllMonsters() async {
    final db = await database;
    final result = await db.query('monsters', orderBy: 'name ASC');
    return result.map((map) => Monster.fromMap(map)).toList(); // ← CORREGIDO
  }

  Future<List<Monster>> readMonstersByEdition(String edition) async {
    final db = await database;
    final result = await db.query('monsters', where: 'edition = ?', whereArgs: [edition], orderBy: 'name ASC');
    return result.map((map) => Monster.fromMap(map)).toList();
  }

  Future<List<Monster>> readFavoriteMonsters() async {
    final db = await database;
    final result = await db.query('monsters', where: 'is_favorite = 1', orderBy: 'name ASC');
    return result.map((map) => Monster.fromMap(map)).toList();
  }

  Future<int> updateMonster(Monster monster) async {
    final db = await database;
    return db.update('monsters', monster.toMap(), where: 'id = ?', whereArgs: [monster.id]);
  }

  Future<int> deleteMonster(String id) async {
    final db = await database;
    return db.delete('monsters', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleFavoriteMonster(String id, bool isFavorite) async {
    final db = await database;
    return db.update('monsters', {'is_favorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Monster>> searchMonsters(String query) async {
    final db = await database;
    final result = await db.query('monsters', where: 'name LIKE ?', whereArgs: ['%$query%'], orderBy: 'name ASC');
    return result.map((map) => Monster.fromMap(map)).toList();
  }

  // === CRUD CLASES ===
  Future<CharacterClass> createClass(CharacterClass cls) async {
    final db = await database;
    await db.insert('character_classes', cls.toMap());
    return cls;
  }

  Future<List<CharacterClass>> readAllClasses() async {
    final db = await database;
    final result = await db.query('character_classes', orderBy: 'name ASC');
    return result.map((map) => CharacterClass.fromMap(map)).toList();
  }

  Future<CharacterClass?> readClass(String id) async {
    final db = await database;
    final maps = await db.query('character_classes', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? CharacterClass.fromMap(maps.first) : null;
  }

  // === CRUD RAZAS ===
  Future<Race> createRace(Race race) async {
    final db = await database;
    await db.insert('races', race.toMap());
    return race;
  }

  Future<List<Race>> readAllRaces() async {
    final db = await database;
    final result = await db.query('races', orderBy: 'name ASC');
    return result.map((map) => Race.fromMap(map)).toList();
  }

  Future<Race?> readRace(String id) async {
    final db = await database;
    final maps = await db.query('races', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Race.fromMap(maps.first) : null;
  }

  // === CRUD HECHIZOS ===
  Future<Spell> createSpell(Spell spell) async {
    final db = await database;
    await db.insert('spells', spell.toMap());
    return spell;
  }

  Future<List<Spell>> readAllSpells() async {
    final db = await database;
    final result = await db.query('spells', orderBy: 'name ASC');
    return result.map((map) => Spell.fromMap(map)).toList();
  }

  Future<Spell?> readSpell(String id) async {
    final db = await database;
    final maps = await db.query('spells', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Spell.fromMap(maps.first) : null;
  }

  Future<int> updateSpell(Spell spell) async {
    final db = await database;
    return db.update('spells', spell.toMap(), where: 'id = ?', whereArgs: [spell.id]);
  }

  Future<int> toggleFavoriteSpell(String id, bool isFavorite) async {
    final db = await database;
    return db.update('spells', {'is_favorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  // === CRUD EQUIPAMIENTO ===
  Future<Equipment> createEquipment(Equipment equipment) async {
    final db = await database;
    await db.insert('equipment', equipment.toMap());
    return equipment;
  }

  Future<List<Equipment>> readAllEquipment() async {
    final db = await database;
    final result = await db.query('equipment', orderBy: 'name ASC');
    return result.map((map) => Equipment.fromMap(map)).toList();
  }

  Future<Equipment?> readEquipment(String id) async {
    final db = await database;
    final maps = await db.query('equipment', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Equipment.fromMap(maps.first) : null;
  }

  // === INSERTS PARA SYNC ===
  Future<int> insertMonster(Monster monster) async {
    final db = await database;
    return await db.insert('monsters', monster.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertSpell(Spell spell) async {
    final db = await database;
    return await db.insert('spells', spell.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertClass(CharacterClass cls) async {
    final db = await database;
    return await db.insert('character_classes', cls.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertRace(Race race) async {
    final db = await database;
    return await db.insert('races', race.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertEquipment(Equipment equipment) async {
    final db = await database;
    return await db.insert('equipment', equipment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // === ESTADÍSTICAS DE SYNC ===
  Future<int> getMonsterCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM monsters');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getApiMonsterCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM monsters WHERE image_path IS NOT NULL');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // === LIMPIEZA ===
  Future<void> deleteApiMonsters() async {
    final db = await database;
    await db.delete('monsters', where: 'image_path IS NOT NULL');
  }

  // === NOTAS ===
  Future<int> saveNote(String entityType, String entityId, String note) async {
    final db = await database;
    return await db.insert('user_notes', {
      'entity_type': entityType,
      'entity_id': entityId,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getNotes(String entityType, String entityId) async {
    final db = await database;
    return await db.query(
      'user_notes',
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType, entityId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete('user_notes', where: 'id = ?', whereArgs: [noteId]);
  }

  // === AUXILIARES ===
  Future<int> rawUpdate(String table, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<void> insertSampleData() async {
    final monsters = Monster.sample();
    for (var m in monsters) await createMonster(m);

    final classes = CharacterClass.getSample();
    for (var c in classes) await createClass(c);
  }

  Future<bool> hasData() async {
    final db = await database;
    final result = await db.query('monsters', limit: 1);
    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> toggleFavoriteEquipment(String id, bool bool) async {
    final db = await database;
    await db.update('equipment', {'is_favorite': bool ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }
}