/// Supabase project configuration.
///
/// The anon key is a public client key. Never put a service-role / secret key
/// in the Flutter app.
///
/// `SUPABASE_URL` and `SUPABASE_ANON_KEY` can be overridden at build time:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gskxaynpuycgbitgewwk.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdza3hheW5wdXljZ2JpdGdld3drIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMxNjA5MjMsImV4cCI6MjEwODczNjkyM30.NYzk9wuQwYIxOsj_XB3eriZmMOnb8cz1PSX99O33k8w',
  );

  /// URL for a file in a public storage bucket.
  static String publicObject(String bucket, String path) =>
      '$url/storage/v1/object/public/$bucket/$path';

  /// Base URL for media served from Cloudflare R2 via the custom domain.
  /// Override at build time with --dart-define=MEDIA_BASE_URL=...
  static const String mediaBaseUrl = String.fromEnvironment(
    'MEDIA_BASE_URL',
    defaultValue: 'https://media.scl-vguard.com',
  );

  /// URL for a media object on the R2 CDN, e.g.
  /// `mediaObject('challenges/logo.png')`.
  static String mediaObject(String path) => '$mediaBaseUrl/$path';
}
