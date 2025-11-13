import 'dart:convert';
import 'api_service.dart';
import 'image_downloader.dart';
import 'database_helper.dart';
import '../models/monster.dart';

class SyncService {
  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Sincroniza monstruos
  Future<void> syncMonsters() async {
    try {
      final data = await _api.get('/api/2014/monsters');
      final List monsters = data['results'];

      for (var m in monsters) {
        final slug = m['index'];
        final detail = await _api.get('/api/2014/monsters/$slug');
        final monster = await _parseMonster(detail);
        if (monster != null) {
          await _db.createMonster(monster);
        }
      }
    } catch (e) {
      print('Error sincronizando monstruos: $e');
    }
  }

  Future<Monster?> _parseMonster(Map<String, dynamic> data) async {
    final name = data['name'] ?? 'Unknown';
    final id = data['index'] ?? name.toLowerCase().replaceAll(' ', '-');

    // Buscar imagen en Google Custom Search o usar placeholder
    final imageUrl = await _findImageUrl(name);
    final localPath = imageUrl != null ? await ImageDownloader.downloadAndSave(imageUrl, name) : null;

    return Monster(
      id: id,
      name: name,
      edition: '5e', // o '2014'
      type: data['type'] ?? '',
      size: data['size'] ?? '',
      hp: data['hit_points'] ?? 0,
      ac: data['armor_class']?[0]['value'] ?? data['armor_class'] ?? 10,
      description: _formatDesc(data),
      abilities: _formatAbilities(data),
      imagePath: localPath,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  String _formatDesc(Map<String, dynamic> data) {
    final desc = StringBuffer();
    if (data['desc'] != null) desc.writeln(data['desc']);
    if (data['special_abilities'] != null) {
      for (var sa in data['special_abilities']) {
        desc.writeln('${sa['name']}: ${sa['desc']}');
      }
    }
    return desc.toString().trim();
  }

  String _formatAbilities(Map<String, dynamic> data) {
    final actions = data['actions'] ?? [];
    return actions.map((a) => '${a['name']}: ${a['desc']}').join('\n');
  }

  /// Busca imagen con Google Custom Search (necesitas API Key)
  Future<String?> _findImageUrl(String query) async {
    // Opción 1: Usa un servicio como Unsplash, Pixabay, o D&D Beyond
    // Opción 2: Placeholder
    return _getPlaceholderImage(query);
  }

  /// Placeholder con D&D Beyond o AI-generated
  String _getPlaceholderImage(String name) {
    final slug = name.toLowerCase().replaceAll(' ', '-');
    return 'https://www.dndbeyond.com/avatars/thumbnails/0/${_hash(slug)}.jpeg';
    // O usa: https://source.unsplash.com/random/400x400/?$name+dnd
  }

  int _hash(String s) {
    return s.hashCode.abs() % 1000;
  }
}