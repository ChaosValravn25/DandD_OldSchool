import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/monster.dart';

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
      version: 1,
      onCreate: _createDB,
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
        created_at TEXT
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
        is_favorite $boolType
      )
    ''');

    // Tabla de clases
    await db.execute('''
      CREATE TABLE character_classes (
        id $idType,
        name $textType,
        edition $textType,
        hit_die TEXT,
        prime_requisite TEXT,
        allowed_weapons TEXT,
        allowed_armor TEXT,
        description TEXT
      )
    ''');

    // Tabla de razas
    await db.execute('''
      CREATE TABLE races (
        id $idType,
        name $textType,
        edition $textType,
        ability_adjustments TEXT,
        special_abilities TEXT,
        level_limits TEXT,
        description TEXT
      )
    ''');

    // Tabla de equipamiento
    await db.execute('''
      CREATE TABLE equipment (
        id $idType,
        name $textType,
        edition $textType,
        equipment_type TEXT,
        cost TEXT,
        weight TEXT,
        damage TEXT,
        ac_bonus INTEGER,
        description TEXT
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

  // ========== OPERACIONES CRUD PARA MONSTRUOS ==========

  /// Crea un nuevo monstruo
  Future<Monster> createMonster(Monster monster) async {
    final db = await database;
    await db.insert('monsters', monster.toMap());
    return monster;
  }

  /// Obtiene un monstruo por ID
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

  /// Obtiene todos los monstruos
  Future<List<Monster>> readAllMonsters() async {
    final db = await database;
    const orderBy = 'name ASC';
    final result = await db.query('monsters', orderBy: orderBy);
    return result.map((json) => Monster.fromMap(json)).toList();
  }

  /// Obtiene monstruos filtrados por edición
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

  /// Obtiene monstruos favoritos
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

  /// Actualiza un monstruo
  Future<int> updateMonster(Monster monster) async {
    final db = await database;
    return db.update(
      'monsters',
      monster.toMap(),
      where: 'id = ?',
      whereArgs: [monster.id],
    );
  }

  /// Elimina un monstruo
  Future<int> deleteMonster(String id) async {
    final db = await database;
    return await db.delete(
      'monsters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marca o desmarca un monstruo como favorito
  Future<int> toggleFavoriteMonster(String id, bool isFavorite) async {
    final db = await database;
    return db.update(
      'monsters',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Busca monstruos por nombre
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

  // ========== OPERACIONES PARA NOTAS ==========

  /// Guarda una nota personal
  Future<int> saveNote(String entityType, String entityId, String note) async {
    final db = await database;
    return await db.insert('user_notes', {
      'entity_type': entityType,
      'entity_id': entityId,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Obtiene notas de una entidad
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

  /// Elimina una nota
  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete(
      'user_notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // ========== INICIALIZACIÓN DE DATOS ==========

  /// Inserta datos de ejemplo (llamar solo una vez)
  Future<void> insertSampleData() async {
    final monsters = Monster.sample();
    for (var monster in monsters) {
      await createMonster(monster);
    }
  }

  /// Verifica si hay datos en la base de datos
  Future<bool> hasData() async {
    final db = await database;
    final result = await db.query('monsters', limit: 1);
    return result.isNotEmpty;
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}