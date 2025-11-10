import 'package:flutter/material.dart';
import 'edition_detail_page.dart';
import '../models/edition.dart' as edition;
import '../widgets/EditionCard.dart' show EditionCard;
// EditionsPage: muestra una lista de ediciones antiguas de D&D
class EditionsPage extends StatelessWidget {
  const EditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final editions = edition.Edition.getSample();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ediciones de D&D'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: editions.length,
        itemBuilder: (context, index) {
          final edition = editions[index];
          return  EditionCard(
            edition: edition,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditionDetailPage(edition: edition),
                ),
              );
            },
          );
        },
      ),
    );
  }
}