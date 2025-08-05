import 'package:flutter_test/flutter_test.dart';
import '../lib/data/models/question_model.dart';

void main() {
  group('QuestionModel Media Detection Tests', () {
    test('should detect video from Supabase URL', () {
      const videoUrl =
          'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/sign/question/2025-06-13%2000-33-48.mp4?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV81YmE3YTAzZi1hZWNiLTQ2ZWYtOGFlYS0xYWIwNzUwZTcxMmYiLCJhbGciOiJIUzI1NiJ9';

      final question = QuestionModel.fromJson({
        'id': 'test-id',
        'challenge_id': 'test-challenge',
        'question_text': 'Test video question',
        'image_url': videoUrl,
        'question_number': 1,
      });

      expect(question.mediaType, MediaType.video);
      expect(question.isVideo, true);
      expect(question.hasMedia, true);
    });

    test('should detect image from Supabase URL', () {
      const imageUrl =
          'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/sign/question/sample-image.jpg?token=abc123';

      final question = QuestionModel.fromJson({
        'id': 'test-id',
        'challenge_id': 'test-challenge',
        'question_text': 'Test image question',
        'image_url': imageUrl,
        'question_number': 1,
      });

      expect(question.mediaType, MediaType.image);
      expect(question.isImage, true);
      expect(question.hasMedia, true);
    });

    test('should handle URL encoded filenames', () {
      const encodedUrl =
          'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/sign/question/My%20Video%20File.mp4?token=abc123';

      final question = QuestionModel.fromJson({
        'id': 'test-id',
        'challenge_id': 'test-challenge',
        'question_text': 'Test encoded URL',
        'image_url': encodedUrl,
        'question_number': 1,
      });

      expect(question.mediaType, MediaType.video);
      expect(question.isVideo, true);
    });

    test('should handle no media', () {
      final question = QuestionModel.fromJson({
        'id': 'test-id',
        'challenge_id': 'test-challenge',
        'question_text': 'Test no media question',
        'image_url': null,
        'question_number': 1,
      });

      expect(question.mediaType, MediaType.none);
      expect(question.hasMedia, false);
    });

    test('should handle direct file URLs', () {
      const directVideoUrl = 'https://example.com/video.webm';

      final question = QuestionModel.fromJson({
        'id': 'test-id',
        'challenge_id': 'test-challenge',
        'question_text': 'Test direct URL',
        'image_url': directVideoUrl,
        'question_number': 1,
      });

      expect(question.mediaType, MediaType.video);
      expect(question.isVideo, true);
    });
  });
}
