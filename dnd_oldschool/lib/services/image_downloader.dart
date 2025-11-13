import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

class ImageDownloader {
  static final Dio _dio = Dio();

  /// Descarga y guarda imagen solo si es válida
  static Future<String?> downloadAndSave(String imageUrl, String monsterName) async {
    try {
      // Generar ruta
      final hash = md5.convert(utf8.encode(imageUrl)).toString().substring(0, 8);
      final fileName = '${monsterName.toLowerCase().replaceAll(' ', '_')}_$hash.png';
      final dir = await getApplicationDocumentsDirectory();
      final filePath = p.join(dir.path, 'images', fileName);
      final file = File(filePath);

      // Si ya existe y es válido, reutilizar
      if (await file.exists()) {
        if (await _isValidImage(file)) {
          return filePath;
        } else {
          await file.delete(); // Borrar corrupto
        }
      }

      // Crear carpeta
      await Directory(p.dirname(filePath)).create(recursive: true);

      // Descargar con validación
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 400,
        ),
      );

      // Verificar Content-Type
      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.startsWith('image/')) {
        print('No es imagen: $contentType - $imageUrl');
        return null;
      }

      // Guardar
      await file.writeAsBytes(response.data);
      if (await _isValidImage(file)) {
        return filePath;
      } else {
        await file.delete();
        return null;
      }
    } catch (e) {
      print('Error descargando $imageUrl: $e');
      return null;
    }
  }

  /// Verifica si el archivo es una imagen válida
  static Future<bool> _isValidImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;

      // Firmas comunes de imágenes
      final header = bytes.sublist(0, bytes.length.clamp(0, 12));
      return header.startsWith([0xFF, 0xD8, 0xFF]) || // JPEG
          header.startsWith([0x89, 0x50, 0x4E, 0x47]) || // PNG
          header.startsWith([0x47, 0x49, 0x46, 0x38]) || // GIF
          header.startsWith([0x52, 0x49, 0x46, 0x46]); // WEBP
    } catch (e) {
      return false;
    }
  }
}