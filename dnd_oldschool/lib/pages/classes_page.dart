/// lib/pages/classes_page.dart
library;
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/character_class.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();
  
  List<CharacterClass> _classes = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    final classes = await _db.readAllClasses();
    setState(() {
      _classes = classes;
      _loading = false;
    });
  }

  Future<void> _syncClasses() async {
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
                Text('Sincronizando clases...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // === REEMPLAZAR EL MÉTODO _syncClasses() COMPLETO ===
Future<void> _syncClasses() async {
  setState(() => _loading = true);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sincronizando Clases'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: _syncService.progress > 0 ? _syncService.progress : null,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                ),
                const SizedBox(height: 16),
                Text(
                  _syncService.progress > 0
                      ? '${(_syncService.progress * 100).toStringAsFixed(0)}%'
                      : 'Iniciando...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );
    },
  );

  try {
    await _syncService.syncClasses(
      onProgress: (current, total) {
        setState(() {
          _syncService.progress = current / total;
        });
        // Forzar actualización del diálogo
        if (mounted) {
          Navigator.of(context).pop();
          _syncClasses(); // Reabrir con nuevo progreso
        }
      },
    );

    await _loadClasses();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clases sincronizadas correctamente'),
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
  }
}
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Clases sincronizadas correctamente'),
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

  List<CharacterClass> get _filteredClasses {
    if (_searchQuery.isEmpty) return _classes;
    return _classes
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases de Personaje'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar desde API',
            onPressed: _syncClasses,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClasses.isEmpty
                    ? _buildEmptyState()
                    : _buildClassesList(),
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
          hintText: 'Buscar clases...',
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
          Icon(Icons.school, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _classes.isEmpty
                ? 'No hay clases sincronizadas'
                : 'No se encontraron clases',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          if (_classes.isEmpty)
            ElevatedButton.icon(
              onPressed: _syncClasses,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sincronizar desde API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredClasses.length,
      itemBuilder: (context, index) {
        final charClass = _filteredClasses[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: _buildClassAvatar(charClass),
            title: Text(
              charClass.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dado de Golpe: ${charClass.hitDie}'),
                Text(
                  'Requisito: ${charClass.primeRequisite}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              charClass.isFavorite ? Icons.star : Icons.star_border,
              color: charClass.isFavorite ? Colors.amber : null,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (charClass.imagePath != null &&
                        File(charClass.imagePath!).existsSync())
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(charClass.imagePath!),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      charClass.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection('Armas Permitidas', charClass.allowedWeapons),
                    _buildInfoSection('Armadura Permitida', charClass.allowedArmor),
                    const SizedBox(height: 16),
                    const Text(
                      'Habilidades:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...charClass.abilities.map((ability) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: charClass.color,
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

  Widget _buildClassAvatar(CharacterClass charClass) {
    if (charClass.imagePath != null && File(charClass.imagePath!).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(charClass.imagePath!)),
        radius: 24,
      );
    }

    return CircleAvatar(
      backgroundColor: charClass.color.withOpacity(0.2),
      child: Icon(charClass.icon, color: charClass.color),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              style: const TextStyle(fontSize: 14),
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