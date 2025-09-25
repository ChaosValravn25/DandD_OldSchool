import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/editions_page.dart';
import 'pages/monsters_list_page.dart';
import 'pages/monster_detail_page.dart';


class AppRouter {
static const String splash = '/';
static const String home = '/home';
static const String editions = '/editions';
static const String monsters = '/monsters';
static const String monsterDetail = '/monster_detail';


static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
    return MaterialPageRoute(builder: (_) => const SplashPage());
      case home:
    return MaterialPageRoute(builder: (_) => const HomePage());
      case editions:
    return MaterialPageRoute(builder: (_) => const EditionsPage());
      case monsters:
    return MaterialPageRoute(builder: (_) => const MonstersListPage());
      case monsterDetail:
    final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
        builder: (_) => MonsterDetailPage(id: args?['id'], monsterName: args?['name']),
        );
  default:
      return MaterialPageRoute(
            builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
        ),
      );
    }
  }
}