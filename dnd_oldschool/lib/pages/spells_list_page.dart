// lib/pages/spells_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/spell.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

class SpellsListPage extends StatefulWidget {
  const SpellsListPage({super.key});

  @override
  State<SpellsListPage> createState() => _SpellsPageState();
}

class _SpellsPageState extends State<SpellsListPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();
  
  List<Spell> _spells = [];
  List<Spell> _filteredSpells = [];
  bool _loading = true;
  int? _selectedLevel;
  String _selectedSchool = 'Todas';
  String _searchQuery = '';
  
  final List<String> _schools = [
    'Todas',
    'Abjuration',
    'Conjuration',
    'Divination',
    'Enchantment',
    'Evocation',
    'Illusion',
    'Necromancy',
    'Transmutation',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpells();
  }

  Future<void> _loadSpells() async {
    setState(() => _loading = true);
    final spells = await _db.readAllSpells();
    setState(() {
      _spells = spells;
      _applyFilters();
      _loading = false;
    });
  }

  void _applyFilters() {
    _filteredSpells = _spells.where((spell) {
      final matchesLevel = _selectedLevel == null || spell.level == _selectedLevel;
      final matchesSchool = _selectedSchool == 'Todas' || 
          spell.school.toLowerCase().contains(_selectedSchool.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          spell.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLevel && matchesSchool && matchesSearch;
    }).toList();
  }

  Future<void> _syncSpells() async {
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
                Text('Sincronizando hechizos...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await _syncService.syncSpells(limit: 50);
      await _loadSpells();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hechizos sincronizados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hechizos'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar desde API',
            onPressed: _syncSpells,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildLevelFilter(),
          _buildSchoolFilter(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSpells.isEmpty
                    ? _buildEmptyState()
                    : _buildSpellsList(),
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
          hintText: 'Buscar hechizos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildLevelFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 10,
        itemBuilder: (context, index) {
          final level = index;
          final isSelected = _selectedLevel == level;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(level == 0 ? 'Truco' : 'Nivel $level'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedLevel = selected ? level : null;
                  _applyFilters();
                });
              },
              backgroundColor: Colors.purple.shade100,
              selectedColor: Colors.purple,
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

  Widget _buildSchoolFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _schools.length,
        itemBuilder: (context, index) {
          final school = _schools[index];
          final isSelected = _selectedSchool == school;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(school),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSchool = school;
                  _applyFilters();
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _spells.isEmpty 
                ? 'No hay hechizos sincronizados'
                : 'No se encontraron hechizos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (_spells.isEmpty)
            ElevatedButton.icon(
              onPressed: _syncSpells,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sincronizar desde API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpellsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredSpells.length,
      itemBuilder: (context, index) {
        final spell = _filteredSpells[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildSpellAvatar(spell),
            title: Text(
              spell.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${spell.school} • Nivel ${spell.level}\n${spell.castingTime}',
            ),
            trailing: IconButton(
              icon: Icon(
                spell.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: spell.isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(spell),
            ),
            onTap: () => _showSpellDetails(spell),
          ),
        );
      },
    );
  }

  Widget _buildSpellAvatar(Spell spell) {
    if (spell.imagePath != null && File(spell.imagePath!).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(spell.imagePath!)),
      );
    }
    
    return CircleAvatar(
      backgroundColor: _getSchoolColor(spell.school),
      child: Text(
        spell.level.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSchoolColor(String school) {
    switch (school.toLowerCase()) {
      case 'abjuration': return Colors.blue;
      case 'conjuration': return Colors.green;
      case 'divination': return Colors.cyan;
      case 'enchantment': return Colors.pink;
      case 'evocation': return Colors.red;
      case 'illusion': return Colors.purple;
      case 'necromancy': return Colors.grey.shade800;
      case 'transmutation': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Future<void> _toggleFavorite(Spell spell) async {
    await _db.toggleFavoriteSpell(spell.id, !spell.isFavorite);
    await _loadSpells();
  }

  void _showSpellDetails(Spell spell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  _buildSpellAvatar(spell),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spell.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${spell.school} • Nivel ${spell.level}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      spell.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: spell.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      _toggleFavorite(spell);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildInfoRow('Tiempo de lanzamiento', spell.castingTime),
              _buildInfoRow('Alcance', spell.range),
              _buildInfoRow('Componentes', spell.components),
              _buildInfoRow('Duración', spell.duration),
              const SizedBox(height: 16),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                spell.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              style: const TextStyle(fontSize: 16),
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