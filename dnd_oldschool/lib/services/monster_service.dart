import 'package:dnd_oldschool/services/api_service.dart';
import 'package:dnd_oldschool/services/image_downloader.dart';
import 'monster_mapper.dart';
import '../models/monster.dart';

class MonsterService {
  final ApiService api;

  MonsterService(this.api);

  /// Lista básica de monstruos
  Future<List<String>> fetchMonsterIndexes() async {
    final data = await api.get("monsters");
    final results = List<Map<String, dynamic>>.from(data["results"]);
    return results.map((e) => e["index"] as String).toList();
  }

  /// Obtiene monstruo completo + imagen integrada
  Future<Monster> fetchMonster(String index) async {
    final json = await api.get("monsters/$index");

    final localImage = await ImageDownloader.downloadFromMultipleSources(
      json["name"],
      json["index"],
    );

    return MonsterMapper.fromDndApi(json, localImage);
  }
}
