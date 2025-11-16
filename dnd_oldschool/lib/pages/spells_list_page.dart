import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../models/spell.dart';
import '../services/database_helper.dart';

class SpellsListPage extends StatefulWidget {
  const SpellsListPage({super.key});

  @override
  State<SpellsListPage> createState() => _SpellsListPage();
}

class _SpellsListPage extends State<SpellsListPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();
  List<Spell> _spells = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSpells();
  }

  Future<void> _loadSpells() async {
    final spellsDB = await _db.readAllSpells();
    setState(() => _spells = spellsDB);
  }

  /// =====================================================
  ///   METODO CORRECTO _syncSpells()
  /// =====================================================
  Future<void> _syncSpells({int limit = 50}) async {
  setState(() => _loading = true);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Sincronizando Hechizos"),
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
    await _syncService.syncSpells(
      limit: limit,
      onProgress: (current, total) {
        setState(() => _syncService.progress = current / total);
      },
    );

    await _loadSpells();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hechizos sincronizados correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al sincronizar hechizos: $e"),
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
        title: const Text("Hechizos"),
        actions: [
          IconButton(
            onPressed: _syncSpells,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _spells.length,
              itemBuilder: (context, index) {
                final spell = _spells[index];
                return ListTile(
                  title: Text(spell.name),
                  subtitle: Text(spell.school),
                );
              },
            ),
    );
  }
}
