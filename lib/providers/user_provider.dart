import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../data/models/user_answer_model.dart';
import '../data/models/rei_accumulate_model.dart';

/// Provider untuk mengelola data user dan jawaban
class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final List<UserAnswerModel> _userAnswers = [];
  ReiAccumulateModel? _reiResult;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  List<UserAnswerModel> get userAnswers => List.unmodifiable(_userAnswers);
  bool get isUserLoggedIn => _currentUser != null;
  ReiAccumulateModel? get reiResult => _reiResult;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Register user baru dengan biodata
  Future<bool> registerUser({
    required String name,
    required String gender,
    required int age,
    required String className,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Buat user model
      final user = UserModel(
        name: name,
        gender: gender,
        age: age,
        className: className,
      );

      print('UserProvider: Attempting to register user: ${user.toJson()}');

      // Insert ke Supabase
      final response =
          await _supabase.from('users').insert(user.toJson()).select().single();

      print('UserProvider: User registered successfully: $response');

      // Set current user
      _currentUser = UserModel.fromJson(response);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('UserProvider: Error registering user: $e');
      _setError('Gagal mendaftarkan user: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Simpan jawaban user
  Future<bool> saveUserAnswer({
    required String questionId,
    required String selectedOptionId,
  }) async {
    if (_currentUser == null) {
      _setError('User belum login');
      return false;
    }

    try {
      // Buat user answer model
      final userAnswer = UserAnswerModel(
        userId: _currentUser!.id,
        questionId: questionId,
        selectedOptionId: selectedOptionId,
      );

      print('UserProvider: Attempting to save answer: ${userAnswer.toJson()}');

      // Insert ke Supabase
      final response =
          await _supabase
              .from('user_answers')
              .insert(userAnswer.toJson())
              .select()
              .single();

      print('UserProvider: Answer saved successfully: $response');

      // Tambah ke local list
      final savedAnswer = UserAnswerModel.fromJson(response);
      _userAnswers.add(savedAnswer);

      notifyListeners();
      return true;
    } catch (e) {
      print('UserProvider: Error saving answer: $e');
      _setError('Gagal menyimpan jawaban: $e');
      return false;
    }
  }

  /// Load jawaban user untuk quiz tertentu
  Future<void> loadUserAnswers() async {
    if (_currentUser == null) return;

    try {
      final response = await _supabase
          .from('user_answers')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('answered_at', ascending: false);

      print('UserProvider: Loaded ${response.length} user answers');

      _userAnswers.clear();
      _userAnswers.addAll(
        response.map((json) => UserAnswerModel.fromJson(json)).toList(),
      );

      notifyListeners();
    } catch (e) {
      print('UserProvider: Error loading user answers: $e');
      _setError('Gagal memuat jawaban: $e');
    }
  }

  /// Logout user
  void logout() {
    _currentUser = null;
    _userAnswers.clear();
    _clearError();
    notifyListeners();
  }

  /// Check if user has answered a specific question
  bool hasAnsweredQuestion(String questionId) {
    return _userAnswers.any((answer) => answer.questionId == questionId);
  }

  /// Get user's answer for a specific question
  UserAnswerModel? getUserAnswerForQuestion(String questionId) {
    try {
      return _userAnswers.firstWhere(
        (answer) => answer.questionId == questionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Load hasil REI untuk user
  Future<ReiAccumulateModel?> loadReiResult() async {
    if (_currentUser == null) {
      _setError('User belum login');
      return null;
    }

    // Return cached result if available
    if (_reiResult != null) {
      print('UserProvider: Returning cached REI result');
      return _reiResult;
    }

    try {
      print('UserProvider: Loading REI result for user: ${_currentUser!.id}');

      final response =
          await _supabase
              .from('rei_accumulate')
              .select()
              .eq('user_id', _currentUser!.id)
              .maybeSingle(); // Gunakan maybeSingle karena mungkin belum ada data

      if (response != null) {
        print('UserProvider: REI result loaded: $response');
        _reiResult = ReiAccumulateModel.fromJson(response);
        notifyListeners();
        return _reiResult;
      } else {
        print('UserProvider: No REI result found for user');
        return null;
      }
    } catch (e) {
      print('UserProvider: Error loading REI result: $e');
      _setError('Gagal memuat hasil REI: $e');
      return null;
    }
  }

  /// Check if user has REI result
  bool get hasReiResult => _reiResult != null;

  /// Reset REI result
  void resetReiResult() {
    _reiResult = null;
    notifyListeners();
  }

  /// Reset user data (for testing)
  void reset() {
    _currentUser = null;
    _userAnswers.clear();
    _reiResult = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
  }

  void _clearError() {
    _errorMessage = null;
  }
}
