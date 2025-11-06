/// Widget para cards de contenido
import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const ContentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: enabled
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : const Text(
                'Próximamente',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}