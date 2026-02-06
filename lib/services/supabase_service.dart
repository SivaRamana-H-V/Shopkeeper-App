import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppStrings.supabaseUrl,
      anonKey: AppStrings.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
