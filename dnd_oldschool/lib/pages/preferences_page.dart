import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import '../providers/theme_provider.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final _prefs = PreferencesService.instance;
  
  String _selectedEdition = 'Todas';
  bool _showImages = true;
  String _selectedSort = 'name_asc';
  bool _showFavoritesOnly = false;
  bool _showFullDescription = false;
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _selectedEdition = _prefs.defaultEdition;
      _showImages = _prefs.showImages;
      _selectedSort = _prefs.defaultSort;
      _showFavoritesOnly = _prefs.showFavoritesOnly;
      _showFullDescription = _prefs.showFullDescription;
      _fontSize = _prefs.fontSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restablecer',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restablecer Preferencias'),
                  content: const Text(
                      '¿Deseas restablecer todas las preferencias a sus valores por defecto?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Restablecer'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await _prefs.resetAll();
                await themeProvider.setTheme('parchment');
                await _loadPreferences();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Preferencias restablecidas')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: Apariencia
          const Text(
            '🎨 Apariencia',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Selector de tema con preview
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Tema de la aplicación'),
                  subtitle: Text(_getThemeName(themeProvider.currentTheme)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _ThemeOption(
                        label: '📜 Pergamino',
                        description: 'Tema clásico estilo D&D',
                        isSelected: themeProvider.isParchmentMode,
                        color: const Color(0xFF8B4513),
                        onTap: () => themeProvider.setTheme('parchment'),
                      ),
                      const SizedBox(height: 8),
                      _ThemeOption(
                        label: '☀️ Claro',
                        description: 'Tema claro y limpio',
                        isSelected: themeProvider.isLightMode,
                        color: Colors.brown,
                        onTap: () => themeProvider.setTheme('light'),
                      ),
                      const SizedBox(height: 8),
                      _ThemeOption(
                        label: '🌙 Oscuro',
                        description: 'Tema oscuro para ambientes con poca luz',
                        isSelected: themeProvider.isDarkMode,
                        color: const Color(0xFF2C1810),
                        onTap: () => themeProvider.setTheme('dark'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tamaño de fuente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_size),
                      const SizedBox(width: 16),
                      Text(
                        'Tamaño de fuente: ${_fontSize.toInt()}pt',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12,
                    max: 20,
                    divisions: 8,
                    label: '${_fontSize.toInt()}pt',
                    onChanged: (value) {
                      setState(() => _fontSize = value);
                    },
                    onChangeEnd: (value) async {
                      await _prefs.setFontSize(value);
                    },
                  ),
                  Text(
                    'Vista previa del tamaño de texto',
                    style: TextStyle(fontSize: _fontSize),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sección: General
          const Text(
            '⚙️ General',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Edición favorita
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_edu),
              title: const Text('Edición favorita por defecto'),
              subtitle: Text(_selectedEdition),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Seleccionar edición'),
                    children: [
                      'Todas',
                      'OD&D',
                      'AD&D 1e',
                      'AD&D 2e',
                      '3e',
                      '3.5e'
                    ].map((edition) {
                      return SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, edition),
                        child: Text(edition),
                      );
                    }).toList(),
                  ),
                );
                if (result != null) {
                  await _prefs.setDefaultEdition(result);
                  setState(() => _selectedEdition = result);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Sección: Visualización
          const Text(
            '👁️ Visualización',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Mostrar imágenes
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.image),
              title: const Text('Mostrar imágenes automáticamente'),
              subtitle: const Text('Desactiva para ahorrar datos'),
              value: _showImages,
              onChanged: (value) async {
                await _prefs.setShowImages(value);
                setState(() => _showImages = value);
              },
            ),
          ),
          const SizedBox(height: 8),

          // Mostrar descripción completa
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.description),
              title: const Text('Mostrar descripción completa en listas'),
              subtitle: const Text('Muestra todo el texto en las tarjetas'),
              value: _showFullDescription,
              onChanged: (value) async {
                await _prefs.setShowFullDescription(value);
                setState(() => _showFullDescription = value);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Sección: Contenido
          const Text(
            '📚 Contenido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Ordenamiento por defecto
          Card(
            child: ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Ordenamiento por defecto'),
              subtitle: Text(_getSortName(_selectedSort)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Ordenar por'),
                    children: [
                      {'value': 'name_asc', 'name': 'Nombre (A-Z)'},
                      {'value': 'name_desc', 'name': 'Nombre (Z-A)'},
                      {'value': 'hp_asc', 'name': 'HP (menor a mayor)'},
                      {'value': 'hp_desc', 'name': 'HP (mayor a menor)'},
                      {'value': 'edition', 'name': 'Edición'},
                    ].map((sort) {
                      return SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, sort['value']),
                        child: Text(sort['name']!),
                      );
                    }).toList(),
                  ),
                );
                if (result != null) {
                  await _prefs.setDefaultSort(result);
                  setState(() => _selectedSort = result);
                }
              },
            ),
          ),
          const SizedBox(height: 8),

          // Mostrar solo favoritos
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.star),
              title: const Text('Mostrar solo favoritos en inicio'),
              subtitle: const Text('Filtra el contenido de la pantalla inicial'),
              value: _showFavoritesOnly,
              onChanged: (value) async {
                await _prefs.setShowFavoritesOnly(value);
                setState(() => _showFavoritesOnly = value);
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Botón para probar cambio rápido de tema
          OutlinedButton.icon(
            onPressed: () => themeProvider.cycleTheme(),
            icon: const Icon(Icons.brightness_6),
            label: const Text('Cambiar Tema'),
          ),
        ],
      ),
    );
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return '☀️ Claro';
      case 'dark':
        return '🌙 Oscuro';
      case 'parchment':
        return '📜 Pergamino';
      default:
        return 'Desconocido';
    }
  }

  String _getSortName(String sort) {
    switch (sort) {
      case 'name_asc':
        return 'Nombre (A-Z)';
      case 'name_desc':
        return 'Nombre (Z-A)';
      case 'hp_asc':
        return 'HP (menor a mayor)';
      case 'hp_desc':
        return 'HP (mayor a menor)';
      case 'edition':
        return 'Edición';
      default:
        return 'Desconocido';
    }
  }
}

// Widget auxiliar para opciones de tema
class _ThemeOption extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}