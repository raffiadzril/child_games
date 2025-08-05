import 'package:flutter/material.dart';
import '../data/models/game_model.dart';
import '../data/repositories/game_repository.dart';

/// ViewModel untuk mengelola state dan logic game
class GameViewModel extends ChangeNotifier {
  final GameRepository _gameRepository = GameRepository();

  List<GameModel> _games = [];
  List<GameModel> _filteredGames = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  int? _selectedAge;

  // Getters
  List<GameModel> get games => _filteredGames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  int? get selectedAge => _selectedAge;

  /// Load all games
  Future<void> loadGames() async {
    try {
      _setLoading(true);
      _clearError();

      _games = await _gameRepository.getAllGames();
      _applyFilters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Filter games by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Filter games by age
  void filterByAge(int? age) {
    _selectedAge = age;
    _applyFilters();
  }

  /// Search games
  Future<void> searchGames(String query) async {
    if (query.isEmpty) {
      _filteredGames = List.from(_games);
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      final searchResults = await _gameRepository.searchGames(query);
      _filteredGames = searchResults;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get game by ID
  Future<GameModel?> getGameById(String gameId) async {
    try {
      return await _gameRepository.getGameById(gameId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = 'all';
    _selectedAge = null;
    _applyFilters();
  }

  /// Apply current filters
  void _applyFilters() {
    _filteredGames =
        _games.where((game) {
          // Category filter
          if (_selectedCategory != 'all' &&
              game.category != _selectedCategory) {
            return false;
          }

          // Age filter
          if (_selectedAge != null) {
            if (game.minAge > _selectedAge! || game.maxAge < _selectedAge!) {
              return false;
            }
          }

          return true;
        }).toList();

    notifyListeners();
  }

  /// Get available categories
  List<String> getCategories() {
    final categories = _games.map((game) => game.category).toSet().toList();
    categories.sort();
    return ['all', ...categories];
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
