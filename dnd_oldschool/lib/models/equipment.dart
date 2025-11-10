import 'package:flutter/material.dart';

class Equipment {
  final String name;
  final String type;
  final String cost;
  final String weight;
  final String? damage;
  final String? acBonus;
  final String description;

  Equipment({
    required this.name,
    required this.type,
    required this.cost,
    required this.weight,
    this.damage,
    this.acBonus,
    required this.description,
  });

  static List<Equipment> getSample() => [
        // Armas
        Equipment(
          name: 'Espada Larga',
          type: 'Arma',
          cost: '15 gp',
          weight: '4 lbs',
          damage: '1d8',
          description: 'Arma versátil, puede usarse a una o dos manos.',
        ),
        Equipment(
          name: 'Daga',
          type: 'Arma',
          cost: '2 gp',
          weight: '1 lb',
          damage: '1d4',
          description: 'Pequeña, ligera, puede lanzarse.',
        ),
        Equipment(
          name: 'Arco Largo',
          type: 'Arma',
          cost: '40 gp',
          weight: '3 lbs',
          damage: '1d8',
          description: 'Rango 70/140/210 pies.',
        ),
        Equipment(
          name: 'Hacha de Batalla',
          type: 'Arma',
          cost: '7 gp',
          weight: '7 lbs',
          damage: '1d8',
          description: 'Versátil, buena contra armaduras.',
        ),
        // Armaduras
        Equipment(
          name: 'Armadura de Placas',
          type: 'Armadura',
          cost: '50 gp',
          weight: '50 lbs',
          acBonus: 'AC 3',
          description: 'La mejor protección disponible.',
        ),
        Equipment(
          name: 'Cota de Mallas',
          type: 'Armadura',
          cost: '30 gp',
          weight: '30 lbs',
          acBonus: 'AC 5',
          description: 'Balance entre protección y movilidad.',
        ),
        Equipment(
          name: 'Armadura de Cuero',
          type: 'Armadura',
          cost: '5 gp',
          weight: '15 lbs',
          acBonus: 'AC 8',
          description: 'Ligera, ideal para ladrones.',
        ),
        Equipment(
          name: 'Escudo',
          type: 'Armadura',
          cost: '10 gp',
          weight: '10 lbs',
          acBonus: '-1 AC',
          description: 'Mejora la clase de armadura en 1.',
        ),
        // Objetos
        Equipment(
          name: 'Antorcha',
          type: 'Objeto',
          cost: '1 cp',
          weight: '1 lb',
          description: 'Ilumina 30 pies durante 6 turnos.',
        ),
        Equipment(
          name: 'Cuerda (50 pies)',
          type: 'Objeto',
          cost: '1 gp',
          weight: '5 lbs',
          description: 'Esencial para exploración.',
        ),
        Equipment(
          name: 'Mochila',
          type: 'Objeto',
          cost: '5 gp',
          weight: '2 lbs',
          description: 'Capacidad: 30 lbs de equipo.',
        ),
        Equipment(
          name: 'Herramientas de Ladrón',
          type: 'Objeto',
          cost: '30 gp',
          weight: '1 lb',
          description: 'Necesarias para abrir cerraduras.',
        ),
      ];
}