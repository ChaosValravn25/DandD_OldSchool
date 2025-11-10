import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/editions_page.dart';
import 'pages/edition_detail_page.dart';
import 'pages/monsters_list_page.dart';
import 'pages/monster_detail_page.dart';
import 'pages/monster_form_page.dart';
import 'pages/preferences_page.dart';
import 'pages/rating_page.dart';
import 'pages/about_page.dart';
import 'pages/spells_list_page.dart';
import 'pages/spell_detail_page.dart';
import 'pages/classes_page.dart';
import 'pages/races_page.dart';
import 'pages/equipment_page.dart';
import 'pages/rules_page.dart';

/// Gestiona todas las rutas de navegación de la aplicación
class AppRouter {
  // ========== RUTAS PRINCIPALES ==========
  static const String splash = '/';
  static const String home = '/home';
  
  // ========== BESTIARIO ==========
  static const String monsters = '/monsters';
  static const String monsterDetail = '/monster_detail';
  static const String monsterForm = '/monster_form';
  
  // ========== CONTENIDO ==========
  static const String editions = '/editions';
  static const String editionDetail = '/edition_detail';
  static const String spells = '/spells';
  static const String spellDetail = '/spell_detail';
  static const String classes = '/classes';
  static const String races = '/races';
  static const String equipment = '/equipment';
  static const String rules = '/rules';
  
  // ========== CONFIGURACIÓN Y EXTRAS ==========
  static const String preferences = '/preferences';
  static const String about = '/about';
  static const String rating = '/rating';

  /// Genera las rutas basadas en el nombre
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ========== RUTAS PRINCIPALES ==========
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      // ========== BESTIARIO ==========
      case monsters:
        return MaterialPageRoute(builder: (_) => const MonstersListPage());
      
      case monsterDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MonsterDetailPage(
            id: args?['id'],
            monsterName: args?['name'],
          ),
        );
      
      case monsterForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MonsterFormPage(
            monster: args?['monster'],
          ),
        );
      
      // ========== CONTENIDO ==========
      case editions:
        return MaterialPageRoute(builder: (_) => const EditionsPage());
      
      case editionDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditionDetailPage(
            edition: args?['edition'],
          ),
        );
      
      case spells:
        return MaterialPageRoute(builder: (_) => const SpellsListPage());
      
      case spellDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SpellDetailPage(
            spell: args?['spell'],
          ),
        );
      
      case classes:
        return MaterialPageRoute(builder: (_) => const ClassesPage());
      
      case races:
        return MaterialPageRoute(builder: (_) => const RacesPage());
      
      case equipment:
        return MaterialPageRoute(builder: (_) => const EquipmentPage());
      
      case rules:
        return MaterialPageRoute(builder: (_) => const RulesPage());
      
      // ========== CONFIGURACIÓN Y EXTRAS ==========
      case preferences:
        return MaterialPageRoute(builder: (_) => const PreferencesPage());
      
      case about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      
      case rating:
        return MaterialPageRoute(builder: (_) => const RatingPage());
      
      // ========== RUTA NO ENCONTRADA ==========
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error 404')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ruta no encontrada',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La ruta "${settings.name}" no existe',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(home),
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al Inicio'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}