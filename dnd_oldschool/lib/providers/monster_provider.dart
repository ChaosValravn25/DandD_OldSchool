import 'package:flutter/foundation.dart';
import '../models/monster.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

/// Provider para gestionar el estado de los monstruos
class MonsterProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();
  
  List<Monster> _monsters = [];
  List<Monster> _filteredMonsters = [];
  String _selectedEdition = 'Todas';
  bool _showOnlyFavorites = false;
  bool _isLoading = false;
  String? _error;
  
  // Variables para el progreso de sincronización
  int _syncProgress = 0;
  int _syncTotal = 0;
  bool _isSyncing = false;

  // Getters
  List<Monster> get monsters => _filteredMonsters.isEmpty ? _monsters : _filteredMonsters;
  String get selectedEdition => _selectedEdition;
  bool get showOnlyFavorites => _showOnlyFavorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalMonsters => _monsters.length;
  int get favoriteCount => _monsters.where((m) => m.isFavorite).length;
  
  // Getters para sincronización
  bool get isSyncing => _isSyncing;
  int get syncProgress => _syncProgress;
  int get syncTotal => _syncTotal;
  double get syncPercentage => _syncTotal > 0 ? _syncProgress / _syncTotal : 0.0;

  /// Lista de ediciones disponibles
  List<String> get availableEditions {
    final editions = _monsters.map((m) => m.edition).toSet().toList();
    editions.sort();
    return ['Todas', ...editions];
  }

  /// Carga todos los monstruos desde la base de datos
  Future<void> loadMonsters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar si hay datos, si no, cargar datos de ejemplo
      final hasData = await _db.hasData();
      if (!hasData) {
        await _db.insertSampleData();
      }

      _monsters = await _db.readAllMonsters();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar monstruos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene un monstruo por ID
  Future<Monster?> getMonsterById(String id) async {
    try {
      return await _db.readMonster(id);
    } catch (e) {
      _error = 'Error al obtener monstruo: $e';
      notifyListeners();
      return null;
    }
  }

  /// Agrega un nuevo monstruo
  Future<bool> addMonster(Monster monster) async {
    try {
      await _db.createMonster(monster);
      _monsters.add(monster);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar monstruo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza un monstruo existente
  Future<bool> updateMonster(Monster monster) async {
    try {
      await _db.updateMonster(monster);
      final index = _monsters.indexWhere((m) => m.id == monster.id);
      if (index != -1) {
        _monsters[index] = monster;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error al actualizar monstruo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina un monstruo
  Future<bool> deleteMonster(String id) async {
    try {
      await _db.deleteMonster(id);
      _monsters.removeWhere((m) => m.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar monstruo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Marca o desmarca un monstruo como favorito
  Future<void> toggleFavorite(String id) async {
    try {
      final monster = _monsters.firstWhere((m) => m.id == id);
      final newFavoriteStatus = !monster.isFavorite;
      
      await _db.toggleFavoriteMonster(id, newFavoriteStatus);
      
      final index = _monsters.indexWhere((m) => m.id == id);
      if (index != -1) {
        _monsters[index] = monster.copyWith(isFavorite: newFavoriteStatus);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar favorito: $e';
      notifyListeners();
    }
  }

  /// Busca monstruos por nombre
  Future<void> searchMonsters(String query) async {
    if (query.isEmpty) {
      _filteredMonsters = [];
      _applyFilters();
      notifyListeners();
      return;
    }

    try {
      _filteredMonsters = await _db.searchMonsters(query);
      notifyListeners();
    } catch (e) {
      _error = 'Error al buscar: $e';
      notifyListeners();
    }
  }

  /// Filtra por edición
  void filterByEdition(String edition) {
    _selectedEdition = edition;
    _applyFilters();
    notifyListeners();
  }

  /// Muestra solo favoritos
  void toggleShowFavorites(bool value) {
    _showOnlyFavorites = value;
    _applyFilters();
    notifyListeners();
  }

  /// Aplica los filtros activos
  void _applyFilters() {
    var filtered = List<Monster>.from(_monsters);

    // Filtrar por edición
    if (_selectedEdition != 'Todas') {
      filtered = filtered.where((m) => m.edition == _selectedEdition).toList();
    }

    // Filtrar por favoritos
    if (_showOnlyFavorites) {
      filtered = filtered.where((m) => m.isFavorite).toList();
    }

    _filteredMonsters = filtered;
  }

  /// Ordena los monstruos
  void sortMonsters(String sortBy) {
    switch (sortBy) {
      case 'name_asc':
        _monsters.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        _monsters.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'hp_asc':
        _monsters.sort((a, b) => a.hp.compareTo(b.hp));
        break;
      case 'hp_desc':
        _monsters.sort((a, b) => b.hp.compareTo(a.hp));
        break;
      case 'edition':
        _monsters.sort((a, b) => a.edition.compareTo(b.edition));
        break;
    }
    _applyFilters();
    notifyListeners();
  }

  /// Limpia los filtros
  void clearFilters() {
    _selectedEdition = 'Todas';
    _showOnlyFavorites = false;
    _filteredMonsters = [];
    _applyFilters();
    notifyListeners();
  }

  /// Limpia el error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Obtiene estadísticas
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (var monster in _monsters) {
      stats[monster.edition] = (stats[monster.edition] ?? 0) + 1;
    }
    return stats;
  }

  /// Exporta monstruos a texto
  String exportToText() {
    final buffer = StringBuffer();
    buffer.writeln('=== D&D Old School Compendium - Bestiario ===\n');
    
    for (var monster in _monsters) {
      buffer.writeln('🐉 ${monster.name}');
      buffer.writeln('   Edición: ${monster.edition}');
      if (monster.type != null) buffer.writeln('   Tipo: ${monster.type}');
      if (monster.size != null) buffer.writeln('   Tamaño: ${monster.size}');
      buffer.writeln('   HP: ${monster.hp}');
      if (monster.ac != null) buffer.writeln('   AC: ${monster.ac}');
      buffer.writeln('   ${monster.description}');
      if (monster.abilities != null) {
        buffer.writeln('   Habilidades: ${monster.abilities}');
      }
      if (monster.isFavorite) buffer.writeln('   ⭐ Favorito');
      buffer.writeln('');
    }
    
    return buffer.toString();
  }

  // ===============================================================
  // SINCRONIZACIÓN CON API D&D 5e
  // ===============================================================

  /// Importa monstruos desde la API oficial D&D 5e
  /// 
  ///  - Número máximo de monstruos a sincronizar (null = todos)
  /// Retorna un Map con los resultados de la sincronización
  Future<Map<String, dynamic>> importMonstersFromApi({int? limit}) async {
    try {
      _isSyncing = true;
      _syncProgress = 0;
      _syncTotal = 0;
      _error = null;
      notifyListeners();

      final results = await _syncService.syncMonsters(
        limit: limit,
        onProgress: (current, total) {
          _syncProgress = current;
          _syncTotal = total;
          notifyListeners();
        },
      );

      // Recargar monstruos después de sincronizar
      _monsters = await _db.readAllMonsters();
      _applyFilters();
      
      return results;
    } catch (e) {
      _error = "Error al importar monstruos desde API: $e";
      return {
        'success': false,
        'message': _error!,
      };
    } finally {
      _isSyncing = false;
      _syncProgress = 0;
      _syncTotal = 0;
      notifyListeners();
    }
  }

  /// Obtiene estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      return await _syncService.getSyncStats();
    } catch (e) {
      _error = 'Error al obtener estadísticas: $e';
      notifyListeners();
      return {
        'total_monsters': 0,
        'synced_from_api': 0,
        'local_only': 0,
      };
    }
  }

  /// Limpia todos los monstruos sincronizados de la API
  Future<void> clearApiMonsters() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _syncService.clearSync();
      await loadMonsters();
    } catch (e) {
      _error = 'Error al limpiar monstruos de API: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}