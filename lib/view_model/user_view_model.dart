import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/supabase_service.dart';

/// ViewModel untuk mengelola state dan logic user
class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final SupabaseService _supabaseService = SupabaseService.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _supabaseService.isLoggedIn;

  /// Initialize user data
  Future<void> init() async {
    if (_supabaseService.isLoggedIn) {
      await getCurrentUser();
    }
  }

  /// Get current user data
  Future<void> getCurrentUser() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _supabaseService.currentUser;
      if (user != null) {
        final userData = await _userRepository.getUserById(user.id);
        _currentUser = userData;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }


 

  /// Logout user
  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.signOut();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser != null) {
        data['updated_at'] = DateTime.now().toIso8601String();
        final updatedUser = await _userRepository.updateUser(
          _currentUser!.id,
          data,
        );
        if (updatedUser != null) {
          _currentUser = updatedUser;
          return true;
        }
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user score
  Future<void> updateScore(int score) async {
    if (_currentUser != null) {
      final newTotalScore = _currentUser!.totalScore + score;
      await updateProfile({'total_score': newTotalScore});
    }
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
