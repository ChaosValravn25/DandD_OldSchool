import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'providers/monster_provider.dart';
import 'services/preferences_service.dart';
import 'providers/theme_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
void main() async {
  // Asegurar que Flutter esté inicializado antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
   }

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
        
        // Provider para gestionar temas
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        
        // Aquí puedes agregar más providers en el futuro:
        //ChangeNotifierProvider(create: (_) => SpellProvider()),
        //ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'D&D Old School Compendium',
            debugShowCheckedModeBanner: false,
            
            // Aplicar tema dinámico del ThemeProvider
            theme: themeProvider.themeData,
            
            // Configuración de rutas
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}