import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/rating_question.dart';

/// Página de valoración de la aplicación
class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final TextEditingController _nameController = TextEditingController();
  RatingData? _ratingData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRatingQuestions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Carga las preguntas desde el JSON en assets
  Future<void> _loadRatingQuestions() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/rating_questions.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        _ratingData = RatingData.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar preguntas: $e';
        _isLoading = false;
      });
    }
  }

  /// Actualiza el valor de una pregunta
  void _updateRating(RatingCategory category, int questionIndex, int value) {
    setState(() {
      category.questions[questionIndex] =
          category.questions[questionIndex].copyWith(valor: value);
    });
  }

  /// Envía la valoración por correo
  Future<void> _sendRating() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre')),
      );
      return;
    }

    if (_ratingData == null) return;

    final emailBody = _ratingData!.toEmailBody(_nameController.text.trim());
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'developer@dndoldschool.com', // Cambiar por tu email
      query:
          'subject=${Uri.encodeComponent('Valoración D&D Old School Compendium')}&body=${Uri.encodeComponent(emailBody)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Gracias por tu valoración!')),
          );
        }
      } else {
        throw 'No se puede abrir el cliente de correo';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tu Opinión')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tu Opinión')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRatingQuestions,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Opinión'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            const Text(
              '📝 Valoración de la App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu opinión es muy importante para mejorar la experiencia. Por favor califica los siguientes aspectos:',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Campo de nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tu nombre o alias',
                hintText: 'Dungeon Master',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Calificación general
            if (_ratingData != null) ...[
              Card(
                color: Colors.brown.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calificación General:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _ratingData!.overallRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          const Text(
                            ' / 5.0',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < _ratingData!.overallRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categorías de valoración
              for (var category in _ratingData!.categories) ...[
                _buildCategorySection(category),
                const SizedBox(height: 24),
              ],

              // Botón de envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sendRating,
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar Valoración'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye una sección de categoría
  Widget _buildCategorySection(RatingCategory category) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${category.averageRating.toStringAsFixed(1)} ⭐',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...category.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionItem(category, index, question);
            }),
          ],
        ),
      ),
    );
  }

  /// Construye un ítem de pregunta con rating
  Widget _buildQuestionItem(
      RatingCategory category, int index, RatingQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (starIndex) {
              final starValue = starIndex + 1;
              return IconButton(
                icon: Icon(
                  starValue <= question.valor ? Icons.star : Icons.star_border,
                  size: 32,
                ),
                color: starValue <= question.valor
                    ? Colors.amber
                    : Colors.grey.shade400,
                onPressed: () => _updateRating(category, index, starValue),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            question.valor == 0 ? 'Sin calificación' : question.max,
            style: TextStyle(
              fontSize: 12,
              color: question.valor == 0 ? Colors.grey : Colors.green.shade700,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          if (index < category.questions.length - 1)
            const Divider(height: 32),
        ],
      ),
    );
  }
}