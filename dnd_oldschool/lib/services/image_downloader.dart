// lib/services/image_downloader.dart
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageDownloader {
  static const Duration _timeout = Duration(seconds: 15);
  
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

      // Descargar imagen con headers más robustos
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Sec-Fetch-Dest': 'image',
          'Sec-Fetch-Mode': 'no-cors',
          'Sec-Fetch-Site': 'cross-site',
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
    } on TimeoutException {
      print('⏱️ Timeout descargando imagen');
      return null;
    } catch (e) {
      print('❌ Error descargando imagen: $e');
      return null;
    }
  }

  /// Intenta descargar desde múltiples fuentes MEJORADAS
  static Future<String?> downloadFromMultipleSources(
    String monsterName,
    String monsterIndex,
  ) async {
    final sources = _getImageSources(monsterName, monsterIndex);
    
    for (int i = 0; i < sources.length; i++) {
      print('🔍 Fuente ${i + 1}/${sources.length}: ${sources[i]['name']}');
      final url = sources[i]['url'] as String;
      
      try {
        final result = await downloadAndSave(url, monsterName);
        if (result != null) {
          print('✅ Imagen encontrada en: ${sources[i]['name']}');
          return result;
        }
      } catch (e) {
        print('⚠️ Error en fuente ${sources[i]['name']}: $e');
      }
      
      // Pequeña pausa entre intentos
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    print('⚠️ No se pudo descargar imagen de ninguna fuente para: $monsterName');
    return null;
  }

  /// Obtiene lista de fuentes de imágenes ACTUALIZADAS Y FUNCIONALES
  static List<Map<String, dynamic>> _getImageSources(String name, String index) {
    final nameSlug = name.toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll("'", '')
        .replaceAll(',', '');
    
    final nameEncoded = Uri.encodeComponent(name);
    final searchTerm = Uri.encodeComponent('$name dnd monster fantasy');
    
    return [
      // 1. D&D 5e API oficial (la más confiable)
      {
        'name': 'D&D 5e API',
        'url': 'https://www.dnd5eapi.co/api/monsters/$index/image',
      },
      
      // 2. Unsplash API v2 (reemplaza source.unsplash.com)
      {
        'name': 'Unsplash Random',
        'url': 'https://images.unsplash.com/photo-1589254065878-42c9da997008?w=400&h=400&fit=crop&q=80',
      },
      
      // 3. Picsum con seed para consistencia
      {
        'name': 'Picsum Photos',
        'url': 'https://picsum.photos/seed/$index/400/400',
      },
      
      // 4. PlaceIMG (reemplazo de LoremFlickr)
      {
        'name': 'PlaceIMG',
        'url': 'https://placeimg.com/400/400/animals',
      },
      
      // 5. DummyImage como fallback
      {
        'name': 'DummyImage',
        'url': 'https://dummyimage.com/400x400/4a5568/ffffff&text=${nameEncoded.length > 20 ? nameEncoded.substring(0, 20) : nameEncoded}',
      },
      
      // 6. Placeholder generado
      {
        'name': 'Via Placeholder',
        'url': 'https://via.placeholder.com/400x400/8B4513/FFFFFF?text=${nameEncoded.length > 15 ? nameEncoded.substring(0, 15) : nameEncoded}',
      },
      
      // 7. RoboHash para imágenes únicas generadas
      {
        'name': 'RoboHash Monster',
        'url': 'https://robohash.org/$index?set=set2&size=400x400',
      },
      
      // 8. Pravatar (genera avatares únicos)
      {
        'name': 'Pravatar',
        'url': 'https://i.pravatar.cc/400?u=$index',
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

    // SVG: <svg
    if (header.length >= 4) {
      final headerStr = String.fromCharCodes(header.sublist(0, 4));
      if (headerStr == '<svg' || headerStr == '<?xml') {
        return true;
      }
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
  static Future<int> cleanupOldImages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'monster_images'));
      
      if (!await imagesDir.exists()) return 0;
      
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
      return deleted;
    } catch (e) {
      print('❌ Error en limpieza: $e');
      return 0;
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

  /// Obtiene el número de imágenes almacenadas
  static Future<int> getImageCount() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'monster_images'));
      
      if (!await imagesDir.exists()) return 0;
      
      final files = await imagesDir.list().toList();
      return files.where((f) => f is File).length;
    } catch (e) {
      return 0;
    }
  }

  /// Elimina todas las imágenes
  static Future<int> deleteAllImages() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(dir.path, 'monster_images'));
      
      if (!await imagesDir.exists()) return 0;
      
      final files = await imagesDir.list().toList();
      int deleted = 0;
      
      for (var entity in files) {
        if (entity is File) {
          await entity.delete();
          deleted++;
        }
      }
      
      print('🗑️ Eliminadas $deleted imágenes');
      return deleted;
    } catch (e) {
      print('❌ Error eliminando imágenes: $e');
      return 0;
    }
  }

  /// Genera una URL de imagen genérica basada en el nombre
  static String getPlaceholderUrl(String name, String index) {
    final nameEncoded = Uri.encodeComponent(name);
    // Usar RoboHash como placeholder más interesante
    return 'https://robohash.org/$index?set=set2&size=400x400';
  }
}