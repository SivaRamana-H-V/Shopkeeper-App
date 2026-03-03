import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dio interceptor that attaches the Supabase access token
/// to every outgoing request as a Bearer token.
///
/// Always reads the latest token from the Supabase session —
/// never caches the token manually.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _supabaseClient.auth.currentSession;

    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Session expired or invalid — sign out gracefully.
      _supabaseClient.auth.signOut();
    }

    handler.next(err);
  }
}
