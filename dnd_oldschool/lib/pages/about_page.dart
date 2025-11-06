import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_router.dart';

/// Página "Acerca de" con información de la app y acceso a valoración
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo/Ícono de la aplicación
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.auto_stories,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Nombre de la aplicación
          const Text(
            'D&D Old School Compendium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Versión
          const Text(
            'Versión 1.0.0 (Beta)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          // Descripción
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sobre esta aplicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Un compendio completo de Dungeons & Dragons Old School con información detallada de monstruos, hechizos, clases, razas y reglas de las ediciones clásicas.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Incluye contenido de:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('📖 Original D&D (OD&D)'),
                  _buildFeatureItem('⚔️ Advanced D&D 1st Edition'),
                  _buildFeatureItem('🛡️ Advanced D&D 2nd Edition'),
                  _buildFeatureItem('🎲 D&D 3rd Edition'),
                  _buildFeatureItem('🐉 D&D 3.5 Edition'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tu opinión
          Card(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.star_rate, color: Colors.amber, size: 32),
              title: const Text(
                'Tu Opinión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Valora la aplicación y ayúdanos a mejorar'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, AppRouter.rating),
            ),
          ),
          const SizedBox(height: 16),
          
          // Información de contacto
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Contacto'),
                  subtitle: const Text('developer@dndoldschool.com'),
                  onTap: () => _launchEmail('developer@dndoldschool.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Repositorio'),
                  subtitle: const Text('github.com/tu-usuario/dnd-oldschool'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchUrl('https://github.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Reportar un problema'),
                  subtitle: const Text('Ayúdanos a mejorar la app'),
                  onTap: () => _launchEmail(
                    'developer@dndoldschool.com',
                    subject: 'Reporte de problema - D&D Old School',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Desarrollador
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Desarrollado por',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '[Tu Nombre Completo]',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Proyecto desarrollado como parte del curso de Programación de Dispositivos Móviles 2025-2',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Créditos y licencias
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.copyright),
              title: const Text('Créditos y Licencias'),
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dungeons & Dragons',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'D&D es una marca registrada de Wizards of the Coast. Esta aplicación no está afiliada ni respaldada por Wizards of the Coast.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Contenido Open Game License',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Parte del contenido está disponible bajo la Open Game License (OGL) y System Reference Document (SRD).',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Imágenes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Las imágenes utilizadas son de dominio público o bajo licencias libres.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Copyright
          const Text(
            '© 2025 D&D Old School Compendium\nTodos los derechos reservados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            'Hecho con ❤️ usando Flutter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email, {String? subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null
          ? 'subject=${Uri.encodeComponent(subject)}'
          : null,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}