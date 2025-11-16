// lib/pages/equipment_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/equipment.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();
  
  List<Equipment> _equipment = [];
  String _selectedType = 'Todos';
  String _searchQuery = '';
  bool _loading = true;
  
  final List<String> _types = [
    'Todos',
    'Weapon',
    'Armor',
    'Adventuring Gear',
    'Tools',
    'Mounts and Vehicles',
  ];

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() => _loading = true);
    final equipment = await _db.readAllEquipment();
    setState(() {
      _equipment = equipment;
      _loading = false;
    });
  }

  Future<void> _syncEquipment({int limit = 20}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sincronizando equipamiento...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await _syncService.syncEquipment(
      limit: limit,
      onProgress: (current, total) {
      setState(() {
        _syncService.progress = current / total;
      });
    },
  );

  await _loadEquipment();

  if (mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipamiento sincronizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }
} catch (e) {
  if (mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
} finally {
  setState(() {
    _loading = false;
    _syncService.progress = 0.0;
  });
}}




  List<Equipment> get _filteredEquipment {
    return _equipment.where((item) {
      final matchesType = _selectedType == 'Todos' || item.type == _selectedType;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamiento'),
        backgroundColor: Colors.orange.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar desde API',
            onPressed: _syncEquipment,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEquipment.isEmpty
                    ? _buildEmptyState()
                    : _buildEquipmentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar equipamiento...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = _selectedType == type;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_translateType(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedType = type);
              },
              backgroundColor: _getTypeColor(type).withOpacity(0.2),
              selectedColor: _getTypeColor(type),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  String _translateType(String type) {
    switch (type) {
      case 'Todos': return 'Todos';
      case 'Weapon': return 'Armas';
      case 'Armor': return 'Armaduras';
      case 'Adventuring Gear': return 'Aventura';
      case 'Tools': return 'Herramientas';
      case 'Mounts and Vehicles': return 'Monturas';
      default: return type;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _equipment.isEmpty
                ? 'No hay equipamiento sincronizado'
                : 'No se encontró equipamiento',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (_equipment.isEmpty)
            ElevatedButton.icon(
              onPressed: _syncEquipment,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sincronizar desde API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredEquipment.length,
      itemBuilder: (context, index) {
        final item = _filteredEquipment[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildItemAvatar(item),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.cost} • ${item.weight}'),
                if (item.damage != null)
                  Text(
                    'Daño: ${item.damage}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (item.acBonus != null)
                  Text(
                    'CA: ${item.acBonus}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: item.isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(item),
            ),
            onTap: () => _showDetails(item),
          ),
        );
      },
    );
  }

  Widget _buildItemAvatar(Equipment item) {
    if (item.imagePath != null && File(item.imagePath!).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(item.imagePath!)),
      );
    }

    return CircleAvatar(
      backgroundColor: _getTypeColor(item.type),
      child: Icon(_getIconForType(item.type), color: Colors.white),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Weapon': return Colors.red.shade700;
      case 'Armor': return Colors.blue.shade700;
      case 'Adventuring Gear': return Colors.green.shade700;
      case 'Tools': return Colors.orange.shade700;
      case 'Mounts and Vehicles': return Colors.purple.shade700;
      default: return Colors.grey.shade700;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Weapon': return Icons.sports_martial_arts;
      case 'Armor': return Icons.shield;
      case 'Adventuring Gear': return Icons.backpack;
      case 'Tools': return Icons.build;
      case 'Mounts and Vehicles': return Icons.pets; // Cambiado de directions_horse
      default: return Icons.inventory;
    }
  }

  Future<void> _toggleFavorite(Equipment item) async {
    await _db.toggleFavoriteEquipment(item.id, !item.isFavorite);
    await _loadEquipment();
  }

  void _showDetails(Equipment item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            _buildItemAvatar(item),
            const SizedBox(width: 12),
            Expanded(child: Text(item.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tipo', _translateType(item.type)),
              _buildDetailRow('Costo', item.cost),
              _buildDetailRow('Peso', item.weight),
              if (item.damage != null)
                _buildDetailRow('Daño', item.damage!, color: Colors.red),
              if (item.damageType != null)
                _buildDetailRow('Tipo de daño', item.damageType!),
              if (item.acBonus != null)
                _buildDetailRow('CA', item.acBonus.toString(), color: Colors.blue),
              if (item.strengthRequirement != null)
                _buildDetailRow('FUE requerida', item.strengthRequirement!),
              if (item.stealthDisadvantage)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Desventaja en Sigilo',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(item.description),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
    