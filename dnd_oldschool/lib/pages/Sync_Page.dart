// lib/pages/sync_page.dart
import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final SyncService _syncService = SyncService();
  bool _isSyncing = false;
  double _progress = 0.0;
  String _statusMessage = 'Listo para sincronizar';
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

  Future<void> _startSyncAll() async {
    setState(() {
      _isSyncing = true;
      _progress = 0.0;
      _statusMessage = 'Iniciando sincronización completa...';
      _lastResult = null;
    });

    final result = await _syncService.syncAll(
      onProgress: (current, total) {
        setState(() {
          _progress = _syncService.progress;
          _statusMessage = 'Sincronizando: $current / $total elementos';
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _lastResult = result;
      _statusMessage = result['success'] == true
          ? 'Sincronización completa exitosa'
          : 'Error en sincronización';
    });

    await _loadStats();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización Completa'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_sync, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Sincronización con D&D 5e API',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sincroniza TODAS las secciones:\n'
                      '• Monstruos\n'
                      '• Hechizos\n'
                      '• Clases\n'
                      '• Razas\n'
                      '• Equipo\n\n'
                      'Imágenes se descargan y guardan localmente para uso offline.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Estadísticas
            if (_stats != null) ...[
              const Text('Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(Icons.pets, 'Total', '${_stats!['total_monsters'] ?? 0}', Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.cloud_done, 'API', '${_stats!['synced_from_api'] ?? 0}', Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.storage, 'Local', '${_stats!['local_only'] ?? 0}', Colors.orange),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _startSyncAll,
                icon: const Icon(Icons.sync, size: 28),
                label: Text(
                  _isSyncing ? 'Sincronizando...' : 'Sincronizar TODO',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_statusMessage, style: const TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                      ),
                      const SizedBox(height: 8),
                      Text('${(_progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Resultado
            if (_lastResult != null && !_isSyncing) ...[
              Card(
                color: _lastResult!['success'] == true ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastResult!['success'] == true ? Icons.check_circle : Icons.error,
                            color: _lastResult!['success'] == true ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          const Text('Resultado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_lastResult!['message'] ?? 'Sin mensaje'),
                      if (_lastResult!['details'] != null) ...[
                        const SizedBox(height: 8),
                        ...( _lastResult!['details'] as Map).entries.map((e) => Text('• ${e.key}: ${e.value['success']} OK, ${e.value['errors']} errores')),
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

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}