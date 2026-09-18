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
  List<String> _userAnswers = []; // jawaban per-index, untuk kompatibilitas
  Map<String, String> _answersMap = {}; // {questionId: selectedOptionId}
  int _score = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isQuizCompleted = false;
  bool _isReviewMode = false; // true saat tampilkan review screen
  bool _isEditingFromReview = false; // true saat user jump dari review ke soal untuk edit

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
  bool get isLastQuestion =>
      _currentQuestionIndex >= _questionsWithOptions.length - 1;
  bool get isReviewMode => _isReviewMode;
  bool get isEditingFromReview => _isEditingFromReview;

  /// Map dari questionId ke selectedOptionId
  Map<String, String> get answersMap => Map.unmodifiable(_answersMap);

  /// Daftar soal yang belum dijawab (question index yang tidak ada di _answersMap)
  List<int> get unansweredQuestionIndices {
    final List<int> unanswered = [];
    for (int i = 0; i < _questionsWithOptions.length; i++) {
      final question =
          _questionsWithOptions[i]['question'] as QuestionModel;
      if (!_answersMap.containsKey(question.id)) {
        unanswered.add(i);
      }
    }
    return unanswered;
  }

  bool get allAnswered => unansweredQuestionIndices.isEmpty;

  /// Jawaban terpilih untuk soal yang sedang aktif (untuk pre-select saat jump)
  String? getSelectedOptionForQuestion(String questionId) {
    return _answersMap[questionId];
  }

  /// Load quiz berdasarkan challenge dengan caching
  Future<void> loadQuiz(ChallengeModel challenge) async {
    // Jika data sudah ada di cache dan challenge sama, gunakan cache
    if (_questionsCache.containsKey(challenge.id) &&
        _currentChallenge?.id == challenge.id &&
        _questionsWithOptions.isNotEmpty) {
      _questionsWithOptions = _questionsCache[challenge.id]!;
      _currentQuestionIndex = 0;
      _userAnswers = [];
      _answersMap = {};
      _score = 0;
      _isQuizCompleted = false;
      _isReviewMode = false;
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
      _answersMap = {};
      _score = 0;
      _isQuizCompleted = false;
      _isReviewMode = false;

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
  /// Jawaban disimpan ke _answersMap (lokal). DB save dilakukan di submitFinalAnswers.
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

    // Simpan ke answersMap
    _answersMap[currentQuestion.id] = selectedOptionId;

    // Update userAnswers list (index-based, untuk kompatibilitas)
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = selectedOptionId;
    } else {
      _userAnswers.add(selectedOptionId);
    }

    // Update score lokal
    _score += selectedOption.scoreOption;

    // Pindah ke pertanyaan selanjutnya atau kembali ke review mode jika sedang edit dari review
    if (_isEditingFromReview) {
      _isReviewMode = true;
      _isEditingFromReview = false;
      notifyListeners();
    } else if (_currentQuestionIndex < _questionsWithOptions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      // Soal terakhir dijawab → masuk review mode
      _isReviewMode = true;
      notifyListeners();
    }
  }

  /// Masuk ke review mode tanpa mengubah index
  void enterReviewMode() {
    _isReviewMode = true;
    _isEditingFromReview = false;
    notifyListeners();
  }

  /// Keluar dari review mode, jump ke soal tertentu untuk edit
  void jumpToQuestion(int questionIndex) {
    _currentQuestionIndex = questionIndex;
    _isReviewMode = false;
    _isEditingFromReview = true;
    notifyListeners();
  }

  /// Update jawaban dari review screen (tanpa pindah halaman)
  void updateAnswerInMap(String questionId, String optionId) {
    _answersMap[questionId] = optionId;
    notifyListeners();
  }

  /// Submit semua jawaban final ke DB dan hitung REI result
  /// Dipanggil dari review screen saat user menekan "Kirim Jawaban"
  Future<void> submitFinalAnswers({
    required UserProvider userProvider,
  }) async {
    if (!userProvider.isUserLoggedIn) return;

    // Loading state dikelola oleh QuizReviewWidget (_isSubmitting),
    // jangan set _isLoading di sini agar review screen tidak terblokir.

    try {
      // Buat list payload untuk bulk save
      final List<Map<String, String>> answersPayload = [];
      for (int i = 0; i < _questionsWithOptions.length; i++) {
        final question =
            _questionsWithOptions[i]['question'] as QuestionModel;
        final selectedOptionId = _answersMap[question.id];
        if (selectedOptionId == null || selectedOptionId.isEmpty) continue;

        answersPayload.add({
          'questionId': question.id,
          'selectedOptionId': selectedOptionId,
        });
      }

      print('QuizProvider: Bulk saving ${answersPayload.length} answers...');

      // Simpan semua sekaligus (DELETE lama + INSERT baru)
      final saveOk = await userProvider.saveAllAnswersBulk(
        answers: answersPayload,
      );

      if (!saveOk) {
        print('QuizProvider: Bulk save failed, tapi tetap lanjut hitung REI');
      }

      // Recalculate _userAnswers dari _answersMap (index-based untuk calculateAndSaveReiResult)
      _userAnswers = [];
      for (int i = 0; i < _questionsWithOptions.length; i++) {
        final question =
            _questionsWithOptions[i]['question'] as QuestionModel;
        final optId = _answersMap[question.id] ?? '';
        _userAnswers.add(optId);
      }

      // Hitung dan simpan REI result
      await userProvider.calculateAndSaveReiResult(
        questionsWithOptions: _questionsWithOptions,
        userAnswers: _userAnswers,
      );

      _isReviewMode = false;
      _isQuizCompleted = true;
      notifyListeners();
    } catch (e) {
      print('QuizProvider: submitFinalAnswers error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Developer Mode: Auto-fill all remaining questions
  Future<void> autoFillAllAnswers({
    UserProvider? userProvider,
    String template = 'high',
  }) async {
    if (_questionsWithOptions.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final total = _questionsWithOptions.length;

      for (int i = 0; i < total; i++) {
        final question = _questionsWithOptions[i]['question'] as QuestionModel;
        if (_answersMap.containsKey(question.id)) continue; // skip yang sudah ada

        final options = List<OptionModel>.from(
          _questionsWithOptions[i]['options'] as List<OptionModel>,
        );
        OptionModel selectedOpt;

        if (template == 'high') {
          options.sort((a, b) => b.scoreOption.compareTo(a.scoreOption));
          selectedOpt = options.first;
        } else if (template == 'medium') {
          selectedOpt = options.firstWhere(
            (o) => o.scoreOption == 3,
            orElse: () => options[options.length ~/ 2],
          );
        } else {
          options.shuffle();
          selectedOpt = options.first;
        }

        _answersMap[question.id] = selectedOpt.id;
        _score += selectedOpt.scoreOption;
      }

      _currentQuestionIndex = total - 1;
      _isReviewMode = true; // Langsung ke review mode

      if (userProvider != null && userProvider.isUserLoggedIn) {
        await submitFinalAnswers(userProvider: userProvider);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('AutoFill error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Reset quiz
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _answersMap = {};
    _score = 0;
    _isQuizCompleted = false;
    _isReviewMode = false;
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
