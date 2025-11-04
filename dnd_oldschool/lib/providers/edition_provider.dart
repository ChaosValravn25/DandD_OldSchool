import 'package:flutter/material.dart';

class EditionProvider extends ChangeNotifier {
  // Current selected edition
  String _currentEdition = 'Basic';

  // Available editions
  final List<String> _editions = [
    'Basic',
    'Advanced',
    'AD&D 2nd Edition',
    'D&D 3rd Edition',
    'D&D 3.5',
  ];

  // Getters
  String get currentEdition => _currentEdition;
  List<String> get editions => _editions;

  // Method to change edition
  void setEdition(String edition) {
    if (_editions.contains(edition)) {
      _currentEdition = edition;
      notifyListeners();
    }
  }
}