// lib/services/image_downloader.dart
import 'dart:io';
import 'dart:async';
import 'dart:math' show min;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageDownloader {
  static const Duration _timeout = Duration(seconds: 15);

  /// Descarga y guarda una imagen desde internet
  static Future<String?> downloadAndSave(String imageUrl, String itemName) async {
    try {
      print('Intentando descargar: $imageUrl');
      
      final hash = md5.convert(utf8.encode(imageUrl)).toString().substring(0, 8);
      final fileName = '${itemName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_$hash.png';
      
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'dnd_images')); // ← Directorio genérico
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final filePath = p.join(imagesDir.path, fileName);
      final file = File(filePath);

      if (await file.exists() && await _isValidImage(file)) {
        print('Imagen ya existe: $filePath');
        return filePath;
      } else if (await file.exists()) {
        await file.delete();
      }

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Connection': 'keep-alive',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (!_isValidImageData(bytes)) return null;
        await file.writeAsBytes(bytes);
        return await _isValidImage(file) ? filePath : null;
      }
    } on TimeoutException {
      print('Timeout: $imageUrl');
    } catch (e) {
      print('Error descargando: $e');
    }
    return null;
  }

  /// Intenta descargar desde múltiples fuentes (por sección)
  static Future<String?> downloadFromMultipleSources(
    String section,
    String name,
    String index,
  ) async {
    final sources = _getImageSources(section, name, index);
    
    for (int i = 0; i < sources.length; i++) {
      final src = sources[i];
      print('Fuente ${i + 1}/${sources.length}: ${src['name']} ($section)');
      final result = await downloadAndSave(src['url'] as String, name);
      if (result != null) {
        print('Imagen encontrada: ${src['name']}');
        return result;
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    print('No se encontró imagen para: $name ($section)');
    return null;
  }

  /// Fuentes de imágenes por sección
  static List<Map<String, dynamic>> _getImageSources(String section, String name, String index) {
  final nameSlug = name.toLowerCase()
      .replaceAll(' ', '-')
      .replaceAll("'", '')
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  final nameEncoded = Uri.encodeComponent(name);

  // === FUENTES COMUNES (para todas las secciones) ===
  final common = [
    {'name': 'AideDD', 'url': 'https://www.aidedd.org/dnd/images/$index.jpg'}, // OFICIAL
    {'name': '5e.tools', 'url': 'https://5e.tools/img/$section/$index.png'},
    {'name': 'D&D Beyond', 'url': 'https://www.dndbeyond.com/avatars/$section/$index.png'},
    {'name': 'UI Avatars', 'url': 'https://ui-avatars.com/api/?name=${nameEncoded}&size=400&background=8B4513&color=FFD700'},
    {'name': 'Placeholder D&D', 'url': 'https://placehold.co/400x400/8B4513/FFD700/png?text=${nameEncoded.substring(0, min(15, name.length))}'},
  ];

  // === POR SECCIÓN ===
  switch (section) {
    // ========================================
    // 1. MONSTRUOS
    // ========================================
    case 'monsters':
      return [
        // OFICIALES (Monster Manual)
        {'name': 'AideDD Official', 'url': 'https://www.aidedd.org/dnd/images/$index.jpg'}, // 95% éxito
        {'name': '5e.tools Monster', 'url': 'https://5e.tools/img/monsters/$index.png'},
        {'name': 'D&D Beyond Monster', 'url': 'https://www.dndbeyond.com/avatars/monsters/$index.png'},

        // WIKIS (buenas imágenes, pero scrape)
        {'name': 'D&D Fandom ES', 'url': 'https://dnd5e.fandom.com/es/wiki/$nameSlug'},
        {'name': 'Forgotten Realms ES', 'url': 'https://forgottenrealms.fandom.com/es/wiki/$nameSlug'},

        // FANTASY-LIKE
        {'name': 'RoboHash Monster', 'url': 'https://robohash.org/$nameSlug?set=set2&size=400x400'}, // set2 = monstruos
        {'name': 'Unsplash Fantasy', 'url': 'https://source.unsplash.com/400x400/?fantasy,monster,$nameEncoded'},
        {'name': 'DiceBear Monster', 'url': 'https://api.dicebear.com/7.x/thumbs/png?seed=$nameSlug&size=400'},
        ...common,
      ];

    // ========================================
    // 2. HECHIZOS
    // ========================================
    case 'spells':
      return [
        {'name': '5e.tools Spell', 'url': 'https://5e.tools/img/spells/$index.png'},
        {'name': 'D&D Beyond Spell', 'url': 'https://www.dndbeyond.com/avatars/spells/$index.png'},
        {'name': 'DiceBear Magic', 'url': 'https://api.dicebear.com/7.x/micah/png?seed=$index&size=400&background=00008B&color=FFD700'},
        {'name': 'RoboHash Spell', 'url': 'https://robohash.org/$nameSlug?set=set3&size=400x400'},
        {'name': 'UI Avatars Magic', 'url': 'https://ui-avatars.com/api/?name=${nameEncoded}&size=400&background=4B0082&color=FFD700'},
        ...common,
      ];

    // ========================================
    // 3. CLASES
    // ========================================
    case 'classes':
      return [
        {'name': '5e.tools Class', 'url': 'https://5e.tools/img/classes/$index.png'},
        {'name': 'D&D Beyond Class', 'url': 'https://www.dndbeyond.com/avatars/classes/$index.png'},
        {'name': 'DiceBear Adventurer', 'url': 'https://api.dicebear.com/7.x/adventurer/png?seed=$nameSlug&size=400'},
        {'name': 'RoboHash Class', 'url': 'https://robohash.org/$nameSlug?set=set1&size=400x400'},
        {'name': 'UI Avatars Class', 'url': 'https://ui-avatars.com/api/?name=${nameEncoded}&size=400&background=8B4513&color=FFD700'},
        ...common,
      ];

    // ========================================
    // 4. RAZAS
    // ========================================
    case 'races':
      return [
        {'name': '5e.tools Race', 'url': 'https://5e.tools/img/races/$index.png'},
        {'name': 'D&D Beyond Race', 'url': 'https://www.dndbeyond.com/avatars/races/$index.png'},
        {'name': 'DiceBear Avataaars', 'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=$nameSlug&size=400'},
        {'name': 'RoboHash Race', 'url': 'https://robohash.org/$nameSlug?set=set4&size=400x400'},
        {'name': 'UI Avatars Race', 'url': 'https://ui-avatars.com/api/?name=${nameEncoded}&size=400&background=228B22&color=FFD700'},
        ...common,
      ];

    // ========================================
    // 5. EQUIPO
    // ========================================
    case 'equipment':
      return [
        {'name': '5e.tools Equipment', 'url': 'https://5e.tools/img/equipment/$index.png'},
        {'name': 'D&D Beyond Equipment', 'url': 'https://www.dndbeyond.com/avatars/equipment/$index.png'},
        {'name': 'DiceBear Item', 'url': 'https://api.dicebear.com/7.x/thumbs/png?seed=$nameSlug&size=400&background=556B2F&color=FFD700'},
        {'name': 'RoboHash Item', 'url': 'https://robohash.org/$nameSlug?set=set5&size=400x400'},
        {'name': 'UI Avatars Item', 'url': 'https://ui-avatars.com/api/?name=${nameEncoded}&size=400&background=8B4513&color=FFD700'},
        ...common,
      ];

    // ========================================
    // DEFAULT
    // ========================================
    default:
      return [
        ...common,
        {'name': 'RoboHash Generic', 'url': 'https://robohash.org/$nameSlug?size=400x400'},
      ];
  }
}

  // === VALIDACIÓN DE IMÁGENES ===
  static bool _isValidImageData(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 12) return false;
    final header = bytes.sublist(0, bytes.length < 12 ? bytes.length : 12);

    // JPEG, PNG, GIF, WEBP, BMP, SVG
    if ([0xFF, 0xD8, 0xFF].every((b) => header.length > 2 && header[header.indexOf(b)] == b)) return true;
    if (header.length >= 8 && header[0] == 0x89 && header[1] == 0x50) return true;
    if (header.length >= 6 && header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) return true;
    if (header.length >= 12 && header[0] == 0x52 && header[1] == 0x49 && header[8] == 0x57) return true;
    if (header.length >= 2 && header[0] == 0x42 && header[1] == 0x4D) return true;
    if (header.length >= 4) {
      final str = String.fromCharCodes(header.sublist(0, 4));
      if (str == '<svg' || str == '<?xml') return true;
    }
    return false;
  }

  static Future<bool> _isValidImage(File file) async {
    if (!await file.exists()) return false;
    final bytes = await file.readAsBytes();
    return _isValidImageData(bytes);
  }

  // === LIMPIEZA Y MANTENIMIENTO ===
  static Future<int> cleanupOldImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'dnd_images'));
    if (!await imagesDir.exists()) return 0;
    int deleted = 0;
    for (var f in await imagesDir.list().toList()) {
      if (f is File && !await _isValidImage(f)) {
        await f.delete();
        deleted++;
      }
    }
    print('Limpieza: $deleted corruptos eliminados');
    return deleted;
  }

  static Future<int> getTotalSize() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'dnd_images'));
    if (!await imagesDir.exists()) return 0;
    int size = 0;
    for (var f in await imagesDir.list().toList()) {
      if (f is File) size += await f.length();
    }
    return size;
  }

  static Future<int> deleteAllImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'dnd_images'));
    if (!await imagesDir.exists()) return 0;
    int deleted = 0;
    for (var f in await imagesDir.list().toList()) {
      if (f is File) {
        await f.delete();
        deleted++;
      }
    }
    print('Eliminadas $deleted imágenes');
    return deleted;
  }

  static Future<dynamic> getImageCount() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'images'));
    if (!await imagesDir.exists()) return 0;
    int count = 0;
    for (var f in await imagesDir.list().toList()) {
      if (f is File) count++;
    }
    return count;
  }
}

extension on String {
  capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}