import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageDownloader {
  static final Dio _dio = Dio();

  static Future<String?> downloadAndSave(String imageUrl, String monsterName) async {
    try {
      final hash = md5.convert(utf8.encode(imageUrl)).toString().substring(0, 8);
      final fileName = '${monsterName.toLowerCase().replaceAll(' ', '_')}_$hash.png';
      final dir = await getApplicationDocumentsDirectory();
      final filePath = p.join(dir.path, 'image', fileName);
      final file = File(filePath);

      // Si ya existe y es válida, reutilizar
      if (await file.exists()) {
        if (await _isValidImage(file)) {
          return filePath;
        } else {
          await file.delete();
        }
      }

      // Crear carpeta
      await Directory(p.dirname(filePath)).create(recursive: true);

      // Descargar
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 400,
        ),
      );

      // Validar Content-Type
      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.startsWith('image/')) {
        print('No es imagen: $contentType');
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
      print('Error descargando imagen: $e');
      return null;
    }
  }

  /// Verifica si el archivo es una imagen válida por firma de bytes
  static Future<bool> _isValidImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;

      final header = bytes.sublist(0, bytes.length.clamp(0, 12));

      // JPEG: FF D8 FF
      if (header.length >= 3 &&
          header[0] == 0xFF &&
          header[1] == 0xD8 &&
          header[2] == 0xFF) {
        return true;
      }

      // PNG: 89 50 4E 47
      if (header.length >= 4 &&
          header[0] == 0x89 &&
          header[1] == 0x50 &&
          header[2] == 0x4E &&
          header[3] == 0x47) {
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

      return false;
    } catch (e) {
      return false;
    }
  }
}