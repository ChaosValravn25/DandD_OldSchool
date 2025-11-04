import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  // Set to store favorite item IDs
  final Set<String> _favorites = {};

  // Getter to access favorites
  Set<String> get favorites => _favorites;

  // Check if an item is favorite
  bool isFavorite(String id) {
    return _favorites.contains(id);
  }

  // Toggle favorite status
  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  // Clear all favorites
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}