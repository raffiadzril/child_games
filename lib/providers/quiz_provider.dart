import 'package:flutter/material.dart';
import '../data/models/challenge_model.dart';
import '../data/models/question_model.dart';
import '../data/models/option_model.dart';
import '../data/repositories/question_repository.dart';
import 'user_provider.dart';

/// Provider untuk mengelola state quiz
class QuizProvider extends ChangeNotifier {
  final QuestionRepository _questionRepository = QuestionRepository();

  // State properties
  ChallengeModel? _currentChallenge;
  List<Map<String, dynamic>> _questionsWithOptions = [];
  int _currentQuestionIndex = 0;
  List<String> _userAnswers = [];
  int _score = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isQuizCompleted = false;

  // Cache untuk mempercepat loading
  static final Map<String, List<Map<String, dynamic>>> _questionsCache = {};

  // Getters
  ChallengeModel? get currentChallenge => _currentChallenge;
  List<Map<String, dynamic>> get questionsWithOptions => _questionsWithOptions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questionsWithOptions.length;
  QuestionModel? get currentQuestion =>
      _questionsWithOptions.isNotEmpty
          ? _questionsWithOptions[_currentQuestionIndex]['question']
          : null;
  List<OptionModel>? get currentOptions =>
      _questionsWithOptions.isNotEmpty
          ? _questionsWithOptions[_currentQuestionIndex]['options']
          : null;
  int get score => _score;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get hasError => _errorMessage != null;

  /// Load quiz berdasarkan challenge dengan caching
  Future<void> loadQuiz(ChallengeModel challenge) async {
    // Jika data sudah ada di cache dan challenge sama, gunakan cache
    if (_questionsCache.containsKey(challenge.id) &&
        _currentChallenge?.id == challenge.id &&
        _questionsWithOptions.isNotEmpty) {
      _questionsWithOptions = _questionsCache[challenge.id]!;
      _currentQuestionIndex = 0;
      _userAnswers = [];
      _score = 0;
      _isQuizCompleted = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentChallenge = challenge;

      // Cek cache terlebih dahulu
      if (_questionsCache.containsKey(challenge.id)) {
        _questionsWithOptions = _questionsCache[challenge.id]!;
      } else {
        // Load dari database dan simpan ke cache
        _questionsWithOptions = await _questionRepository
            .getQuestionsWithOptions(challenge.id);
        _questionsCache[challenge.id] = _questionsWithOptions;
      }

      _currentQuestionIndex = 0;
      _userAnswers = [];
      _score = 0;
      _isQuizCompleted = false;

      if (_questionsWithOptions.isEmpty) {
        throw Exception('Tidak ada pertanyaan untuk challenge ini');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit jawaban dan pindah ke pertanyaan selanjutnya
  Future<void> submitAnswer(
    String selectedOptionId, {
    UserProvider? userProvider,
  }) async {
    if (_currentQuestionIndex >= _questionsWithOptions.length) return;

    final currentOptions =
        _questionsWithOptions[_currentQuestionIndex]['options']
            as List<OptionModel>;
    final selectedOption = currentOptions.firstWhere(
      (option) => option.id == selectedOptionId,
    );

    final currentQuestion =
        _questionsWithOptions[_currentQuestionIndex]['question']
            as QuestionModel;

    // Simpan jawaban user
    _userAnswers.add(selectedOptionId);

    // Update score berdasarkan scoreOption
    _score += selectedOption.scoreOption;

    // Simpan jawaban ke database jika userProvider tersedia
    if (userProvider != null && userProvider.isUserLoggedIn) {
      try {
        await userProvider.saveUserAnswer(
          questionId: currentQuestion.id,
          selectedOptionId: selectedOptionId,
        );
        print('QuizProvider: Answer saved successfully');
      } catch (e) {
        print('QuizProvider: Failed to save answer: $e');
        // Note: Kita tidak menghentikan quiz jika gagal save answer
        // karena user masih bisa melanjutkan quiz
      }
    }

    // Pindah ke pertanyaan selanjutnya atau selesaikan quiz
    if (_currentQuestionIndex < _questionsWithOptions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _isQuizCompleted = true;
    }

    notifyListeners();
  }

  /// Reset quiz
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _score = 0;
    _isQuizCompleted = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear cache untuk refresh data
  static void clearCache() {
    _questionsCache.clear();
  }

  /// Clear cache untuk challenge tertentu
  static void clearCacheForChallenge(String challengeId) {
    _questionsCache.remove(challengeId);
  }

  /// Get maximum possible score
  int get maxPossibleScore {
    int maxScore = 0;
    for (var questionWithOptions in _questionsWithOptions) {
      final options = questionWithOptions['options'] as List<OptionModel>;
      final maxOptionScore = options
          .map((o) => o.scoreOption)
          .fold(0, (max, score) => score > max ? score : max);
      maxScore += maxOptionScore;
    }
    return maxScore;
  }

  /// Get progress percentage
  double get progress =>
      totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;
}
