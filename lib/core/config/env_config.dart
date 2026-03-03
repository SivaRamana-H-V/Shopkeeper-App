import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
/// Reads values from the `.env` file loaded via flutter_dotenv.
abstract final class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
