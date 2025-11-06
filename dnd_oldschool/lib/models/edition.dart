class Edition {
  final String name;
  final String description;
  final DateTime releaseDate;

  Edition({
    required this.name,
    required this.description,
    required this.releaseDate,
  });

  @override
  String toString() {
    return 'Edition{name: $name, description: $description, releaseDate: $releaseDate}';
  }
}