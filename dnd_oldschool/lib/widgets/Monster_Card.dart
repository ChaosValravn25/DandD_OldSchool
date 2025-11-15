// lib/widgets/monster_card.dart
import 'package:flutter/material.dart';
import '../models/monster.dart';
import 'Badge.dart';
import 'dart:io';
/// Widget de tarjeta de monstruo
class MonsterCard extends StatelessWidget {
  final Monster monster;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;

  const MonsterCard({
    super.key,
    required this.monster,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del monstruo
              _buildMonsterImage(),
              const SizedBox(width: 12),

              // Información del monstruo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y botón de favorito
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            monster.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            monster.isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: monster.isFavorite
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          onPressed: onFavoriteToggle,
                          tooltip: 'Marcar como favorito',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Badges de información
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        CustomBadge(
                          icon: Icons.history_edu,
                          label: monster.edition,
                          color: Colors.brown,
                        ),
                        if (monster.type != null)
                          CustomBadge(
                            icon: Icons.category,
                            label: monster.type!,
                            color: Colors.purple,
                          ),
                        CustomBadge(
                          icon: Icons.favorite,
                          label: 'HP ${monster.hp}',
                          color: Colors.red,
                        ),
                        if (monster.ac != null)
                          CustomBadge(
                            icon: Icons.shield,
                            label: 'AC ${monster.ac}',
                            color: Colors.blue,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Descripción
                    Text(
                      monster.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón compartir
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                onPressed: onShare,
                tooltip: 'Compartir',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reemplaza _buildMonsterImage() por esto:
Widget _buildMonsterImage() {
  if (monster.imagePath != null && monster.imagePath!.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(monster.imagePath!),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage();
        },
      ),
    );
  }
  return _fallbackImage();
}

Widget _fallbackImage() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 80,
      height: 80,
      color: _getColorForType(monster.type).withOpacity(0.3),
      child: Icon(
        _getIconForType(monster.type),
        size: 40,
        color: _getColorForType(monster.type),
      ),
    ),
  );
}

  /// Obtiene color según el tipo de monstruo
  Color _getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'undead':
        return Colors.grey.shade700;
      case 'dragon':
        return Colors.red.shade700;
      case 'beast':
      case 'animal':
        return Colors.brown.shade600;
      case 'humanoid':
        return Colors.blue.shade600;
      case 'aberration':
        return Colors.purple.shade700;
      case 'ooze':
        return Colors.green.shade600;
      case 'construct':
        return Colors.blueGrey.shade700;
      case 'elemental':
        return Colors.orange.shade700;
      case 'fey':
        return Colors.pink.shade400;
      case 'giant':
        return Colors.brown.shade800;
      case 'magical beast':
      case 'monstrosity':
        return Colors.deepPurple.shade600;
      case 'fiend':
        return Colors.red.shade900;
      case 'celestial':
        return Colors.amber.shade600;
      case 'plant':
        return Colors.green.shade700;
      default:
        return Colors.brown.shade600;
    }
  }

  /// Obtiene el icono según el tipo de monstruo
  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'undead':
        return Icons.nightlight;
      case 'dragon':
        return Icons.wb_sunny;
      case 'beast':
      case 'animal':
        return Icons.pets;
      case 'humanoid':
        return Icons.person;
      case 'aberration':
        return Icons.visibility;
      case 'ooze':
        return Icons.opacity;
      case 'construct':
        return Icons.build;
      case 'elemental':
        return Icons.whatshot;
      case 'fey':
        return Icons.auto_awesome;
      case 'giant':
        return Icons.terrain;
      case 'magical beast':
        return Icons.stars;
      default:
        return Icons.pets;
    }
  }
}