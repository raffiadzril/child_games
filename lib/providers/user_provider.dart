import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../data/models/user_answer_model.dart';
import '../data/models/rei_accumulate_model.dart';
import '../data/models/question_model.dart';
import '../data/models/option_model.dart';

/// Provider untuk mengelola data user dan jawaban
class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final List<UserAnswerModel> _userAnswers = [];
  ReiAccumulateModel? _reiResult;
  String? _selectedAgeCategory; // '<13' atau '>=13'

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  List<UserAnswerModel> get userAnswers => List.unmodifiable(_userAnswers);
  bool get isUserLoggedIn => _currentUser != null;
  ReiAccumulateModel? get reiResult => _reiResult;
  String? get selectedAgeCategory => _selectedAgeCategory;
  bool get isAdultMode => _selectedAgeCategory == '>=13';

  void setSelectedAgeCategory(String? category) {
    _selectedAgeCategory = category;
    notifyListeners();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Register user baru dengan biodata & kuesioner awal
  Future<bool> registerUser({
    required String name,
    required String gender,
    required int age,
    String? educationLevel,
    String className = '',
    String school = '',
    String? surveyType,
    String? isActiveSportsMember,
    String? sportsDuration,
    String? sportsFrequency,
    String? sportsLiking,
    String? hasSportsCompetition,
    String? likesSportsCompetition,
    String? competitionType,
    String? competitionLevel,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Buat user model
      final user = UserModel(
        name: name,
        gender: gender,
        age: age,
        educationLevel: educationLevel,
        className: className,
        school: school,
        surveyType: surveyType,
        isActiveSportsMember: isActiveSportsMember,
        sportsDuration: sportsDuration,
        sportsFrequency: sportsFrequency,
        sportsLiking: sportsLiking,
        hasSportsCompetition: hasSportsCompetition,
        likesSportsCompetition: likesSportsCompetition,
        competitionType: competitionType,
        competitionLevel: competitionLevel,
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

  /// Simpan jawaban user (single)
  Future<bool> saveUserAnswer({
    required String questionId,
    required String selectedOptionId,
  }) async {
    if (_currentUser == null) {
      _setError('User belum login');
      return false;
    }

    try {
      final userAnswer = UserAnswerModel(
        userId: _currentUser!.id,
        questionId: questionId,
        selectedOptionId: selectedOptionId,
      );

      print('UserProvider: Attempting to save answer: ${userAnswer.toJson()}');

      // Delete existing dulu (jika ada), lalu insert baru — tidak butuh unique constraint
      await _supabase
          .from('user_answers')
          .delete()
          .eq('user_id', _currentUser!.id)
          .eq('question_id', questionId);

      final response = await _supabase
          .from('user_answers')
          .insert(userAnswer.toJson())
          .select()
          .single();

      print('UserProvider: Answer saved successfully: $response');

      // Update local list
      _userAnswers.removeWhere((a) => a.questionId == questionId);
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

  /// Simpan SEMUA jawaban quiz sekaligus (bulk) — lebih reliable dari save satu per satu
  /// Strategi: DELETE semua jawaban lama untuk soal-soal ini, lalu INSERT semuanya sekaligus
  Future<bool> saveAllAnswersBulk({
    required List<Map<String, String>> answers,
  }) async {
    if (_currentUser == null) {
      _setError('User belum login');
      return false;
    }

    if (answers.isEmpty) return true;

    try {
      final userId = _currentUser!.id;
      final questionIds = answers.map((a) => a['questionId']!).toList();

      print('UserProvider: Bulk saving ${answers.length} answers...');

      // 1. Hapus semua jawaban lama untuk soal-soal ini
      await _supabase
          .from('user_answers')
          .delete()
          .eq('user_id', userId)
          .inFilter('question_id', questionIds);

      // 2. Buat payload bulk insert
      final now = DateTime.now().toIso8601String();
      final payload = answers.map((a) => {
        'user_id': userId,
        'question_id': a['questionId']!,
        'selected_option_id': a['selectedOptionId']!,
        'answered_at': now,
      }).toList();

      // 3. Bulk insert semua sekaligus
      final response = await _supabase
          .from('user_answers')
          .insert(payload)
          .select();

      print('UserProvider: Bulk save success — ${response.length} answers saved');

      // Update local list
      _userAnswers.removeWhere((a) => questionIds.contains(a.questionId));
      _userAnswers.addAll(
        response.map((json) => UserAnswerModel.fromJson(json)).toList(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      print('UserProvider: Error bulk saving answers: $e');
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

  /// Calculate REI score & save to Supabase according to REI Update 2026 guidelines
  Future<ReiAccumulateModel?> calculateAndSaveReiResult({
    required List<Map<String, dynamic>> questionsWithOptions,
    required List<String> userAnswers,
  }) async {
    if (_currentUser == null) {
      _setError('User belum login');
      return null;
    }

    _setLoading(true);

    try {
      int respectScore = 0;
      int equityScore = 0;
      int inclusionScore = 0;
      int respectCount = 0;
      int equityCount = 0;
      int inclusionCount = 0;

      final totalQuestions = questionsWithOptions.length;

      for (int i = 0; i < totalQuestions && i < userAnswers.length; i++) {
        final qMap = questionsWithOptions[i];
        final question = qMap['question'] as QuestionModel;
        final options = qMap['options'] as List<OptionModel>;
        final selectedOptId = userAnswers[i];

        final selectedOpt = options.firstWhere(
          (o) => o.id == selectedOptId,
          orElse: () => options.first,
        );

        final score = selectedOpt.scoreOption;
        final qNum = question.questionNumber;

        if (totalQuestions > 20) {
          // 45 Questions (Adult 13+): Q1-15 Respect, Q16-30 Equity, Q31-45 Inclusion
          if (qNum <= 15) {
            respectScore += score;
            respectCount++;
          } else if (qNum <= 30) {
            equityScore += score;
            equityCount++;
          } else {
            inclusionScore += score;
            inclusionCount++;
          }
        } else {
          // 15 Questions (Child <13): Q1-5 Respect, Q6-10 Equity, Q11-15 Inclusion
          if (qNum <= 5) {
            respectScore += score;
            respectCount++;
          } else if (qNum <= 10) {
            equityScore += score;
            equityCount++;
          } else {
            inclusionScore += score;
            inclusionCount++;
          }
        }
      }

      final respectMean = respectCount > 0 ? respectScore / respectCount : 0.0;
      final equityMean = equityCount > 0 ? equityScore / equityCount : 0.0;
      final inclusionMean =
          inclusionCount > 0 ? inclusionScore / inclusionCount : 0.0;
      final overallCount = respectCount + equityCount + inclusionCount;
      final overallMean = overallCount > 0
          ? (respectScore + equityScore + inclusionScore) / overallCount
          : 0.0;

      String determineCategory(double mean) {
        if (mean <= 2.33) {
          return 'Rendah';
        } else if (mean <= 3.67) {
          return 'Sedang';
        } else {
          return 'Tinggi';
        }
      }

      final respectCat = determineCategory(respectMean);
      final equityCat = determineCategory(equityMean);
      final inclusionCat = determineCategory(inclusionMean);
      final overallCat = determineCategory(overallMean);

      String getRespectNote(String cat) {
        switch (cat) {
          case 'Rendah':
            return 'Perlu meningkatkan pemahaman dalam menghargai diri sendiri dan orang lain.';
          case 'Sedang':
            return 'Cukup baik dalam menghargai diri dan orang lain, tingkatkan konsistensi.';
          case 'Tinggi':
          default:
            return 'Sangat baik dalam menerapkan sikap saling menghargai dan menghormati.';
        }
      }

      String getEquityNote(String cat) {
        switch (cat) {
          case 'Rendah':
            return 'Perlu memahami lebih dalam tentang pentingnya keadilan dan dukungan bersama.';
          case 'Sedang':
            return 'Memiliki pemahaman keadilan yang cukup baik dalam situasi bermain.';
          case 'Tinggi':
          default:
            return 'Sangat menjunjung tinggi keadilan dan kesetaraan kesempatan bagi semua.';
        }
      }

      String getInclusionNote(String cat) {
        switch (cat) {
          case 'Rendah':
            return 'Perlu lebih aktif mengajak dan melibatkan teman tanpa membeda-bedakan.';
          case 'Sedang':
            return 'Cukup inklusif dan terbuka terhadap teman dengan latar belakang berbeda.';
          case 'Tinggi':
          default:
            return 'Sangat inklusif, ramah, dan aktif merangkul semua orang dalam kelompok.';
        }
      }

      final respectPct = (respectMean * 20.0).clamp(0.0, 100.0);
      final equityPct = (equityMean * 20.0).clamp(0.0, 100.0);
      final inclusionPct = (inclusionMean * 20.0).clamp(0.0, 100.0);
      final overallPct = (overallMean * 20.0).clamp(0.0, 100.0);
      final randomId = Random().nextInt(0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0');
      final generatedUniqueCode = 'REI13-${respectPct.toStringAsFixed(1)}-${equityPct.toStringAsFixed(1)}-${inclusionPct.toStringAsFixed(1)}-${overallPct.toStringAsFixed(1)}-$randomId';

      final payload = {
        'user_id': _currentUser!.id,
        'respect': respectScore,
        'equity': equityScore,
        'inclusion': inclusionScore,
        'respect_category': respectCat,
        'equity_category': equityCat,
        'inclussion_category': inclusionCat,
        'all_category': overallCat,
        'respect_note': getRespectNote(respectCat),
        'equity_note': getEquityNote(equityCat),
        'inclusion_note': getInclusionNote(inclusionCat),
        'all_note':
            'Hasil Evaluasi REI 2026: Kategori $overallCat (Rerata: ${overallMean.toStringAsFixed(2)})',
        'created_at': DateTime.now().toIso8601String(),
      };

      print('UserProvider: Saving calculated REI result to Supabase: $payload');

      try {
        final response =
            await _supabase.from('rei_accumulate').upsert(payload).select().single();
        _reiResult = ReiAccumulateModel.fromJson(response).copyWith(uniqueCode: generatedUniqueCode);
      } catch (dbErr) {
        print('UserProvider: Supabase upsert error (using local model fallback): $dbErr');
        _reiResult = ReiAccumulateModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _currentUser!.id,
          respect: respectScore,
          equity: equityScore,
          inclusion: inclusionScore,
          respectCategory: respectCat,
          equityCategory: equityCat,
          inclusionCategory: inclusionCat,
          allCategory: overallCat,
          respectNote: getRespectNote(respectCat),
          equityNote: getEquityNote(equityCat),
          inclusionNote: getInclusionNote(inclusionCat),
          allNote: 'Hasil Evaluasi REI 2026: Kategori $overallCat (Rerata: ${overallMean.toStringAsFixed(2)})',
          uniqueCode: generatedUniqueCode,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      _setLoading(false);
      notifyListeners();
      return _reiResult;
    } catch (e) {
      print('UserProvider: Error calculating/saving REI result: $e');
      _setError('Gagal menyimpan hasil REI: $e');
      _setLoading(false);
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
    _selectedAgeCategory = null;
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
