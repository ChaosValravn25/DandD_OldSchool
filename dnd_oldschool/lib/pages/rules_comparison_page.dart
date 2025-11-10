import 'package:flutter/material.dart';

class RuleComparisonCard extends StatelessWidget {
  final String title;
  final Map<String, String> rules;

  const RuleComparisonCard({
    required this.title,
    required this.rules,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...rules.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}