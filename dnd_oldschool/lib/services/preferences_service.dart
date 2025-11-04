
import 'package:shared_preferences/shared_preferences.dart';


/// Servicio para gestionar las preferencias del usuario
class PreferencesService {
  static final PreferencesService instance = PreferencesService._init();
  SharedPreferences? _prefs;

  PreferencesService._init();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== PREFERENCIAS ==========

  /// Edición favorita por defecto
  String get defaultEdition => _prefs?.getString('default_edition') ?? 'Todas';
  Future<void> setDefaultEdition(String edition) async {
    await _prefs?.setString('default_edition', edition);
  }

  /// Tema de la aplicación (light, dark, parchment)
  String get theme => _prefs?.getString('theme') ?? 'parchment';
  Future<void> setTheme(String theme) async {
    await _prefs?.setString('theme', theme);
  }

  /// Mostrar imágenes automáticamente
  bool get showImages => _prefs?.getBool('show_images') ?? true;
  Future<void> setShowImages(bool value) async {
    await _prefs?.setBool('show_images', value);
  }

  /// Ordenamiento por defecto
  String get defaultSort => _prefs?.getString('default_sort') ?? 'name_asc';
  Future<void> setDefaultSort(String sort) async {
    await _prefs?.setString('default_sort', sort);
  }

  /// Mostrar solo favoritos en inicio
  bool get showFavoritesOnly => _prefs?.getBool('show_favorites_only') ?? false;
  Future<void> setShowFavoritesOnly(bool value) async {
    await _prefs?.setBool('show_favorites_only', value);
  }

  /// Mostrar descripción completa en listas
  bool get showFullDescription =>
      _prefs?.getBool('show_full_description') ?? false;
  Future<void> setShowFullDescription(bool value) async {
    await _prefs?.setBool('show_full_description', value);
  }

  /// Tamaño de fuente
  double get fontSize => _prefs?.getDouble('font_size') ?? 14.0;
  Future<void> setFontSize(double size) async {
    await _prefs?.setDouble('font_size', size);
  }

  /// Restablecer todas las preferencias
  Future<void> resetAll() async {
    await _prefs?.clear();
  }
}