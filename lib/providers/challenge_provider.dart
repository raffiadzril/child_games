import 'package:flutter/foundation.dart';
import '../data/models/challenge_model.dart';
import '../data/repositories/challenge_repository.dart';

/// Provider untuk mengelola state challenges
class ChallengeProvider extends ChangeNotifier {
  final ChallengeRepository _challengeRepository = ChallengeRepository();

  // Private state
  List<ChallengeModel> _challenges = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters
  List<ChallengeModel> get challenges => _challenges;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _challenges.isEmpty;

  ChallengeProvider() {
    print('ChallengeProvider constructor called');
  }

  /// Load all challenges from database
  Future<void> loadChallenges() async {
    print('ChallengeProvider: loadChallenges called');
    _setLoading(true);
    _clearError();

    try {
      _challenges = await _challengeRepository.getAllChallenges();
      print('ChallengeProvider: Loaded ${_challenges.length} challenges');
    } catch (e) {
      print('ChallengeProvider: Error loading challenges: $e');
      _setError('Gagal memuat challenges: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh challenges data
  Future<void> refreshChallenges() async {
    await loadChallenges();
  }

  /// Get challenge by ID
  ChallengeModel? getChallengeById(String id) {
    try {
      return _challenges.firstWhere((challenge) => challenge.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
