import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shopkeeper_app/core/constants/api_constants.dart';
import 'package:shopkeeper_app/core/network/dio_client.dart';

/// Repository handling authentication operations.
///
/// - Google Sign-In via Supabase
/// - Session management
/// - Backend user sync via `/auth/me`
class AuthRepository {
  AuthRepository(this._supabaseClient, this._dio);

  final SupabaseClient _supabaseClient;
  final Dio _dio;

  /// Signs in with Google using Supabase OAuth.
  /// Opens a browser for Google Sign-In. The session is received
  /// via deep link and handled by `onAuthStateChange`.
  Future<bool> signInWithGoogle() async {
    return _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  /// Retrieves the current Supabase session, if any.
  Session? get currentSession => _supabaseClient.auth.currentSession;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange =>
      _supabaseClient.auth.onAuthStateChange;

  /// Calls the backend `/auth/me` endpoint.
  /// The backend will auto-create the user if they don't exist.
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await _dio.get(ApiConstants.authMe);
    return response.data as Map<String, dynamic>;
  }

  /// Signs out from Supabase.
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}

/// Riverpod provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client, ref.watch(dioClientProvider));
});
