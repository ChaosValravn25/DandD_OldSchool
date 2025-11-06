// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/theme.dart';

/// Provider para gestionar el tema de la aplicación
/// Soporta 3 temas: Pergamino (default), Claro y Oscuro
class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService.instance;
  String _currentTheme = 'parchment';

  ThemeProvider() {
    _loadTheme();
  }

  /// Obtiene el tema actual
  String get currentTheme => _currentTheme;

  /// Verifica si es tema oscuro
  bool get isDarkMode => _currentTheme == 'dark';

  /// Verifica si es tema claro
  bool get isLightMode => _currentTheme == 'light';

  /// Verifica si es tema pergamino
  bool get isParchmentMode => _currentTheme == 'parchment';

  /// Obtiene el ThemeData según el tema actual
  ThemeData get themeData {
    switch (_currentTheme) {
      case 'dark':
        return darkTheme();
      case 'light':
        return lightTheme();
      case 'parchment':
      default:
        return parchmentTheme();
    }
  }

  /// Carga el tema guardado en preferencias
  Future<void> _loadTheme() async {
    _currentTheme = _prefs.theme;
    notifyListeners();
  }

  /// Cambia el tema
  Future<void> setTheme(String theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      await _prefs.setTheme(theme);
      notifyListeners();
    }
  }

  /// Alterna entre tema claro y oscuro (útil para toggle switch)
  Future<void> toggleDarkMode() async {
    final newTheme = _currentTheme == 'dark' ? 'light' : 'dark';
    await setTheme(newTheme);
  }

  /// Cicla entre los 3 temas disponibles
  Future<void> cycleTheme() async {
    String nextTheme;
    switch (_currentTheme) {
      case 'parchment':
        nextTheme = 'light';
        break;
      case 'light':
        nextTheme = 'dark';
        break;
      case 'dark':
      default:
        nextTheme = 'parchment';
        break;
    }
    await setTheme(nextTheme);
  }
  
}