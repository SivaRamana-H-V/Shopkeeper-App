import 'package:shopkeeper_app/services/supabase_service.dart';
import 'package:shopkeeper_app/core/errors/app_exceptions.dart';

class AuthController {
  Future<void> login(String username, String password) async {
    final res = await SupabaseService.client
        .from('shopkeepers')
        .select()
        .eq('username', username)
        .eq('password', password)
        .maybeSingle();

    if (res == null) {
      throw AuthException();
    }
  }

  Future<void> register(
    String shopName,
    String username,
    String password,
  ) async {
    await SupabaseService.client.from('shopkeepers').insert({
      'shop_name': shopName,
      'username': username,
      'password': password,
    });
  }
}
