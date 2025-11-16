// lib/screens/image_manager_screen.dart
import 'package:flutter/material.dart';
import '../services/image_downloader.dart';
import 'dart:io';

class ImageManagerScreen extends StatefulWidget {
  const ImageManagerScreen({super.key});

  @override
  State<ImageManagerScreen> createState() => _ImageManagerScreenState();
}

class _ImageManagerScreenState extends State<ImageManagerScreen> {
  int _imageCount = 0;
  int _totalSize = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImageStats();
  }

  Future<void> _loadImageStats() async {
    setState(() => _loading = true);
    
    final count = await ImageDownloader.getImageCount();
    final size = await ImageDownloader.getTotalSize();
    
    setState(() {
      _imageCount = count;
      _totalSize = size;
      _loading = false;
    });
  }

  Future<void> _cleanupImages() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar imágenes corruptas'),
        content: const Text(
          '¿Deseas eliminar imágenes corruptas o inválidas?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final deleted = await ImageDownloader.cleanupOldImages();
      await _loadImageStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Se eliminaron $deleted imágenes corruptas'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllImages() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todas las imágenes'),
        content: const Text(
          '⚠️ ADVERTENCIA: Esto eliminará todas las imágenes descargadas. '
          'Tendrás que volver a sincronizar para recuperarlas.\n\n'
          '¿Estás seguro?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final deleted = await ImageDownloader.deleteAllImages();
      await _loadImageStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Se eliminaron $deleted imágenes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Imágenes'),
        backgroundColor: Colors.brown,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                  const SizedBox(height: 16),
                  _buildSourcesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.image, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'Estadísticas de Imágenes',
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
              '📊 Total de imágenes',
              '$_imageCount',
              icon: Icons.photo_library,
            ),
            _buildStatRow(
              '💾 Espacio utilizado',
              _formatBytes(_totalSize),
              icon: Icons.storage,
            ),
            if (_imageCount > 0)
              _buildStatRow(
                '📏 Promedio por imagen',
                _formatBytes(_totalSize ~/ _imageCount),
                icon: Icons.assessment,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
                  'Información',
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
              '• Las imágenes se descargan automáticamente durante la sincronización\n'
              '• Se intentan múltiples fuentes hasta encontrar una válida\n'
              '• Las imágenes se almacenan localmente en el dispositivo\n'
              '• Las imágenes corruptas se detectan y pueden eliminarse\n'
              '• Al eliminar un monstruo, su imagen permanece en caché',
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

  Widget _buildActionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _cleanupImages,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Limpiar imágenes corruptas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _deleteAllImages,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Eliminar todas las imágenes'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadImageStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar estadísticas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_download, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Fuentes de Imágenes D&D',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSourceItem('D&D 5e API', '✅ Oficial', Colors.green),
            _buildSourceItem('Pexels', '✅ Fantasía HD', Colors.blue),
            _buildSourceItem('DiceBear', '✅ Avatares generados', Colors.purple),
            _buildSourceItem('Boring Avatars', '✅ Estilo artístico', Colors.orange),
            _buildSourceItem('RoboHash', '✅ Monstruos únicos', Colors.red),
            _buildSourceItem('UI Avatars', '✅ Iniciales', Colors.teal),
            _buildSourceItem('Multiavatar', '✅ Personalizados', Colors.indigo),
            _buildSourceItem('Placeholders', '✅ Texto', Colors.grey),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todas las fuentes están optimizadas para contenido de D&D y fantasía',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceItem(String name, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}