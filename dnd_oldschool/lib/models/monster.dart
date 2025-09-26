class Monster {
final String id;
final String name;
final String edition;
final String description;
final int hp;
final String imagePath;

Monster({required this.id, required this.name, required this.edition, required this.description, required this.hp, required this.imagePath,});


// Ejemplo estático para prototipo
static List<Monster> sample() => [
Monster(
id: 'm1',
name: 'Giant Rat',
edition: 'OD&D',
description: 'Rata gigante, común en mazmorras antiguas. Hostil y voraz.',
hp: 4,
 imagePath: 'assets/images/Rat.png',
),
Monster(
id: 'm2',
name: 'Skeleton',
edition: 'AD&D 1e',
description: 'Esqueleto reanimado. Vulnerable a daño contundente.',
hp: 8,
imagePath: 'assets/images/Skeleton1e.png',
),
];
}