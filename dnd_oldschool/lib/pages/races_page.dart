// lib/pages/races_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/race.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

class RacesPage extends StatefulWidget {
  const RacesPage({super.key});

  @override
  State<RacesPage> createState() => _RacesPageState();
}

class _RacesPageState extends State<RacesPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();
  
  List<Race> _races = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    setState(() => _loading = true);
    final races = await _db.readAllRaces();
    setState(() {
      _races = races;
      _loading = false;
    });
  }

  Future<void> _syncRaces() async {
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
                Text('Sincronizando razas...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await _syncService.syncRaces();
      await _loadRaces();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Razas sincronizadas correctamente'),
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

  List<Race> get _filteredRaces {
    if (_searchQuery.isEmpty) return _races;
    return _races
        .where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razas'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar desde API',
            onPressed: _syncRaces,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRaces.isEmpty
                    ? _buildEmptyState()
                    : _buildRacesList(),
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
          hintText: 'Buscar razas...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _races.isEmpty
                ? 'No hay razas sincronizadas'
                : 'No se encontraron razas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (_races.isEmpty)
            ElevatedButton.icon(
              onPressed: _syncRaces,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sincronizar desde API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRacesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRaces.length,
      itemBuilder: (context, index) {
        final race = _filteredRaces[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: _buildRaceAvatar(race),
            title: Text(
              race.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: race.abilityMods.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    children: race.abilityMods.entries.map((e) {
                      final sign = e.value > 0 ? '+' : '';
                      return Chip(
                        label: Text(
                          '${e.key} $sign${e.value}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: race.color.withOpacity(0.2),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  )
                : const Text(
                    'Sin modificadores',
                    style: TextStyle(color: Colors.grey),
                  ),
            trailing: Icon(
              race.isFavorite ? Icons.star : Icons.star_border,
              color: race.isFavorite ? Colors.amber : null,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (race.imagePath != null &&
                        File(race.imagePath!).existsSync())
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(race.imagePath!),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      race.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Habilidades Especiales:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (race.specialAbilities.isEmpty)
                      const Text(
                        'Sin habilidades especiales',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ...race.specialAbilities.map((ability) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.stars,
                                size: 18,
                                color: race.color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ability,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRaceAvatar(Race race) {
    if (race.imagePath != null && File(race.imagePath!).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(race.imagePath!)),
        radius: 24,
      );
    }

    return CircleAvatar(
      backgroundColor: race.color.withOpacity(0.2),
      child: Icon(race.icon, color: race.color),
    );
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}