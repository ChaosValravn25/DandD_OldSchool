class CharacterClass {
  String name;
  int level;
  String description;

  CharacterClass({
    required this.name,
    required this.level,
    required this.description,
  });

  void levelUp() {
    level++;
  }

  @override
  String toString() {
    return 'Class: $name, Level: $level, Description: $description';
  }
}