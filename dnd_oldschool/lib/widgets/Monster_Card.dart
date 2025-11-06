import 'package:dnd_oldschool/models/monster.dart';
import 'package:flutter/material.dart';
import 'Badge.dart';

/// Widget de tarjeta de monstruo
class MonsterCard extends StatelessWidget {
  final Monster monster;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;

  const MonsterCard({super.key, 
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
              // Imagen
              if (monster.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    monster.imagePath!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.pets, size: 40),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}