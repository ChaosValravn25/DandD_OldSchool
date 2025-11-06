// lib/widgets/stat_block.dart
import 'package:flutter/material.dart';

/// Widget compacto para mostrar una "stat block" (p. ej. puntuación de habilidad
/// en un juego de rol): etiqueta, valor (score) y modificador.
/// Diseñado para D&D Old School - muestra atributos de personajes o monstruos.
class StatBlock extends StatelessWidget {
  final String label; // p. ej. "FUE", "DEX", "INT", "HP", "AC"
  final int score; // puntuación, p. ej. 16
  final int? modifier; // modificador opcional; si es null se calcula desde score
  final bool proficient; // si tiene competencia (opcional para estilo)
  final double size; // tamaño base del bloque
  final VoidCallback? onTap;

  const StatBlock({
    super.key,
    required this.label,
    required this.score,
    this.modifier,
    this.proficient = false,
    this.size = 64.0,
    this.onTap,
  });

  int get _modifier => modifier ?? ((score - 10) ~/ 2);

  String get _formattedModifier {
    final m = _modifier;
    return (m >= 0) ? '+$m' : '$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ✅ Estilos actualizados para Flutter 3 / Material 3
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    final scoreStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final modStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
    );

    Widget content = SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Etiqueta
          Text(
            label.toUpperCase(),
            style: labelStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          
          // Bloque de puntuación
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text('$score', style: scoreStyle),
          ),
          const SizedBox(height: 6),
          
          // Modificador
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (proficient)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.star,
                    size: 14,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              Text(_formattedModifier, style: modStyle),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: content,
        ),
      );
    }

    return content;
  }
}

// ============= EJEMPLO DE USO =============

/// Ejemplo: Cómo usar StatBlock en una pantalla de detalles de personaje
class StatBlockExample extends StatelessWidget {
  const StatBlockExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo StatBlock')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atributos del Personaje',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Fila de atributos principales (D&D)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                StatBlock(label: 'FUE', score: 16), // +3
                StatBlock(label: 'DES', score: 14), // +2
                StatBlock(label: 'CON', score: 15), // +2
                StatBlock(label: 'INT', score: 10), // +0
                StatBlock(label: 'SAB', score: 12), // +1
                StatBlock(label: 'CAR', score: 8),  // -1
              ],
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Stats de Combate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Stats de combate con modificadores explícitos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                StatBlock(
                  label: 'HP',
                  score: 45,
                  modifier: 0, // Sin modificador
                  size: 72,
                ),
                StatBlock(
                  label: 'AC',
                  score: 17,
                  modifier: 0,
                  size: 72,
                ),
                StatBlock(
                  label: 'INI',
                  score: 14,
                  modifier: 2,
                  proficient: true, // Con competencia
                  size: 72,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}