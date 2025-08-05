import 'package:just_audio/just_audio.dart';

/// Service untuk mengelola sound effects dan background music
class SoundService {
  static SoundService? _instance;

  // Private constructor
  SoundService._internal();

  // Singleton factory with cleanup on hot restart
  factory SoundService() {
    if (_instance == null) {
      print('Creating new SoundService instance');
      _instance = SoundService._internal();
    }
    return _instance!;
  }

  static SoundService get instance {
    if (_instance == null) {
      print('Creating new SoundService instance via getter');
      _instance = SoundService._internal();
    }
    return _instance!;
  }

  // Force dispose all instances for hot restart
  static Future<void> disposeAll() async {
    if (_instance != null) {
      print('Disposing existing SoundService instance');
      await _instance!._disposeInternal();
      _instance = null;
    }
  }

  AudioPlayer? _sfxPlayer; // For sound effects
  AudioPlayer? _musicPlayer; // For background music
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isInitialized = false;

  // Sound effect URLs
  static const String _clickSoundUrl =
      'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/sign/sound-music-vocal/soundeffect/click-app.mp3?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV81YmE3YTAzZi1hZWNiLTQ2ZWYtOGFlYS0xYWIwNzUwZTcxMmYiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJzb3VuZC1tdXNpYy12b2NhbC9zb3VuZGVmZmVjdC9jbGljay1hcHAubXAzIiwiaWF0IjoxNzUzNDc3NjI4LCJleHAiOjE3ODUwMTM2Mjh9.QaogsHtFEnWumgVYGhGYYhlrUZasw-UtGxOU2jEx7OU';

  // Background music URL
  static const String _backgroundMusicUrl =
      'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/sound-music-vocal/music/funny-cartoon-kids-background-music-350273.mp3';

