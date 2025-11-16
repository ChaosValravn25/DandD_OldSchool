import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/monster_provider.dart';
import '../app_router.dart';
import '../models/monster.dart';
import '../widgets/Monster_Card.dart';

/// Página de lista de monstruos con funcionalidades avanzadas
class MonstersListPage extends StatefulWidget {
  const MonstersListPage({super.key});

  @override
  State<MonstersListPage> createState() => _MonstersListPageState();
}

class _MonstersListPageState extends State<MonstersListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonsterProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bestiario Old School'),
            actions: [
              // Compartir bestiario completo
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Compartir bestiario',
                onPressed: () {
                  final text = provider.exportToText();
                  Share.share(
                    text,
                    subject: 'D&D Old School - Mi Bestiario',
                  );
                },
              ),

              // Importar desde API oficial
              IconButton(
                icon: const Icon(Icons.cloud_download),
                tooltip: 'Importar desde API oficial',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Importar Monstruos'),
                      content: const Text(
                        '¿Desea importar monstruos desde la API oficial de D&D 5e?\n'
                        'Se descargarán imágenes y datos automáticamente.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Importar'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await provider.importMonstersFromApi();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Importación iniciada. Revisa la pestaña de Sincronización.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),

              // Menú de ordenamiento
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                tooltip: 'Ordenar',
                onSelected: (value) => provider.sortMonsters(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'name_asc',
                    child: Text('Nombre (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: 'name_desc',
                    child: Text('Nombre (Z-A)'),
                  ),
                  const PopupMenuItem(
                    value: 'hp_asc',
                    child: Text('HP (menor a mayor)'),
                  ),
                  const PopupMenuItem(
                    value: 'hp_desc',
                    child: Text('HP (mayor a menor)'),
                  ),
                  const PopupMenuItem(
                    value: 'edition',
                    child: Text('Por edición'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar monstruos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.searchMonsters('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => provider.searchMonsters(value),
                ),
              ),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ...provider.availableEditions.map((edition) {
                      final isSelected = provider.selectedEdition == edition;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(edition),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          onSelected: (selected) {
                            provider.filterByEdition(edition);
                          },
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.star, size: 18),
                      label: const Text('Favoritos'),
                      selected: provider.showOnlyFavorites,
                      selectedColor: Colors.amber.withOpacity(0.2),
                      onSelected: (selected) {
                        provider.toggleShowFavorites(selected);
                      },
                    ),
                  ],
                ),
              ),

              // Estadísticas
              if (provider.selectedEdition != 'Todas' || provider.showOnlyFavorites)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${provider.monsters.length} monstruo(s)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => provider.clearFilters(),
                        child: const Text('Limpiar filtros'),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 1),

              // Lista de monstruos
              Expanded(
                child: _buildMonsterList(provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.monsterForm);
            },
            tooltip: 'Agregar monstruo',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildMonsterList(MonsterProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadMonsters();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.monsters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No se encontraron monstruos.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '¡Agrega nuevos monstruos o importa desde la API!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: provider.monsters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final monster = provider.monsters[index];
        return MonsterCard(
          monster: monster,
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.monsterDetail,
              arguments: {'id': monster.id, 'name': monster.name},
            );
          },
          onFavoriteToggle: () {
            provider.toggleFavorite(monster.id);
          },
          onShare: () {
            _shareMonster(monster);
          },
        );
      },
    );
  }

  void _shareMonster(Monster monster) {
    final text = '''
Beholder ${monster.name}
Edición: ${monster.edition}
${monster.type != null ? 'Tipo: ${monster.type}' : ''}
HP: ${monster.hp}
${monster.ac != null ? 'AC: ${monster.ac}' : ''}

${monster.description}

${monster.abilities != null ? 'Habilidades:\n${monster.abilities}' : ''}

---
Compartido desde D&D Old School Compendium
''';
    Share.share(text, subject: 'D&D - ${monster.name}');
  }
}