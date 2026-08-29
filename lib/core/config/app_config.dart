/// Global Application Configuration
/// Digunakan untuk mengaktifkan/nonaktifkan fitur Developer Mode, Background Music, & Sound Effects.
class AppConfig {
  /// Set isDeveloperMode ke true saat proses development/testing (untuk memunculkan tombol DEV: Auto-Fill).
  /// Set ke false saat rilis aplikasi (untuk menyembunyikan seluruh fitur developer).
  static const bool isDeveloperMode = false;

  /// Set isMusicEnabled ke false untuk mematikan seluruh Musik Latar (Background Music) tanpa ada suara yang bocor.
  /// Set ke true untuk mengaktifkan musik latar.
  static const bool isMusicEnabled = false;

  /// Set isSoundEnabled ke false untuk mematikan seluruh Efek Suara (Sound Effects).
  /// Set ke true untuk mengaktifkan efek suara interaksi.
  static const bool isSoundEnabled = false;
}

