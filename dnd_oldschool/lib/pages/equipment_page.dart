// lib/pages/equipment_page.dart
import 'package:flutter/material.dart';
import '../models/equipment.dart';

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
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No hay equipo'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTypeColor(item.type),
                            child: Icon(_getIconForType(item.type), color: Colors.white),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.cost} • ${item.weight}'),
                              if (item.damage != null) Text('Daño: ${item.damage}'),
                              if (item.acBonus != null) Text('CA: ${item.acBonus}'),
                            ],
                          ),
                          trailing: Icon(
                            item.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: item.isFavorite ? Colors.red : null,
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

  Widget _buildFilterChips() {
    return Container(
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
                onSelected: (selected) => setState(() => _selectedType = type),
                backgroundColor: _getTypeColor(type),
                selectedColor: _getTypeColor(type).withOpacity(0.3),
                labelStyle: TextStyle(
                  color: _selectedType == type ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Arma': return Colors.red.shade700;
      case 'Armadura': return Colors.blue.shade700;
      case 'Objeto': return Colors.green.shade700;
      default: return Colors.grey.shade700;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Arma': return Icons.sports_martial_arts;
      case 'Armadura': return Icons.shield;
      case 'Objeto': return Icons.inventory;
      default: return Icons.help;
    }
  }

  void _showDetails(Equipment item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: ${item.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Costo: ${item.cost}'),
              Text('Peso: ${item.weight}'),
              if (item.damage != null) Text('Daño: ${item.damage}'),
              if (item.acBonus != null) Text('CA: ${item.acBonus}'),
              if (item.strengthRequirement != null) Text('FUE requerida: ${item.strengthRequirement}'),
              if (item.stealthDisadvantage) const Text('Desventaja en Sigilo'),
              const Divider(),
              Text(item.description),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}