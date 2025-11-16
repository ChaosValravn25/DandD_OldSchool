import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/monster.dart';
import '../models/character_class.dart';
import '../models/race.dart';
import '../models/equipment.dart';
import '../models/spell.dart';

/// Servicio para gestionar la base de datos SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Inicializar FFI para escritorio
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('dnd_oldschool.db');
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // ← INCREMENTADO PARA MIGRACIÓN
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // ← AGREGADO
    );
  }

  /// Crea las tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER DEFAULT 0';

    // Tabla de monstruos
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

    // Tabla de hechizos
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

    // Tabla de clases (CON color e icon)
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

    // Tabla races (CON color e icon)
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

    // Tabla de equipamiento
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

    // Tabla de ediciones
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

    // Tabla de reglas
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

    // Tabla de notas personales
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

  /// Migra la base de datos a una nueva versión
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columnas faltantes a character_classes
      try {
        await db.execute('ALTER TABLE character_classes ADD COLUMN abilities TEXT');
      } catch (e) {
        print('Column abilities already exists in character_classes');
      }
      
      try {
        await db.execute('ALTER TABLE character_classes ADD COLUMN color TEXT DEFAULT "red"');
      } catch (e) {
        print('Column color already exists in character_classes');
      }
      
      try {
        await db.execute('ALTER TABLE character_classes ADD COLUMN icon TEXT DEFAULT "shield"');
      } catch (e) {
        print('Column icon already exists in character_classes');
      }

      // Agregar columnas faltantes a races
      try {
        await db.execute('ALTER TABLE races ADD COLUMN color TEXT DEFAULT "brown"');
      } catch (e) {
        print('Column color already exists in races');
      }
      
      try {
        await db.execute('ALTER TABLE races ADD COLUMN icon TEXT DEFAULT "person"');
      } catch (e) {
        print('Column icon already exists in races');
      }
    }
  }

  // ========== OPERACIONES CRUD PARA MONSTRUOS ==========

  Future<Monster> createMonster(Monster monster) async {
    final db = await database;
    await db.insert('monsters', monster.toMap());
    return monster;
  }

  Future<Monster?> readMonster(String id) async {
    final db = await database;
    final maps = await db.query(
      'monsters',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Monster.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Monster>> readAllMonsters() async {
    final db = await database;
    const orderBy = 'name ASC';
    final result = await db.query('monsters', orderBy: orderBy);
    return result.map((json) => Monster.fromMap(json)).toList();
  }

  Future<List<Monster>> readMonstersByEdition(String edition) async {
    final db = await database;
    final result = await db.query(
      'monsters',
      where: 'edition = ?',
      whereArgs: [edition],
      orderBy: 'name ASC',
    );
    return result.map((json) => Monster.fromMap(json)).toList();
  }

  Future<List<Monster>> readFavoriteMonsters() async {
    final db = await database;
    final result = await db.query(
      'monsters',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((json) => Monster.fromMap(json)).toList();
  }

  Future<int> updateMonster(Monster monster) async {
    final db = await database;
    return db.update(
      'monsters',
      monster.toMap(),
      where: 'id = ?',
      whereArgs: [monster.id],
    );
  }

  Future<int> deleteMonster(String id) async {
    final db = await database;
    return await db.delete(
      'monsters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavoriteMonster(String id, bool isFavorite) async {
    final db = await database;
    return db.update(
      'monsters',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Monster>> searchMonsters(String query) async {
    final db = await database;
    final result = await db.query(
      'monsters',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((json) => Monster.fromMap(json)).toList();
  }

  // ========== OPERACIONES PARA CLASES ==========

  Future<CharacterClass> createClass(CharacterClass cls) async {
    final db = await database;
    await db.insert('character_classes', cls.toMap());
    return cls;
  }

  Future<List<CharacterClass>> readAllClasses() async {
    final db = await database;
    final result = await db.query('character_classes', orderBy: 'name ASC');
    return result.map(CharacterClass.fromMap).toList();
  }

  Future<CharacterClass?> readClass(String id) async {
    final db = await database;
    final maps = await db.query(
      'character_classes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? CharacterClass.fromMap(maps.first) : null;
  }

  // ========== OPERACIONES PARA RAZAS ==========

  Future<Race> createRace(Race race) async {
    final db = await database;
    await db.insert('races', race.toMap());
    return race;
  }

  Future<List<Race>> readAllRaces() async {
    final db = await database;
    final result = await db.query('races', orderBy: 'name ASC');
    return result.map(Race.fromMap).toList();
  }

  Future<Race?> readRace(String id) async {
    final db = await database;
    final maps = await db.query(
      'races',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Race.fromMap(maps.first) : null;
  }

  // ========== OPERACIONES PARA HECHIZOS ==========

  Future<Spell> createSpell(Spell spell) async {
    final db = await database;
    await db.insert('spells', spell.toMap());
    return spell;
  }

  Future<List<Spell>> readAllSpells() async {
    final db = await database;
    final result = await db.query('spells', orderBy: 'name ASC');
    return result.map(Spell.fromMap).toList();
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

  // ========== OPERACIONES PARA EQUIPAMIENTO ==========

  Future<Equipment> createEquipment(Equipment equipment) async {
    final db = await database;
    await db.insert('equipment', equipment.toMap());
    return equipment;
  }

  Future<List<Equipment>> readAllEquipment() async {
    final db = await database;
    final result = await db.query('equipment', orderBy: 'name ASC');
    return result.map(Equipment.fromMap).toList();
  }

  Future<Equipment?> readEquipment(String id) async {
    final db = await database;
    final maps = await db.query('equipment', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Equipment.fromMap(maps.first) : null;
  }

  Future<int> updateEquipment(Equipment equipment) async {
    final db = await database;
    return db.update('equipment', equipment.toMap(), where: 'id = ?', whereArgs: [equipment.id]);
  }

  Future<int> toggleFavoriteEquipment(String id, bool isFavorite) async {
    final db = await database;
    return db.update('equipment', {'is_favorite': isFavorite ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  // ========== OPERACIONES PARA NOTAS ==========

  Future<int> saveNote(String entityType, String entityId, String note) async {
    final db = await database;
    return await db.insert('user_notes', {
      'entity_type': entityType,
      'entity_id': entityId,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getNotes(
      String entityType, String entityId) async {
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
    return await db.delete(
      'user_notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // ========== MÉTODOS AUXILIARES ==========

  Future<int> rawUpdate(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<void> insertSampleData() async {
    final monsters = Monster.sample();
    for (var monster in monsters) {
      await createMonster(monster);
    }
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
}