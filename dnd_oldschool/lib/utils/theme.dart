import 'package:flutter/material.dart';

 /// Tema pergamino (por defecto) - Estilo D&D clásico
  ThemeData parchmentTheme() {
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
        onPrimary: Colors.white,
        onSecondary: const Color(0xFF8B4513),
        onSurface: Colors.black87,
        onBackground: Colors.black87,
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
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
      
      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF8B4513),
        ),
      ),
      
      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF8B4513),
          side: const BorderSide(color: Color(0xFF8B4513)),
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
      
      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.brown.shade300,
        thickness: 1,
      ),
    );
  }

  /// Tema claro
  ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.brown,
        primary: Colors.brown,
        secondary: Colors.amber,
        surface: Colors.grey.shade50,
        background: Colors.white,
      ),
      
      scaffoldBackgroundColor: Colors.white,
      
      appBarTheme: const AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.brown,
      ),
    );
  }

  /// Tema oscuro
  ThemeData darkTheme() {
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
        error: const Color(0xFFFF5252),
      ),
      
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      
      appBarTheme: const AppBarTheme(
        elevation: 2,
        centerTitle: true,
        backgroundColor: Color(0xFF2C1810),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      cardTheme: CardThemeData(
      elevation: 3,
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
       ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B7355),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFCC3333),
        foregroundColor: Colors.white,
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3D3D3D),
        thickness: 1,
      ),
    );
  }
