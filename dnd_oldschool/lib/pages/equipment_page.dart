import 'package:flutter/material.dart';
import 'package:dnd_oldschool/models/equipment.dart';
class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  String _selectedType = 'Todos';
  final List<String> _types = ['Todos', 'Arma', 'Armadura', 'Objeto'];

  @override
  Widget build(BuildContext context) {
    final equipment = Equipment.getSample();
    final filtered = _selectedType == 'Todos'
        ? equipment
        : equipment.where((e) => e.type == _selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamiento'),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _types.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() => _selectedType = type);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Lista
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getIconForType(item.type)),
                    ),
                    title: Text(item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.cost} • ${item.weight}'),
                        if (item.damage != null) Text('Daño: ${item.damage}'),
                        if (item.acBonus != null) Text(item.acBonus!),
                      ],
                    ),
                    onTap: () => _showDetails(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Arma':
        return Icons.sports_martial_arts;
      case 'Armadura':
        return Icons.shield;
      case 'Objeto':
        return Icons.inventory;
      default:
        return Icons.help;
    }
  }

  void _showDetails(Equipment item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${item.type}'),
            Text('Costo: ${item.cost}'),
            Text('Peso: ${item.weight}'),
            if (item.damage != null) Text('Daño: ${item.damage}'),
            if (item.acBonus != null) Text('AC: ${item.acBonus}'),
            const SizedBox(height: 12),
            Text(item.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
