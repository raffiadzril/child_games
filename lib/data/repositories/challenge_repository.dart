import '../services/supabase_service.dart';
import '../models/challenge_model.dart';

/// Repository untuk mengelola data challenges
class ChallengeRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get all challenges dari table 'challenges'
  Future<List<ChallengeModel>> getAllChallenges() async {
    try {
      final response = await _supabaseService.select('challenges');
      return response.map((json) => ChallengeModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get challenge by ID
  Future<ChallengeModel?> getChallengeById(String challengeId) async {
    try {
      // Menggunakan client langsung untuk filtering
      final response =
          await _supabaseService.client
              .from('challenges')
              .select()
              .eq('id', challengeId)
              .single();

      return ChallengeModel.fromJson(response);
    } catch (e) {
      print('Error fetching challenge by ID: $e');
      return null;
    }
  }

  /// Insert new challenge
  Future<ChallengeModel?> createChallenge(ChallengeModel challenge) async {
    try {
      final response = await _supabaseService.insert(
        'challenges',
        challenge.toJson(),
      );
      return ChallengeModel.fromJson(response);
    } catch (e) {
      print('Error creating challenge: $e');
      return null;
    }
  }

  /// Update challenge
  Future<ChallengeModel?> updateChallenge(
    String id,
    ChallengeModel challenge,
  ) async {
    try {
      final response = await _supabaseService.update(
        'challenges',
        id,
        challenge.toJson(),
      );
      return ChallengeModel.fromJson(response);
    } catch (e) {
      print('Error updating challenge: $e');
      return null;
    }
  }

  /// Delete challenge
  Future<bool> deleteChallenge(String id) async {
    try {
      await _supabaseService.client.from('challenges').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting challenge: $e');
      return false;
    }
  }
}
