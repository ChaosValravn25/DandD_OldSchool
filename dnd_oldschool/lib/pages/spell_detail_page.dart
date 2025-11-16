import 'package:flutter/material.dart';
import 'package:dnd_oldschool/models/spell.dart';
class SpellDetailPage extends StatelessWidget {
  final Spell spell;

  const SpellDetailPage({super.key, required this.spell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spell.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Nivel', '${spell.level}'),
            _InfoRow('Escuela', spell.school),
            _InfoRow('Tiempo de Lanzamiento', spell.castingTime),
            _InfoRow('Rango', spell.spellRange),
            _InfoRow('Componentes', spell.components),
            _InfoRow('Duración', spell.duration),
            const SizedBox(height: 16),
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(spell.description, style: const TextStyle(height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}