import 'package:flutter/material.dart';

class CharacterClass {
  final String name;
  final String description;
  final String hitDie;
  final List<String> abilities;
  final IconData icon;
  final Color color;

  CharacterClass({
    required this.name,
    required this.description,
    required this.hitDie,
    required this.abilities,
    required this.icon,
    required this.color,
  });

  static List<CharacterClass> getSample() => [
        CharacterClass(
          name: 'Guerrero (Fighter)',
          description:
              'Maestro del combate cuerpo a cuerpo. Experto en todas las armas y armaduras, el guerrero es la columna vertebral de cualquier grupo aventurero.',
          hitDie: '1d10',
          abilities: [
            'Competencia en todas las armas',
            'Competencia en todas las armaduras',
            'Múltiples ataques por nivel',
            'Bonos de ataque superiores',
          ],
          icon: Icons.shield,
          color: Colors.red,
        ),
        CharacterClass(
          name: 'Mago (Magic-User)',
          description:
              'Estudioso de las artes arcanas. Débil físicamente pero capaz de lanzar poderosos hechizos que pueden cambiar el curso de la batalla.',
          hitDie: '1d4',
          abilities: [
            'Acceso a hechizos arcanos',
            'Libro de hechizos',
            'Preparación de conjuros diaria',
            'Slots de hechizo por nivel',
          ],
          icon: Icons.auto_fix_high,
          color: Colors.purple,
        ),
        CharacterClass(
          name: 'Clérigo (Cleric)',
          description:
              'Servidor de los dioses con poder divino. Combina habilidades de combate moderadas con magia curativa y protectora.',
          hitDie: '1d8',
          abilities: [
            'Hechizos divinos',
            'Turn Undead (expulsar no-muertos)',
            'Armaduras pesadas permitidas',
            'Armas contundentes',
          ],
          icon: Icons.church,
          color: Colors.amber,
        ),
        CharacterClass(
          name: 'Ladrón (Thief)',
          description:
              'Experto en sigilo, trampas y subterfugio. Esencial para explorar mazmorras peligrosas llenas de mecanismos mortales.',
          hitDie: '1d6',
          abilities: [
            'Backstab (ataque por la espalda)',
            'Abrir cerraduras',
            'Detectar y desarmar trampas',
            'Moverse en silencio',
            'Esconderse en las sombras',
          ],
          icon: Icons.visibility_off,
          color: Colors.grey,
        ),
        CharacterClass(
          name: 'Enano (Dwarf)',
          description:
              'Guerrero resistente de las montañas. En ediciones antiguas, Enano era una clase, no solo una raza.',
          hitDie: '1d8',
          abilities: [
            'Resistencia contra venenos',
            'Resistencia contra magia',
            'Detección de construcciones',
            'Infravisión',
          ],
          icon: Icons.terrain,
          color: Colors.brown,
        ),
        CharacterClass(
          name: 'Elfo (Elf)',
          description:
              'Combinación de guerrero y mago. Los elfos podían cambiar entre clases según la situación.',
          hitDie: '1d6',
          abilities: [
            'Cambio entre guerrero y mago',
            'Inmunidad a Ghoul paralysis',
            'Infravisión',
            'Detectar puertas secretas',
          ],
          icon: Icons.park,
          color: Colors.green,
        ),
        CharacterClass(
          name: 'Mediano (Halfling)',
          description:
              'Pequeños pero valientes. Excelentes con proyectiles y difíciles de golpear por su tamaño.',
          hitDie: '1d6',
          abilities: [
            'Bonos con armas a distancia',
            'Difícil de golpear (AC mejorado)',
            'Resistencia a magia',
            'Sigilo natural',
          ],
          icon: Icons.local_dining,
          color: Colors.orange,
        ),
      ];
}