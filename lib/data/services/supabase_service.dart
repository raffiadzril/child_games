import 'package:supabase_flutter/supabase_flutter.dart';

/// Service sederhana untuk mengelola koneksi Supabase
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  /// Client Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// User yang sedang login
  User? get currentUser => client.auth.currentUser;

  /// Cek status login
  bool get isLoggedIn => currentUser != null;

  // Auth Methods

  /// Login dengan email dan password
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Register dengan email dan password
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  /// Logout
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Database Methods

  /// Select data dari table
  Future<List<Map<String, dynamic>>> select(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    var query = client.from(table).select();

    // Add filters if provided
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert data ke table
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  /// Update data di table
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response =
        await client.from(table).update(data).eq('id', id).select().single();
    return response;
  }
}