  /// Initialize audio players
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _sfxPlayer = AudioPlayer();
      _musicPlayer = AudioPlayer();
      _isInitialized = true;
      print('SoundService initialized successfully');
    } catch (e) {
      print('Failed to initialize SoundService: $e');
      _isInitialized = false;
    }
  }

  /// Enable atau disable sound effects
  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  /// Enable atau disable background music
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  /// Check apakah sound diaktifkan
  bool get isSoundEnabled => _isSoundEnabled;

  /// Check apakah music diaktifkan
  bool get isMusicEnabled => _isMusicEnabled;

  /// Check apakah musik sedang playing
  bool get isMusicPlaying {
    try {
      if (!_isInitialized || _musicPlayer == null) return false;
      return _musicPlayer!.playing;
    } catch (e) {
      print('Error checking music playing state: $e');
      return false;
    }
  }

  /// Start background music with looping
  Future<void> startBackgroundMusic() async {
    if (!_isMusicEnabled || !_isInitialized || _musicPlayer == null) {
      print(
        'Music not enabled or not initialized. Enabled: $_isMusicEnabled, Initialized: $_isInitialized',
      );
      return;
    }

    try {
      // Always stop and dispose current player to prevent overlapping
      if (_musicPlayer != null) {
        await _musicPlayer!.stop();
        await _musicPlayer!.dispose();
        print('Disposed old music player to prevent overlap');
      }

      // Create fresh music player
      _musicPlayer = AudioPlayer();

      // Small delay to ensure clean state
      await Future.delayed(const Duration(milliseconds: 100));

      // Set the URL and configuration
      await _musicPlayer!.setUrl(_backgroundMusicUrl);
      await _musicPlayer!.setLoopMode(LoopMode.one); // Loop forever
      await _musicPlayer!.setVolume(0.5); // Good audible volume

      // Start playing
      await _musicPlayer!.play();
      print(
        'Fresh background music started successfully. Playing: ${_musicPlayer!.playing}',
      );
    } catch (e) {
      print('Failed to start background music: $e');
      // Simple retry with fresh player
      try {
        print('Attempting retry with fresh player...');
        _musicPlayer?.dispose();
        _musicPlayer = AudioPlayer();
        await Future.delayed(const Duration(milliseconds: 200));
        await _musicPlayer!.setUrl(_backgroundMusicUrl);
        await _musicPlayer!.setLoopMode(LoopMode.one);
        await _musicPlayer!.setVolume(0.5);
        await _musicPlayer!.play();
        print(
          'Background music started on retry. Playing: ${_musicPlayer!.playing}',
        );
      } catch (e2) {
        print('Failed to start background music on retry: $e2');
      }
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    if (!_isInitialized || _musicPlayer == null) return;

    try {
      await _musicPlayer!.stop();
      print('Background music stopped');
    } catch (e) {
      print('Failed to stop background music: $e');
    }
  }

  /// Force stop all audio for hot reload
  Future<void> forceStopAll() async {
    try {
      // Simply stop current music without disposing
      if (_musicPlayer != null && _musicPlayer!.playing) {
        await _musicPlayer!.stop();
        print('Force stopped music player');
      }

      // Stop SFX if playing
      if (_sfxPlayer != null && _sfxPlayer!.playing) {
        await _sfxPlayer!.stop();
        print('Force stopped SFX player');
      }
    } catch (e) {
      print('Error in force stop: $e');
    }
  }

  /// Simple stop for hot reload - just stop playing
  Future<void> simpleStop() async {
    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.stop();
        print('Simple stop: Music stopped');
      }
    } catch (e) {
      print('Error in simple stop: $e');
    }
  }

  /// Global cleanup for hot restart - call this from main app
  static Future<void> globalCleanup() async {
    try {
      print('Performing global SoundService cleanup...');
      if (_instance != null) {
        // Force stop all audio first
        try {
          if (_instance!._musicPlayer != null) {
            await _instance!._musicPlayer!.stop();
            await _instance!._musicPlayer!.dispose();
            print('Disposed old music player');
          }
          if (_instance!._sfxPlayer != null) {
            await _instance!._sfxPlayer!.stop();
            await _instance!._sfxPlayer!.dispose();
            print('Disposed old SFX player');
          }
        } catch (e) {
          print('Error disposing old players: $e');
        }

        // Null out the instance completely
        _instance = null;
        print('Global cleanup completed - instance nullified');
      }
    } catch (e) {
      print('Error in global cleanup: $e');
      // Force null the instance even if cleanup fails
      _instance = null;
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (!_isInitialized || _musicPlayer == null) return;

    try {
      if (_musicPlayer!.playing) {
        await _musicPlayer!.pause();
        print('Background music paused');
      }
    } catch (e) {
      print('Failed to pause background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled || !_isInitialized || _musicPlayer == null) return;

    try {
      // Check if music player has a source loaded
      if (_musicPlayer!.audioSource != null) {
        await _musicPlayer!.play();
        print('Background music resumed');
      } else {
        // If no source, start fresh
        await startBackgroundMusic();
      }
    } catch (e) {
      print('Failed to resume background music: $e');
      // Try to start fresh if resume fails
      try {
        await startBackgroundMusic();
      } catch (e2) {
        print('Failed to start background music after resume failure: $e2');
      }
    }
  }

  /// Play sound effect untuk click option
  Future<void> playClickSound() async {
    if (!_isSoundEnabled || !_isInitialized || _sfxPlayer == null) return;

    try {
      // Stop any currently playing sound effect
      await _sfxPlayer!.stop();

      // Set the audio source and play
      await _sfxPlayer!.setUrl(_clickSoundUrl);
      await _sfxPlayer!.play();
    } catch (e) {
      // Jika gagal play sound, tidak crash aplikasi
      print('Failed to play click sound: $e');
    }
  }

  /// Play sound dengan URL custom
  Future<void> playCustomSound(String url) async {
    if (!_isSoundEnabled || !_isInitialized || _sfxPlayer == null) return;

    try {
      await _sfxPlayer!.stop();
      await _sfxPlayer!.setUrl(url);
      await _sfxPlayer!.play();
    } catch (e) {
      print('Failed to play custom sound: $e');
    }
  }

  /// Stop current sound effect
  Future<void> stopSound() async {
    if (!_isInitialized || _sfxPlayer == null) return;

    try {
      await _sfxPlayer!.stop();
    } catch (e) {
      print('Failed to stop sound: $e');
    }
  }

  /// Set volume for sound effects (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized || _sfxPlayer == null) return;

    try {
      await _sfxPlayer!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Failed to set volume: $e');
    }
  }

  /// Set volume for background music (0.0 - 1.0)
  Future<void> setMusicVolume(double volume) async {
    if (!_isInitialized || _musicPlayer == null) return;

    try {
      await _musicPlayer!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Failed to set music volume: $e');
    }
  }

  /// Fade volume from current to target volume with smooth transition
  Future<void> fadeMusicVolume({
    required double targetVolume,
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    if (!_isInitialized || _musicPlayer == null) return;

    try {
      final currentVolume = _musicPlayer!.volume;
      final steps = 20; // Number of fade steps
      final stepDuration = Duration(
        milliseconds: duration.inMilliseconds ~/ steps,
      );
      final volumeStep = (targetVolume - currentVolume) / steps;

      print('Fading music volume from $currentVolume to $targetVolume');

      for (int i = 0; i < steps; i++) {
        final newVolume = currentVolume + (volumeStep * (i + 1));
        await _musicPlayer!.setVolume(newVolume.clamp(0.0, 1.0));
        await Future.delayed(stepDuration);
      }

      // Ensure we reach the exact target volume
      await _musicPlayer!.setVolume(targetVolume.clamp(0.0, 1.0));
      print('Music volume faded to $targetVolume');
    } catch (e) {
      print('Failed to fade music volume: $e');
    }
  }

  /// Lower volume for quiz/question sessions
  Future<void> lowerVolumeForQuiz() async {
    await fadeMusicVolume(targetVolume: 0.25);
  }

  /// Restore normal volume after quiz
  Future<void> restoreNormalVolume() async {
    await fadeMusicVolume(targetVolume: 0.5);
  }

  /// Dispose audio players
  void dispose() {
    _disposeInternal();
  }

  /// Internal dispose method
  Future<void> _disposeInternal() async {
    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.stop();
        await _musicPlayer!.dispose();
        _musicPlayer = null;
        print('Music player disposed');
      }

      if (_sfxPlayer != null) {
        await _sfxPlayer!.stop();
        await _sfxPlayer!.dispose();
        _sfxPlayer = null;
        print('SFX player disposed');
      }

      _isInitialized = false;
      print('SoundService disposed completely');
    } catch (e) {
      print('Error disposing SoundService: $e');
    }
  }

  /// Reset service for hot restart
  Future<void> reset() async {
    print('SoundService: Resetting for hot restart');

    // Stop all audio first
    try {
      await stopBackgroundMusic();
    } catch (e) {
      print('Error stopping music during reset: $e');
    }

    // Dispose current players
    dispose();

    // Reinitialize
    await initialize();
    print('SoundService: Reset complete');
  }
}
