class Race {
  final String name;
  final String description;
  final List<String> abilities;

  Race({
    required this.name,
    required this.description,
    required this.abilities,
  });

  @override
  String toString() {
    return 'Race{name: $name, description: $description, abilities: $abilities}';
  }
}