import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dnd_oldschool/models/edition.dart';

class EditionDetailPage extends StatelessWidget {
  final Edition edition;

  const EditionDetailPage({super.key, required this.edition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(edition.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEdition(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    edition.color,
                    edition.color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    edition.icon,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    edition.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${edition.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          edition.publisher,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  const Text(
                    '📖 Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    edition.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Características principales
                  const Text(
                    '⚔️ Características Principales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...edition.keyFeatures.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: edition.color,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Datos interesantes
                  Card(
                    color: edition.color.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: edition.color),
                              const SizedBox(width: 8),
                              const Text(
                                'Contexto Histórico',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getHistoricalContext(edition.id),
                            style: const TextStyle(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareEdition(),
                          icon: const Icon(Icons.share),
                          label: const Text('Compartir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: edition.color,
                            side: BorderSide(color: edition.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Ver monstruos de esta edición
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Monstruos de ${edition.name} próximamente',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.pets),
                          label: const Text('Ver Monstruos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: edition.color,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHistoricalContext(String editionId) {
    switch (editionId) {
      case 'odnd':
        return 'Creado por Gary Gygax y Dave Arneson, OD&D revolucionó el gaming al introducir el concepto de juego de rol. Sus reglas abiertas permitieron a cada grupo crear su propia experiencia única.';
      case 'add1e':
        return 'Gary Gygax quiso expandir y formalizar las reglas originales, creando un sistema más robusto para jugadores experimentados. Esta edición definió muchos conceptos que persisten hoy.';
      case 'add2e':
        return 'Bajo presión social y comercial, TSR revisó AD&D para hacerlo más accesible y familiar. Esta edición vio el nacimiento de múltiples escenarios de campaña populares.';
      case '3e':
        return 'Wizards of the Coast, tras adquirir TSR, modernizó completamente D&D con el sistema d20. La Open Game License permitió un ecosistema de contenido sin precedentes.';
      case '35e':
        return 'Basándose en feedback de la comunidad, WotC refinó la 3e en solo 3 años. Muchos consideran esta la "edad dorada" con el mejor balance entre complejidad y jugabilidad.';
      default:
        return 'Una importante edición en la historia de D&D.';
    }
  }

  void _shareEdition() {
    final text = '''
📚 ${edition.fullName} 📚

Año: ${edition.year}
Publisher: ${edition.publisher}

${edition.description}

Características principales:
${edition.keyFeatures.map((f) => '• $f').join('\n')}

Compartido desde D&D Old School Compendium
''';
    Share.share(text, subject: edition.fullName);
  }
}