import 'package:flutter/material.dart';
class Edition {
  final String id;
  final String name;
  final String fullName;
  final int year;
  final String publisher;
  final String description;
  final List<String> keyFeatures;
  final Color color;
  final IconData icon;

  Edition({
    required this.id,
    required this.name,
    required this.fullName,
    required this.year,
    required this.publisher,
    required this.description,
    required this.keyFeatures,
    required this.color,
    required this.icon,
  });

  static List<Edition> getSample() => [
        Edition(
          id: 'odnd',
          name: 'OD&D',
          fullName: 'Original Dungeons & Dragons',
          year: 1974,
          publisher: 'TSR',
          description:
              'La primera edición de D&D, publicada en tres libros en una caja blanca. Estableció las bases del juego de rol moderno con mecánicas simples y abiertas a interpretación.',
          keyFeatures: [
            'Sistema de clases: Guerrero, Clérigo, Mago',
            'Dados poliédricos (d4, d6, d8, d12, d20)',
            'Niveles del 1 al 20',
            'Sistema de alineamiento Ley-Caos-Neutralidad',
            'Tablas de ataque THAC0',
            'Énfasis en la exploración de mazmorras',
          ],
          color: Colors.brown,
          icon: Icons.book,
        ),
        Edition(
          id: 'add1e',
          name: 'AD&D 1e',
          fullName: 'Advanced Dungeons & Dragons 1st Edition',
          year: 1977,
          publisher: 'TSR',
          description:
              'Primera edición avanzada con reglas más detalladas y complejas. Introdujo el concepto de "Advanced" separándose del D&D básico.',
          keyFeatures: [
            'Sistema expandido de clases y razas',
            'Introducción de habilidades de ladrón',
            'Sistema de iniciativa por segmentos',
            'Tablas de ataque separadas por clase',
            'Alineamiento de 9 puntos (Ley-Caos / Bien-Mal)',
            'Psiónicos como sistema opcional',
            'Énfasis en realismo y simulación',
          ],
          color: Colors.red.shade800,
          icon: Icons.shield,
        ),
        Edition(
          id: 'add2e',
          name: 'AD&D 2e',
          fullName: 'Advanced Dungeons & Dragons 2nd Edition',
          year: 1989,
          publisher: 'TSR',
          description:
              'Revisión y reorganización de AD&D 1e con reglas más accesibles. Eliminó referencias controversiales y simplificó algunas mecánicas.',
          keyFeatures: [
            'Sistema de kits de personaje',
            'Proficiencias de armas y no-armas',
            'Eliminación de demonios y diablos (luego reintroducidos)',
            'THAC0 estandarizado',
            'Puntos de especialización',
            'Sistema de campaña ampliado',
            'Múltiples configuraciones de mundos',
          ],
          color: Colors.blue.shade800,
          icon: Icons.castle,
        ),
        Edition(
          id: '3e',
          name: 'D&D 3e',
          fullName: 'Dungeons & Dragons 3rd Edition',
          year: 2000,
          publisher: 'Wizards of the Coast',
          description:
              'Revolución completa del sistema con el d20 System. Primera edición bajo Wizards of the Coast tras la adquisición de TSR.',
          keyFeatures: [
            'Sistema d20 unificado',
            'Bonificadores en lugar de penalizadores',
            'Skills unificados',
            'Feats (dotes) para personalización',
            'Ascending AC (Clase de Armadura ascendente)',
            'Multiclase flexible',
            'Open Game License (OGL)',
          ],
          color: Colors.orange.shade800,
          icon: Icons.auto_awesome,
        ),
        Edition(
          id: '35e',
          name: 'D&D 3.5e',
          fullName: 'Dungeons & Dragons 3.5 Edition',
          year: 2003,
          publisher: 'Wizards of the Coast',
          description:
              'Revisión y balance de la 3ª edición. Considerada por muchos como la más completa y equilibrada de las ediciones antiguas.',
          keyFeatures: [
            'Rebalanceo de clases y habilidades',
            'Simplificación de skills',
            'Nuevas clases base (ej. Bard mejorado)',
            'Sistema de prestigio refinado',
            'Combate más táctico',
            'Grapple simplificado',
            'Amplia biblioteca de suplementos',
          ],
          color: Colors.purple.shade800,
          icon: Icons.stars,
        ),
      ];
}
