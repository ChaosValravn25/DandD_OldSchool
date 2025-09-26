import 'package:flutter/material.dart';

// EditionsPage: muestra una lista de ediciones antiguas de D&D
class EditionsPage extends StatelessWidget {
const EditionsPage({super.key});


final List<String> editions = const ['OD&D', 'AD&D 1e', 'AD&D 2e', '3e', '3.5e'];


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Ediciones antiguas')),
body: ListView.builder(
itemCount: editions.length,
itemBuilder: (context, index) {
final ed = editions[index];
return ListTile(
leading: const Icon(Icons.history_edu),
title: Text(ed),
subtitle: const Text('Resumen y recursos de la edición'),
onTap: () {
// aquí podrías navegar a una pantalla de detalle por edición
},
);
},
),
);
}
}