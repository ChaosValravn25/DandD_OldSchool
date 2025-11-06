import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'providers/monster_provider.dart';
import 'services/preferences_service.dart';

void main() async {
  // Asegurar que Flutter esté inicializado antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicio de preferencias
  await PreferencesService.instance.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider para gestionar monstruos
        ChangeNotifierProvider(
          create: (_) => MonsterProvider()..loadMonsters(),
        ),
        
        // Aquí puedes agregar más providers en el futuro:
        // ChangeNotifierProvider(create: (_) => SpellProvider()),
        // ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: Consumer<MonsterProvider>(
        builder: (context, monsterProvider, child) {
          // Obtener tema de preferencias
          final themeMode = PreferencesService.instance.theme;
          
          return MaterialApp(
            title: 'D&D Old School Compendium',
            debugShowCheckedModeBanner: false,
            
            // Aplicar tema según preferencias del usuario
            theme: _getThemeData(themeMode),
            
            // Configuración de rutas
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }

  /// Obtiene el tema según las preferencias del usuario
  ThemeData _getThemeData(String themeType) {
    switch (themeType) {
      case 'dark':
        return _darkTheme();
      case 'light':
        return _lightTheme();
      case 'parchment':
      default:
        return _parchmentTheme();
    }
  }

  /// Tema pergamino (por defecto) - Estilo D&D clásico
  ThemeData _parchmentTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colores principales
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B4513), // Marrón cuero
        primary: const Color(0xFF8B4513),
        secondary: const Color(0xFFD4AF37), // Dorado viejo
        surface: const Color(0xFFEDE3D3), // Papel envejecido
        background: const Color(0xFFF7EFE0), // Pergamino
        error: const Color(0xFFB22222), // Rojo sangre
      ),
      
      // Scaffold
      scaffoldBackgroundColor: const Color(0xFFF7EFE0),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 3,
        color: const Color(0xFFEDE3D3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.brown.shade300, width: 1),
        ),
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFFF7EFE0),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFEDE3D3),
        selectedItemColor: Color(0xFF8B4513),
        unselectedItemColor: Colors.brown,
        elevation: 8,
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFD4AF37),
        foregroundColor: Color(0xFF8B4513),
      ),
    );
  }

  /// Tema claro
  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        primary: Colors.brown,
        secondary: Colors.amber,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Tema oscuro
  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C1810),
        brightness: Brightness.dark,
        primary: const Color(0xFF8B7355),
        secondary: const Color(0xFFCC3333),
        surface: const Color(0xFF2D2D2D),
        background: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: Color(0xFF2C1810),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}