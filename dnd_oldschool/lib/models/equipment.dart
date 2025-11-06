class Equipment {
  final String name;
  final String type;
  final int weight;
  final String description;

  Equipment({
    required this.name,
    required this.type,
    required this.weight,
    required this.description,
  });

  @override
  String toString() {
    return 'Equipment{name: $name, type: $type, weight: $weight, description: $description}';
  }
}