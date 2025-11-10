import 'package:flutter/material.dart';
import '../pages/rules_comparison_page.dart';
class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparación de Reglas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Comparación entre Ediciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RuleComparisonCard(
            title: 'Sistema de Ataque',
            rules: {
              'OD&D': 'Tablas de ataque por clase',
              'AD&D 1e': 'THAC0 por clase',
              'AD&D 2e': 'THAC0 estandarizado',
              '3e/3.5e': 'Bonus de Ataque Base (BAB)',
            },
          ),
          RuleComparisonCard(
            title: 'Clase de Armadura (AC)',
            rules: {
              'OD&D': 'AC descendente (9 es peor que 0)',
              'AD&D': 'AC descendente (-10 es mejor)',
              '3e/3.5e': 'AC ascendente (números altos mejor)',
            },
          ),
          RuleComparisonCard(
            title: 'Iniciativa',
            rules: {
              'OD&D': '1d6 por grupo',
              'AD&D 1e': 'Segmentos de combate',
              'AD&D 2e': '1d10 + modificadores',
              '3e/3.5e': '1d20 + Destreza',
            },
          ),
          RuleComparisonCard(
            title: 'Puntos de Golpe',
            rules: {
              'OD&D': 'Dado de golpe por nivel',
              'AD&D': 'Dado de golpe con CON',
              '3e/3.5e': 'Dado + modificador CON por nivel',
            },
          ),
        ],
      ),
    );
  }
}