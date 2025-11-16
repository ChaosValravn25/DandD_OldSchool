// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://www.dnd5eapi.co/api';

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load $endpoint');
  }

  /// Obtiene índices de monstruos
  Future<List<String>> getMonsterIndexes() async {
    final data = await get('monsters');
    final results = List<Map<String, dynamic>>.from(data['results']);
    return results.map((e) => e['index'] as String).toList();
  }

  /// Obtiene índices de cualquier sección
  Future<List<String>> getIndexes(String section) async {
    final data = await get(section);
    final results = List<Map<String, dynamic>>.from(data['results']);
    return results.map((e) => e['index'] as String).toList();
  }
}
