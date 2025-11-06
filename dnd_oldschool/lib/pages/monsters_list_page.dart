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
              // Botón de compartir bestiario completo
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
                    // Filtro por edición
                    ...provider.availableEditions.map((edition) {
                      final isSelected = provider.selectedEdition == edition;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(edition),
                          selected: isSelected,
                          onSelected: (selected) {
                            provider.filterByEdition(edition);
                          },
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    // Filtro de favoritos
                    FilterChip(
                      avatar: const Icon(Icons.star, size: 18),
                      label: const Text('Favoritos'),
                      selected: provider.showOnlyFavorites,
                      onSelected: (selected) {
                        provider.toggleShowFavorites(selected);
                      },
                    ),
                  ],
                ),
              ),

              // Estadísticas
              if (provider.selectedEdition != 'Todas' ||
                  provider.showOnlyFavorites)
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay monstruos',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primer monstruo',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
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
🐉 ${monster.name}
📚 Edición: ${monster.edition}
${monster.type != null ? '🏷️ Tipo: ${monster.type}' : ''}
❤️ HP: ${monster.hp}
${monster.ac != null ? '🛡️ AC: ${monster.ac}' : ''}

${monster.description}

${monster.abilities != null ? '⚔️ Habilidades:\n${monster.abilities}' : ''}

---
Compartido desde D&D Old School Compendium
''';
    Share.share(text, subject: 'D&D - ${monster.name}');
  }
}
