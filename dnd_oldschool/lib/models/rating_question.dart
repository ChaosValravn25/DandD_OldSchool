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

// ============= JSON PARA ASSETS =============
// Guardar este contenido en: assets/data/rating_questions.json

const String ratingQuestionsJson = '''
{
  "usabilidad": [
    {
      "titulo": "Pregunta 1: ¿Qué tan fácil fue navegar a través de la aplicación?",
      "valor": 0,
      "min": "0 estrellas: Fue muy difícil encontrar las funcionalidades, la navegación fue confusa.",
      "max": "5 estrellas: Fue extremadamente fácil, la navegación es intuitiva y sin complicaciones."
    },
    {
      "titulo": "Pregunta 2: ¿Pudiste completar tus tareas en la aplicación sin problemas?",
      "valor": 0,
      "min": "0 estrellas: No pude completar las tareas, fue frustrante.",
      "max": "5 estrellas: Pude completar todas las tareas de forma rápida y eficiente."
    },
    {
      "titulo": "Pregunta 3: ¿Cómo calificas la interfaz gráfica en términos de diseño y claridad?",
      "valor": 0,
      "min": "0 estrellas: La interfaz es poco clara y difícil de entender.",
      "max": "5 estrellas: La interfaz es clara, atractiva y facilita el uso."
    }
  ],
  "contenido": [
    {
      "titulo": "Pregunta 1: ¿El contenido de la aplicación fue útil para ti?",
      "valor": 0,
      "min": "0 estrellas: El contenido no fue relevante ni útil.",
      "max": "5 estrellas: El contenido fue muy útil y relevante para mis necesidades."
    },
    {
      "titulo": "Pregunta 2: ¿Qué tan bien el contenido de la aplicación se adapta a tus expectativas?",
      "valor": 0,
      "min": "0 estrellas: El contenido no cumplió con mis expectativas.",
      "max": "5 estrellas: El contenido superó completamente mis expectativas."
    },
    {
      "titulo": "Pregunta 3: ¿El contenido de la aplicación está presentado de manera clara y comprensible?",
      "valor": 0,
      "min": "0 estrellas: El contenido está mal estructurado o es confuso.",
      "max": "5 estrellas: El contenido está muy bien presentado y es fácil de comprender."
    }
  ],
  "compartir": [
    {
      "titulo": "Pregunta 1: ¿Qué tan probable es que recomiendes esta aplicación a un amigo?",
      "valor": 0,
      "min": "0 estrellas: No la recomendaría en absoluto.",
      "max": "5 estrellas: Definitivamente la recomendaría."
    },
    {
      "titulo": "Pregunta 2: ¿Cómo te sentirías al compartir esta aplicación con alguien más?",
      "valor": 0,
      "min": "0 estrellas: No me sentiría cómodo compartiéndola.",
      "max": "5 estrellas: Me sentiría muy cómodo compartiéndola."
    },
    {
      "titulo": "Pregunta 3: ¿Crees que esta aplicación podría ser útil para personas cercanas a ti?",
      "valor": 0,
      "min": "0 estrellas: No creo que sea útil para otras personas.",
      "max": "5 estrellas: Estoy seguro de que sería muy útil para personas cercanas."
    }
  ]
}
''';