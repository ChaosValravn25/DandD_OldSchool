/// Modelo para preguntas de valoración
class RatingQuestion {
  final String titulo;
  int valor;
  final String min;
  final String max;

  RatingQuestion({
    required this.titulo,
    this.valor = 0,
    required this.min,
    required this.max,
  });

  factory RatingQuestion.fromJson(Map<String, dynamic> json) {
    return RatingQuestion(
      titulo: json['titulo'] as String,
      valor: json['valor'] as int? ?? 0,
      min: json['min'] as String,
      max: json['max'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'valor': valor,
      'min': min,
      'max': max,
    };
  }

  RatingQuestion copyWith({int? valor}) {
    return RatingQuestion(
      titulo: titulo,
      valor: valor ?? this.valor,
      min: min,
      max: max,
    );
  }
}

/// Modelo para categorías de valoración
class RatingCategory {
  final String name;
  final List<RatingQuestion> questions;

  RatingCategory({
    required this.name,
    required this.questions,
  });

  factory RatingCategory.fromJson(String name, List<dynamic> json) {
    return RatingCategory(
      name: name,
      questions: json
          .map((q) => RatingQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  double get averageRating {
    if (questions.isEmpty) return 0;
    final sum = questions.fold(0, (prev, q) => prev + q.valor);
    return sum / questions.length;
  }
}

/// Modelo completo de valoración
class RatingData {
  final RatingCategory usabilidad;
  final RatingCategory contenido;
  final RatingCategory compartir;

  RatingData({
    required this.usabilidad,
    required this.contenido,
    required this.compartir,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      usabilidad: RatingCategory.fromJson('Usabilidad', json['usabilidad']),
      contenido: RatingCategory.fromJson('Contenido', json['contenido']),
      compartir: RatingCategory.fromJson('Compartir', json['compartir']),
    );
  }

  List<RatingCategory> get categories => [usabilidad, contenido, compartir];

  double get overallRating {
    final avg = (usabilidad.averageRating +
            contenido.averageRating +
            compartir.averageRating) /
        3;
    return avg;
  }

  String toEmailBody(String userName) {
    final buffer = StringBuffer();
    buffer.writeln('=== VALORACIÓN D&D OLD SCHOOL COMPENDIUM ===\n');
    buffer.writeln('Usuario: $userName');
    buffer.writeln('Fecha: ${DateTime.now()}\n');
    buffer.writeln('Calificación General: ${overallRating.toStringAsFixed(1)}/5.0 ⭐\n');

    for (var category in categories) {
      buffer.writeln('--- ${category.name.toUpperCase()} ---');
      buffer.writeln('Promedio: ${category.averageRating.toStringAsFixed(1)}/5.0\n');

      for (var i = 0; i < category.questions.length; i++) {
        final q = category.questions[i];
        buffer.writeln('${i + 1}. ${q.titulo}');
        buffer.writeln('   Calificación: ${q.valor}/5 ${"⭐" * q.valor}');
        buffer.writeln('');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

