import 'package:flutter/material.dart';
import '../models/monster.dart';
import '../app_router.dart';


class MonstersListPage extends StatelessWidget {
const MonstersListPage({super.key});


@override
Widget build(BuildContext context) {
final monsters = Monster.sample();


return Scaffold(
appBar: AppBar(title: const Text('Bestiario')),
body: ListView.separated(
padding: const EdgeInsets.all(12),
itemBuilder: (context, index) {
final m = monsters[index];
return ListTile(
leading: Image.asset('assets/images/placeholder_monster.png', width: 48, height: 48),
title: Text(m.name),
subtitle: Text('Edición: ${m.edition} • HP: ${m.hp}'),
onTap: () => Navigator.of(context).pushNamed(
AppRouter.monsterDetail,
arguments: {'id': m.id, 'name': m.name},
),
);
},
separatorBuilder: (_, __) => const Divider(),
itemCount: monsters.length,
),
);
}
}