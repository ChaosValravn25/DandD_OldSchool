import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

class ImageDownloader {
  static final Dio _dio = Dio();

  /// Descarga y guarda imagen localmente
  static Future<String?> downloadAndSave(String imageUrl, String monsterName) async {
    try {
      // Generar nombre único
      final hash = md5.convert(utf8.encode(imageUrl)).toString().substring(0, 8);
      final fileName = '${monsterName.toLowerCase().replaceAll(' ', '_')}_$hash.png';
      final dir = await getApplicationDocumentsDirectory();
      final filePath = p.join(dir.path, 'images', fileName);

      final file = File(filePath);
      if (await file.exists()) {
        return filePath; // Ya existe
      }

      // Crear carpeta
      await Directory(p.dirname(filePath)).create(recursive: true);

      // Descargar
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);
      return filePath;
    } catch (e) {
      print('Error descargando imagen $imageUrl: $e');
      return null;
    }
  }
}