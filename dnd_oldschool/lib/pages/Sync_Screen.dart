// lib/pages/Sync_Screen.dart
import 'package:flutter/material.dart';
import '../services/sync_service.dart';  // ← IMPORT CORREGIDO
import '../services/database_helper.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncService _syncService = SyncService();  // ← OK
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  bool _isSyncing = false;
  double _progress = 0.0;
  String _statusMessage = 'Listo para sincronizar';
  Map<String, dynamic>? _syncResult;
  Map<String, dynamic>? _stats;
  int _currentMonster = 0;
  int _totalMonsters = 0;

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
      _syncResult = null;
      _currentMonster = 0;
      _totalMonsters = 0;
    });

    final result = await _syncService.syncMonsters(
      limit: limit,
      onProgress: (current, total) {
        setState(() {
          _currentMonster = current;
          _totalMonsters = total;
          _progress = _syncService.progress;
          _statusMessage = 'Sincronizando: $current de $total monstruos';
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _syncResult = result;
      _statusMessage = result['success'] 
          ? '✅ Sincronización completada' 
          : '❌ Error en sincronización';
    });

    await _loadStats();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Sincronización finalizada'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _clearSync() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar limpieza'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los monstruos '
          'sincronizados desde la API?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _syncService.clearSync();
      await _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Monstruos de la API eliminados'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización D&D 5e API'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estadísticas
            _buildStatsCard(),
            const SizedBox(height: 16),
            
            // Estado de sincronización
            if (_isSyncing) _buildSyncProgressCard(),
            
            // Resultado
            if (_syncResult != null && !_isSyncing) _buildResultCard(),
            
            const SizedBox(height: 16),
            
            // Botones de acción
            _buildActionButtons(),
            
            const SizedBox(height: 16),
            
            // Información de la API
            _buildApiInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storage, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildStatRow(
              '📊 Total de monstruos',
              '${_stats!['total_monsters'] ?? 0}',
            ),
            _buildStatRow(
              '☁️ Sincronizados desde API',
              '${_stats!['synced_from_api'] ?? 0}',
              color: Colors.blue,
            ),
            _buildStatRow(
              '💾 Creados localmente',
              '${_stats!['local_only'] ?? 0}',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncProgressCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '🔄 Sincronizando...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 10,
            ),
            const SizedBox(height: 12),
            Text(
              '$_currentMonster de $_totalMonsters monstruos',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final success = _syncResult!['success'] ?? false;
    final synced = _syncResult!['synced'] ?? 0;
    final errors = _syncResult!['errors'] ?? 0;
    final total = _syncResult!['total'] ?? 0;

    return Card(
      elevation: 4,
      color: success ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              success ? 'Sincronización Exitosa' : 'Error en Sincronización',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: success ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultStat('Total', '$total', Colors.blue),
                _buildResultStat('Exitosos', '$synced', Colors.green),
                _buildResultStat('Errores', '$errors', Colors.red),
              ],
            ),
            if (_syncResult!['errorList'] != null && 
                (_syncResult!['errorList'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ExpansionTile(
                title: Text(
                  'Ver errores (${(_syncResult!['errorList'] as List).length})',
                  style: const TextStyle(fontSize: 14),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: (_syncResult!['errorList'] as List).length,
                      itemBuilder: (context, index) {
                        final error = (_syncResult!['errorList'] as List)[index];
                        return Text(
                          '• $error',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isSyncing ? null : () => _startSync(limit: 10),
          icon: const Icon(Icons.download),
          label: const Text('Sincronizar 10 monstruos (Prueba)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isSyncing ? null : () => _startSync(limit: 50),
          icon: const Icon(Icons.cloud_download),
          label: const Text('Sincronizar 50 monstruos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isSyncing ? null : () => _startSync(),
          icon: const Icon(Icons.sync),
          label: const Text('Sincronizar TODOS los monstruos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isSyncing ? null : _clearSync,
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Limpiar monstruos de la API'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildApiInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Información de la API',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '• API: D&D 5e API\n'
              '• URL: https://www.dnd5eapi.co/api/\n'
              '• Monstruos disponibles: ~300+\n'
              '• Incluye: Stats, acciones, habilidades\n'
              '• Velocidad: ~300ms por monstruo\n'
              '• Imágenes: Algunas incluidas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}