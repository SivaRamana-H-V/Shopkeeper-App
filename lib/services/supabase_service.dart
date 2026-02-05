import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://mpwtobxkftamchjjoong.supabase.co',
      anonKey: 'sb_publishable_Ct4xLzSpXrkQjdNlwEGTcA_1DgRV7on',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
