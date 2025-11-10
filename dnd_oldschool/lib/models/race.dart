import 'package:flutter/material.dart';
class Race {
  final String name;
  final String description;
  final Map<String, int> abilityMods;
  final List<String> specialAbilities;
  final IconData icon;
  final Color color;

  Race({
    required this.name,
    required this.description,
    required this.abilityMods,
    required this.specialAbilities,
    required this.icon,
    required this.color,
  });

  static List<Race> getSample() => [
        Race(
          name: 'Humano',
          description:
              'La raza más versátil y adaptable. Sin bonificaciones especiales pero sin restricciones de clase.',
          abilityMods: {},
          specialAbilities: [
            'Sin límites de nivel',
            'Pueden ser cualquier clase',
            'Bonus de 10% a experiencia',
          ],
          icon: Icons.person,
          color: Colors.blue,
        ),
        Race(
          name: 'Elfo',
          description:
              'Seres mágicos de los bosques. Gráciles y conectados con la naturaleza y la magia.',
          abilityMods: {'DES': 1, 'CON': -1},
          specialAbilities: [
            'Infravisión 60 pies',
            'Inmunidad a parálisis de ghoul',
            'Detectar puertas secretas',
            'Resistencia a encantamientos',
          ],
          icon: Icons.eco,
          color: Colors.green,
        ),
        Race(
          name: 'Enano',
          description:
              'Robustos habitantes de las montañas. Maestros artesanos y guerreros implacables.',
          abilityMods: {'CON': 1, 'CAR': -1},
          specialAbilities: [
            'Infravisión 60 pies',
            '+4 vs venenos',
            '+4 vs magia',
            'Detectar construcciones especiales',
          ],
          icon: Icons.diamond,
          color: Colors.brown,
        ),
        Race(
          name: 'Mediano (Halfling)',
          description:
              'Pequeñas criaturas pacíficas. Valientes cuando es necesario y excepcionalmente afortunados.',
          abilityMods: {'DES': 1, 'FUE': -1},
          specialAbilities: [
            '+1 a AC vs criaturas grandes',
            '+3 con armas de proyectil',
            '+1 a salvaciones',
            'Sigilo mejorado',
          ],
          icon: Icons.wb_sunny,
          color: Colors.orange,
        ),
        Race(
          name: 'Semielfo',
          description:
              'Mezcla de humano y elfo. Combinan lo mejor de ambos mundos con menos restricciones.',
          abilityMods: {},
          specialAbilities: [
            'Infravisión 60 pies',
            'Resistencia a encantamientos',
            'Detectar puertas secretas (30%)',
            'Multiclase flexible',
          ],
          icon: Icons.people,
          color: Colors.teal,
        ),
        Race(
          name: 'Semiorco',
          description:
              'Fuertes y resistentes. A menudo rechazados por ambas sociedades, se destacan con su determinación.',
          abilityMods: {'FUE': 1, 'CAR': -2, 'CON': 1},
          specialAbilities: [
            'Infravisión 60 pies',
            'Resistencia natural',
            'Fuerza excepcional',
          ],
          icon: Icons.fitness_center,
          color: Colors.grey,
        ),
      ];
}