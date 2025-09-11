import 'package:flutter/material.dart';
import '../app_router.dart';


class HomePage extends StatelessWidget {
const HomePage({Key? key}) : super(key: key);


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('D&D OldSchool')),
drawer: Drawer(
child: ListView(
padding: EdgeInsets.zero,
children: [
const DrawerHeader(
decoration: BoxDecoration(color: Colors.brown),
child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 20)),
),
ListTile(
leading: const Icon(Icons.book),
title: const Text('Ediciones'),
onTap: () => Navigator.of(context).pushNamed(AppRouter.editions),
),
ListTile(
leading: const Icon(Icons.pets),
title: const Text('Bestiario'),
onTap: () => Navigator.of(context).pushNamed(AppRouter.monsters),
),
ListTile(
leading: const Icon(Icons.rule),
title: const Text('Reglas antiguas'),
onTap: () {},
),
],
),
),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Bienvenido al Compendium OldSchool', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
const Text('Explora ediciones, módulos, monstruos y reglas clásicas.'),
const SizedBox(height: 20),
ElevatedButton.icon(
onPressed: () => Navigator.of(context).pushNamed(AppRouter.monsters),
icon: const Icon(Icons.pets),
label: const Text('Ir al Bestiario'),
),
],
),
),
);
}
}