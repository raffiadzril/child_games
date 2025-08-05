import '../services/supabase_service.dart';
import '../models/game_model.dart';

/// Repository untuk mengelola data game
class GameRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  /// Get all games
  Future<List<GameModel>> getAllGames() async {
    try {
      final response = await _supabaseService.select('games');
      return response.map((json) => GameModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Get game by ID
  Future<GameModel?> getGameById(String gameId) async {
    try {
      final response = await _supabaseService.select('games');
      final gameJson = response.firstWhere((game) => game['id'] == gameId);
      return GameModel.fromJson(gameJson);
    } catch (e) {
      return null;
    }
  }
  
  /// Search games by title
  Future<List<GameModel>> searchGames(String query) async {
    try {
      final response = await _supabaseService.select('games');
      final filteredGames = response
          .where((game) => 
              (game['title'] as String).toLowerCase().contains(query.toLowerCase()) ||
              (game['description'] as String).toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return filteredGames.map((json) => GameModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
