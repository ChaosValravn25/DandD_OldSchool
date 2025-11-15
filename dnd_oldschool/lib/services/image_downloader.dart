// lib/services/image_downloader.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageDownloader {
  static const Duration _timeout = Duration(seconds: 10);
  
  /// Descarga y guarda una imagen desde internet
  static Future<String?> downloadAndSave(String imageUrl, String monsterName) async {
    try {
      print('📥 Intentando descargar: $imageUrl');
      
      // Generar nombre de archivo único
      final hash = md5.convert(utf8.encode(imageUrl)).toString().substring(0, 8);
      final fileName = '${monsterName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_$hash.png';
      
      // Obtener directorio de la app
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'monster_images'));
      
      // Crear directorio si no existe
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final filePath = p.join(imagesDir.path, fileName);
      final file = File(filePath);

      // Si ya existe y es válida, retornar
      if (await file.exists()) {
        if (await _isValidImage(file)) {
          print('✅ Imagen ya existe: $filePath');
          return filePath;
        } else {
          await file.delete();
          print('🗑️ Imagen corrupta eliminada, reintentando...');
        }
      }

      // Descargar imagen
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'image/*',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // Validar que sea una imagen
        if (!_isValidImageData(bytes)) {
          print('❌ Los datos descargados no son una imagen válida');
          return null;
        }

        // Guardar archivo
        await file.writeAsBytes(bytes);
        
        // Verificar que se guardó correctamente
        if (await _isValidImage(file)) {
          print('✅ Imagen descargada: $filePath (${(bytes.length / 1024).toStringAsFixed(1)} KB)');
          return filePath;
        } else {
          await file.delete();
          print('❌ Imagen guardada pero corrupta');
          return null;
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}: $imageUrl');
        return null;
      }
    } catch (e) {
      print('❌ Error descargando imagen: $e');
      return null;
    }
  }

  /// Intenta descargar desde múltiples fuentes
  static Future<String?> downloadFromMultipleSources(
    String monsterName,
    String monsterIndex,
  ) async {
    final sources = _getImageSources(monsterName, monsterIndex);
    
    for (int i = 0; i < sources.length; i++) {
      print('🔍 Fuente ${i + 1}/${sources.length}: ${sources[i]['name']}');
      final url = sources[i]['url'] as String;
      
      final result = await downloadAndSave(url, monsterName);
      if (result != null) {
        print('✅ Imagen encontrada en: ${sources[i]['name']}');
        return result;
      }
    }
    
    print('⚠️ No se pudo descargar imagen de ninguna fuente para: $monsterName');
    return null;
  }

  /// Obtiene lista de fuentes de imágenes
  static List<Map<String, dynamic>> _getImageSources(String name, String index) {
    final nameSlug = name.toLowerCase().replaceAll(' ', '-').replaceAll("'", '');
    final nameEncoded = Uri.encodeComponent(name);
    
    return [
      // 1. D&D Beyond (mejor calidad pero puede requerir auth)
      {
        'name': 'D&D Beyond',
        'url': 'https://www.dndbeyond.com/avatars/thumbnails/monsters/$index.png',
      },
      
      // 2. Roll20 Compendium
      {
        'name': 'Roll20',
        'url': 'https://roll20.net/compendium/dnd5e/$index/avatar.png',
      },
      
      // 3. Open5e (API alternativa con imágenes)
      {
        'name': 'Open5e',
        'url': 'https://api.open5e.com/v1/monsters/$index/image',
      },
      
      // 4. Wikimedia Commons (imágenes libres)
      {
        'name': 'Wikimedia',
        'url': 'https://commons.wikimedia.org/wiki/Special:FilePath/$nameEncoded',
      },
      
      // 5. Unsplash (genérico pero siempre funciona)
      {
        'name': 'Unsplash Fantasy',
        'url': 'https://source.unsplash.com/400x400/?fantasy,monster,$nameEncoded',
      },
      
      // 6. LoremFlickr (alternativa)
      {
        'name': 'LoremFlickr',
        'url': 'https://loremflickr.com/400/400/dragon,fantasy,monster',
      },
      
      // 7. Picsum (último recurso - imagen aleatoria)
      {
        'name': 'Picsum',
        'url': 'https://picsum.photos/400/400?random=$index',
      },
    ];
  }

  /// Valida que los bytes sean una imagen válida
  static bool _isValidImageData(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 12) return false;

    // Verificar firmas de archivos de imagen
    final header = bytes.sublist(0, bytes.length < 12 ? bytes.length : 12);

    // JPEG: FF D8 FF
    if (header.length >= 3 &&
        header[0] == 0xFF &&
        header[1] == 0xD8 &&
        header[2] == 0xFF) {
      return true;
    }

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (header.length >= 8 &&
        header[0] == 0x89 &&
        header[1] == 0x50 &&
        header[2] == 0x4E &&
        header[3] == 0x47 &&
        header[4] == 0x0D &&
        header[5] == 0x0A &&
        header[6] == 0x1A &&
        header[7] == 0x0A) {
      return true;
    }

    // GIF: GIF87a o GIF89a
    if (header.length >= 6 &&
        header[0] == 0x47 &&
        header[1] == 0x49 &&
        header[2] == 0x46 &&
        header[3] == 0x38 &&
        (header[4] == 0x37 || header[4] == 0x39) &&
        header[5] == 0x61) {
      return true;
    }

    // WEBP: RIFF....WEBP
    if (header.length >= 12 &&
        header[0] == 0x52 &&
        header[1] == 0x49 &&
        header[2] == 0x46 &&
        header[3] == 0x46 &&
        header[8] == 0x57 &&
        header[9] == 0x45 &&
        header[10] == 0x42 &&
        header[11] == 0x50) {
      return true;
    }

    // BMP: BM
    if (header.length >= 2 &&
        header[0] == 0x42 &&
        header[1] == 0x4D) {
      return true;
    }

    return false;
  }

  /// Verifica si un archivo es una imagen válida
  static Future<bool> _isValidImage(File file) async {
    try {
      if (!await file.exists()) return false;
      
      final bytes = await file.readAsBytes();
      return _isValidImageData(bytes);
    } catch (e) {
      return false;
    }
  }

  /// Limpia imágenes antiguas o corruptas
  static Future<void> cleanupOldImages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'monster_images'));
      
      if (!await imagesDir.exists()) return;
      
      final files = await imagesDir.list().toList();
      int deleted = 0;
      
      for (var entity in files) {
        if (entity is File) {
          if (!await _isValidImage(entity)) {
            await entity.delete();
            deleted++;
          }
        }
      }
      
      print('🗑️ Limpieza: $deleted archivos corruptos eliminados');
    } catch (e) {
      print('❌ Error en limpieza: $e');
    }
  }

  /// Obtiene el tamaño total de imágenes descargadas
  static Future<int> getTotalSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'monster_images'));
      
      if (!await imagesDir.exists()) return 0;
      
      final files = await imagesDir.list().toList();
      int totalSize = 0;
      
      for (var entity in files) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}