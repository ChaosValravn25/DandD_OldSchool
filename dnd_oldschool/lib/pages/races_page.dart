import 'package:flutter/material.dart';

class RacesPage extends StatefulWidget {
  const RacesPage({super.key});

  @override
  State<RacesPage> createState() => _RacesPageState();
}

class _RacesPageState extends State<RacesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Races'),
        backgroundColor: Colors.brown[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            // Here you'll add your race cards or list items
          ],
        ),
      ),
    );
  }
}