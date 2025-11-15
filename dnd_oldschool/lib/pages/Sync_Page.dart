// lib/pages/sync_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';
import '../providers/monster_provider.dart';
import '../widgets/StatCard.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final SyncService _syncService = SyncService();
  bool _isSyncing = false;
  double _progress = 0.0;
  String _statusMessage = '';
  Map<String, dynamic>? _lastResult;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _syncService.getSyncStats();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _startSync({int? limit}) async {
    setState(() {
      _isSyncing = true;
      _progress = 0.0;
      _statusMessage = 'Iniciando sincronización...';
      _lastResult = null;
    });

    final result = await _syncService.syncMonsters(
      limit: limit,
      onProgress: (current, total) {
        setState(() {
          _progress = current / total;
          _statusMessage = 'Sincronizando: $current / $total';
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _lastResult = result;
      _statusMessage = result['message'] ?? 'Completado';
    });

    // Recargar monstruos en el provider
    if (mounted) {
      final provider = Provider.of<MonsterProvider>(context, listen: false);
      await provider.loadMonsters();
    }

    await _loadStats();

    // Mostrar resultado
    if (mounted && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización API'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_download,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Sincronización con D&D 5e API',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Descarga monstruos desde la API oficial de D&D 5e. Las imágenes se guardarán localmente para uso offline.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estadísticas
            if (_stats != null) ...[
              const Text(
                'Estadísticas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.pets,
                      label: 'Total',
                      value: '${_stats!['total_monsters'] ?? 0}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.cloud_done,
                      label: 'Desde API',
                      value: '${_stats!['synced_from_api'] ?? 0}',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.storage,
                      label: 'Locales',
                      value: '${_stats!['local_only'] ?? 0}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Botones de sincronización
            const Text(
              'Opciones de Sincronización',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Sincronización rápida (10 monstruos)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : () => _startSync(limit: 10),
                icon: const Icon(Icons.flash_on),
                label: const Text('Sincronización Rápida (10)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Sincronización media (50 monstruos)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : () => _startSync(limit: 50),
                icon: const Icon(Icons.download),
                label: const Text('Sincronización Media (50)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Sincronización completa
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : () => _startSync(),
                icon: const Icon(Icons.cloud_sync),
                label: const Text('Sincronización Completa'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progreso
            if (_isSyncing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 8),
                      Text(
                        '${(_progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Resultado de última sincronización
            if (_lastResult != null && !_isSyncing) ...[
              Card(
                color: _lastResult!['success'] == true
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastResult!['success'] == true
                                ? Icons.check_circle
                                : Icons.error,
                            color: _lastResult!['success'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Resultado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_lastResult!['message'] ?? 'Sin mensaje'),
                      if (_lastResult!['synced'] != null) ...[
                        const SizedBox(height: 8),
                        Text('✅ Sincronizados: ${_lastResult!['synced']}'),
                        Text('❌ Errores: ${_lastResult!['errors'] ?? 0}'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}