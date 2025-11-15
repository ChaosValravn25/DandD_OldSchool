import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_router.dart';
import '../providers/monster_provider.dart';
import '../widgets/Statcard.dart';
import '../widgets/QuickAccessCard.dart';
import '../widgets/ContentCard.dart';

/// HomePage: Pantalla principal con dashboard y navegación completa
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('D&D Old School'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Preferencias',
            onPressed: () => Navigator.pushNamed(context, AppRouter.preferences),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de bienvenida
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),
              
              // Estadísticas rápidas
              _buildQuickStats(context),
              const SizedBox(height: 24),
              
              // Accesos rápidos principales
              const Text(
                '⚔️ Accesos Rápidos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQuickAccessGrid(context),
              const SizedBox(height: 24),
              
              // Sección de contenido
              const Text(
                '📚 Explorar Contenido',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildContentCards(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el drawer de navegación
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              image: const DecorationImage(
                image: AssetImage('assets/images/Dungeons-and-Dragons-Logo-2000.png'),
                fit: BoxFit.contain,
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menú Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Inicio
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          
          const Divider(),
          
          // Bestiario
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Bestiario'),
            subtitle: const Text('Monstruos por edición'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.monsters);
            },
          ),
          
          // Ediciones
          ListTile(
            leading: const Icon(Icons.history_edu),
            title: const Text('Ediciones'),
            subtitle: const Text('Historia de D&D'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.editions);
            },
          ),
          
          // Hechizos - ✅ HABILITADO
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: const Text('Hechizos'),
            subtitle: const Text('Magia arcana y divina'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.spells);
            },
          ),
          
          // Clases y Razas - ✅ HABILITADO
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Clases y Razas'),
            subtitle: const Text('Personajes jugables'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.classes);
            },
          ),
          
          // Equipamiento - ✅ HABILITADO
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Equipamiento'),
            subtitle: const Text('Armas y armaduras'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.equipment);
            },
          ),
          
          // Reglas antiguas
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Reglas Antiguas'),
            subtitle: const Text('Comparativas entre ediciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.rules);
            },
          ),
          
          const Divider(),
          
          // Preferencias
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferencias'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.preferences);
            },
          ),
          
          // Sincronización API
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Sincronizar API'),
            subtitle: const Text('Descargar desde D&D 5e API'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.sync);
            },
          ),
          
          // Acerca de
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.about);
            },
          ),
        ],
      ),
    );
  }

  /// Encabezado de bienvenida
  Widget _buildWelcomeHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido al Compendium',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Explora las ediciones clásicas de D&D',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            // Botón de valoración destacado
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRouter.rating),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star_rate,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Te gusta la app?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Valora tu experiencia',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estadísticas rápidas
  Widget _buildQuickStats(BuildContext context) {
    return Consumer<MonsterProvider>(
      builder: (context, provider, child) {
        final stats = provider.getStatistics();
        
        return Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.pets,
                label: 'Monstruos',
                value: '${provider.totalMonsters}',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.star,
                label: 'Favoritos',
                value: '${provider.favoriteCount}',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.history_edu,
                label: 'Ediciones',
                value: '${stats.length}',
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Grid de accesos rápidos
  Widget _buildQuickAccessGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickAccessCard(
            icon: Icons.pets,
            label: 'Bestiario',
            color: Colors.red,
            onTap: () => Navigator.pushNamed(context, AppRouter.monsters),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickAccessCard(
            icon: Icons.history_edu,
            label: 'Ediciones',
            color: Colors.brown,
            onTap: () => Navigator.pushNamed(context, AppRouter.editions),
          ),
        ),
      ],
    );
  }

  /// Cards de contenido
  Widget _buildContentCards(BuildContext context) {
    return Column(
      children: [
        // Hechizos - ✅ HABILITADO
        ContentCard(
          icon: Icons.auto_fix_high,
          title: 'Hechizos',
          subtitle: 'Magia de todas las ediciones',
          color: Colors.purple,
          enabled: true, // ✅ CAMBIADO A true
          onTap: () => Navigator.pushNamed(context, AppRouter.spells),
        ),
        const SizedBox(height: 8),
        
        // Clases y Razas - ✅ HABILITADO
        ContentCard(
          icon: Icons.shield,
          title: 'Clases y Razas',
          subtitle: 'Guerreros, magos, elfos y más',
          color: Colors.blue,
          enabled: true, // ✅ CAMBIADO A true
          onTap: () => Navigator.pushNamed(context, AppRouter.classes),
        ),
        const SizedBox(height: 8),
        
        // Equipamiento - ✅ HABILITADO
        ContentCard(
          icon: Icons.shopping_bag,
          title: 'Equipamiento',
          subtitle: 'Armas, armaduras y objetos mágicos',
          color: Colors.orange,
          enabled: true, // ✅ CAMBIADO A true
          onTap: () => Navigator.pushNamed(context, AppRouter.equipment),
        ),
        const SizedBox(height: 8),
        
        // Reglas Antiguas - ✅ YA ESTABA HABILITADO
        ContentCard(
          icon: Icons.menu_book,
          title: 'Reglas Antiguas',
          subtitle: 'Compara mecánicas entre ediciones',
          color: Colors.brown,
          enabled: true, // Por defecto es true si no se especifica
          onTap: () => Navigator.pushNamed(context, AppRouter.rules),
        ),
        const SizedBox(height: 16),
        
        // ⭐ VALORACIÓN - Card especial destacada
        Card(
          elevation: 3,
          color: Colors.amber.shade50,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRouter.rating),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rate,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⭐ Valora la Aplicación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tu opinión nos ayuda a mejorar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}