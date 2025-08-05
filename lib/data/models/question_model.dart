/// Enum untuk jenis media pada question
enum MediaType { none, image, video }

/// Model untuk question
class QuestionModel {
  final String id;
  final String challengeId;
  final String questionText;
  final String? mediaUrl;
  final MediaType mediaType;
  final int questionNumber;

  QuestionModel({
    required this.id,
    required this.challengeId,
    required this.questionText,
    this.mediaUrl,
    this.mediaType = MediaType.none,
    this.questionNumber = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Determine media type from file extension
    MediaType mediaType = MediaType.none;
    String? mediaUrl;

    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      mediaUrl = json['image_url'] as String;
      mediaType = _detectMediaType(mediaUrl);
    }

    return QuestionModel(
      id: json['id'] as String,
      challengeId: json['challenge_id'] as String,
      questionText: json['question_text'] as String,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      questionNumber: json['question_number'] as int? ?? 1,
    );
  }

  /// Deteksi jenis media berdasarkan ekstensi file
  static MediaType _detectMediaType(String url) {
    // Untuk URL Supabase, ekstrak path sebelum token
    String cleanUrl = url;

    // Jika ada token parameter, ambil bagian sebelum token
    if (url.contains('?token=')) {
      cleanUrl = url.split('?token=').first;
    }

    // Untuk URL Supabase storage, ekstrak nama file dari path
    // Format: https://xxx.supabase.co/storage/v1/object/sign/bucket/filename.ext
    if (cleanUrl.contains('/storage/v1/object/')) {
      final pathParts = cleanUrl.split('/');
      if (pathParts.isNotEmpty) {
        cleanUrl = pathParts.last;
      }
    }

    // Decode URL encoding (%20 menjadi spasi, dll)
    cleanUrl = Uri.decodeFull(cleanUrl);

    // Ambil ekstensi file
    final extension = cleanUrl.toLowerCase().split('.').last;

    // Video extensions
    const videoExtensions = [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm',
      'm4v',
      'flv',
      '3gp',
      'wmv',
    ];

    // Image extensions
    const imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'svg',
      'bmp',
      'tiff',
      'ico',
    ];

    MediaType detectedType;
    if (videoExtensions.contains(extension)) {
      detectedType = MediaType.video;
    } else if (imageExtensions.contains(extension)) {
      detectedType = MediaType.image;
    } else {
      detectedType = MediaType.none;
    }

    // Debug print untuk development
    print('Media detection:');
    print('  Original URL: $url');
    print('  Clean URL: $cleanUrl');
    print('  Extension: $extension');
    print('  Detected type: $detectedType');

    return detectedType;
  }

  /// Helper methods untuk pengecekan jenis media
  bool get hasMedia => mediaType != MediaType.none;
  bool get isImage => mediaType == MediaType.image;
  bool get isVideo => mediaType == MediaType.video;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'question_text': questionText,
      'image_url': mediaUrl, // Gunakan image_url untuk semua jenis media
      'question_number': questionNumber,
    };
  }
}
