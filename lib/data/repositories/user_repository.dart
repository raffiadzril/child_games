import '../services/supabase_service.dart';
import '../models/user_model.dart';

/// Repository untuk mengelola data user
class UserRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get user profile by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabaseService.select('users');
      final userJson = response.firstWhere((user) => user['id'] == userId);
      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<UserModel?> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabaseService.update('users', userId, data);
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create user profile
  Future<UserModel?> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _supabaseService.insert('users', userData);
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get leaderboard
  Future<List<UserModel>> getLeaderboard() async {
    try {
      final response = await _supabaseService.select('users');
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
