class Spell {
  final String name;
  final int level;
  final String school;
  final String castingTime;
  final String range;
  final String components;
  final String duration;
  final String description;

  Spell({
    required this.name,
    required this.level,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.components,
    required this.duration,
    required this.description,
  });

  static List<Spell> getSample() => [
        Spell(
          name: 'Magic Missile',
          level: 1,
          school: 'Evocación',
          castingTime: '1 acción',
          range: '120 pies',
          components: 'V, S',
          duration: 'Instantáneo',
          description:
              'Creas tres dardos brillantes de fuerza mágica. Cada dardo impacta automáticamente y causa 1d4+1 de daño.',
        ),
        Spell(
          name: 'Sleep',
          level: 1,
          school: 'Encantamiento',
          castingTime: '1 acción',
          range: '90 pies',
          components: 'V, S, M',
          duration: '1 minuto',
          description:
              'Criaturas en el área con 4+1 DG o menos caen dormidas. Afecta hasta 2d8 dados de golpe.',
        ),
        Spell(
          name: 'Fireball',
          level: 3,
          school: 'Evocación',
          castingTime: '1 acción',
          range: '150 pies',
          components: 'V, S, M',
          duration: 'Instantáneo',
          description:
              'Una esfera de fuego explota en el punto que designes. Cada criatura en un radio de 20 pies recibe 1d6 de daño por nivel del lanzador.',
        ),
        Spell(
          name: 'Cure Light Wounds',
          level: 1,
          school: 'Sanación',
          castingTime: '1 acción',
          range: 'Toque',
          components: 'V, S',
          duration: 'Instantáneo',
          description: 'La criatura tocada recupera 1d6+1 puntos de golpe.',
        ),
        Spell(
          name: 'Hold Person',
          level: 2,
          school: 'Encantamiento',
          castingTime: '1 acción',
          range: '120 pies',
          components: 'V, S, M',
          duration: '9 rounds',
          description:
              'El objetivo humanoide queda paralizado y no puede moverse ni actuar.',
        ),
        Spell(
          name: 'Lightning Bolt',
          level: 3,
          school: 'Evocación',
          castingTime: '1 acción',
          range: '120 pies',
          components: 'V, S, M',
          duration: 'Instantáneo',
          description:
              'Un rayo de 60 pies de largo y 5 pies de ancho. Causa 1d6 de daño por nivel del lanzador.',
        ),
      ];
}