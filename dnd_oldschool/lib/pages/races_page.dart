// lib/pages/races_page.dart
import 'package:flutter/material.dart';
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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    final racesDB = await _db.readAllRaces();
    setState(() => _races = racesDB);
  }

  /// =====================================================
  ///   METODO CORRECTO _syncRaces()
  /// =====================================================
  Future<void> _syncRaces({int limit = 20}) async {
  setState(() => _loading = true);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Sincronizando Razas"),
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: _syncService.progress > 0 ? _syncService.progress : null,
            ),
            const SizedBox(height: 16),
            Text(
              _syncService.progress > 0
                  ? '${(_syncService.progress * 100).toStringAsFixed(0)}%'
                  : "Iniciando...",
            ),
          ],
        ),
      ),
    ),
  );

  try {
    await _syncService.syncRaces(
      limit: limit,
      onProgress: (current, total) {
        setState(() => _syncService.progress = current / total);
      },
    );

    await _loadRaces();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Razas sincronizadas correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al sincronizar razas: $e"),
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


  /// =====================================================
  ///   WIDGET PRINCIPAL
  /// =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Razas"),
        actions: [
          IconButton(
            onPressed: _syncRaces,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _races.length,
              itemBuilder: (context, index) {
                final race = _races[index];
                return ListTile(
                  title: Text(race.name),
                  subtitle: Text("Velocidad: ${race.speed} ft"),
                );
              },
            ),
    );
  }
}