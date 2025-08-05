import '../models/question_model.dart';
import '../models/option_model.dart';
import '../services/supabase_service.dart';

/// Repository untuk mengelola questions dan options
class QuestionRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Ambil semua questions berdasarkan challenge_id
  Future<List<QuestionModel>> getQuestionsByChallengeId(
    String challengeId,
  ) async {
    final response = await _supabaseService.select(
      'questions',
      filters: {'challenge_id': challengeId},
    );

    final questions =
        response.map((json) => QuestionModel.fromJson(json)).toList();

    // Sort berdasarkan question_number
    questions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    return questions;
  }

  /// Ambil options berdasarkan question_id
  Future<List<OptionModel>> getOptionsByQuestionId(String questionId) async {
    final response = await _supabaseService.select(
      'options',
      filters: {'question_id': questionId},
    );

    return response.map((json) => OptionModel.fromJson(json)).toList();
  }

  /// Ambil questions dengan options sekaligus - OPTIMIZED VERSION
  Future<List<Map<String, dynamic>>> getQuestionsWithOptions(
    String challengeId,
  ) async {
    // Ambil semua questions untuk challenge ini
    final questions = await getQuestionsByChallengeId(challengeId);

    if (questions.isEmpty) return [];

    // Fallback: Gunakan loop untuk kompatibilitas dengan semua versi Supabase
    List<Map<String, dynamic>> questionsWithOptions = [];
    for (QuestionModel question in questions) {
      final options = await getOptionsByQuestionId(question.id);
      questionsWithOptions.add({'question': question, 'options': options});
    }

    return questionsWithOptions;
  }
}
