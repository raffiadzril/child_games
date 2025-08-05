import 'package:just_audio/just_audio.dart';

/// Service untuk mengelola sound effects
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static SoundService get instance => _instance;

  AudioPlayer? _audioPlayer;
  bool _isSoundEnabled = true;
  bool _isInitialized = false;

  // Sound effect URLs
  static const String _clickSoundUrl =
      'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/sign/sound-music-vocal/soundeffect/click-app.mp3?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV81YmE3YTAzZi1hZWNiLTQ2ZWYtOGFlYS0xYWIwNzUwZTcxMmYiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJzb3VuZC1tdXNpYy12b2NhbC9zb3VuZGVmZmVjdC9jbGljay1hcHAubXAzIiwiaWF0IjoxNzUzNDc3NjI4LCJleHAiOjE3ODUwMTM2Mjh9.QaogsHtFEnWumgVYGhGYYhlrUZasw-UtGxOU2jEx7OU';

  /// Initialize audio player
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();
      _isInitialized = true;
      print('SoundService initialized successfully');
    } catch (e) {
      print('Failed to initialize SoundService: $e');
      _isInitialized = false;
    }
  }

  /// Enable atau disable sound
  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  /// Check apakah sound diaktifkan
  bool get isSoundEnabled => _isSoundEnabled;

  /// Play sound effect untuk click option
  Future<void> playClickSound() async {
    if (!_isSoundEnabled || !_isInitialized || _audioPlayer == null) return;

    try {
      // Stop any currently playing sound
      await _audioPlayer!.stop();

      // Set the audio source and play
      await _audioPlayer!.setUrl(_clickSoundUrl);
      await _audioPlayer!.play();
    } catch (e) {
      // Jika gagal play sound, tidak crash aplikasi
      print('Failed to play click sound: $e');
    }
  }

  /// Play sound dengan URL custom
  Future<void> playCustomSound(String url) async {
    if (!_isSoundEnabled || !_isInitialized || _audioPlayer == null) return;

    try {
      await _audioPlayer!.stop();
      await _audioPlayer!.setUrl(url);
      await _audioPlayer!.play();
    } catch (e) {
      print('Failed to play custom sound: $e');
    }
  }

  /// Stop current sound
  Future<void> stopSound() async {
    if (!_isInitialized || _audioPlayer == null) return;

    try {
      await _audioPlayer!.stop();
    } catch (e) {
      print('Failed to stop sound: $e');
    }
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized || _audioPlayer == null) return;

    try {
      await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Failed to set volume: $e');
    }
  }

  /// Dispose audio player
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isInitialized = false;
  }
}
