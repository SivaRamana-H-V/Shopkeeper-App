import 'package:flutter_riverpod/legacy.dart';
import 'package:shopkeeper_app/core/auth_session.dart';
import 'package:shopkeeper_app/services/supabase_service.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController();
});

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false); // false = not loading

  Future<String?> login(String username, String password) async {
    state = true; // loading
    try {
      // Task C: Query Supabase by username only
      final res = await SupabaseService.client
          .from('shopkeepers')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (res != null) {
        // Task C: Compare password in Dart
        final dbPassword = res['password'] as String;
        if (dbPassword == password) {
          AuthSession.shopkeeperId = res['id'] as String;
          AuthSession.shopName = res['shop_name'] as String;
          state = false;
          return 'success';
        } else {
          // Wrong password
          state = false;
          return 'wrong_password';
        }
      } else {
        // User not found
        state = false;
        return 'user_not_found';
      }
    } catch (e) {
      state = false;
      return e
          .toString(); // Error logic handled by View showing generic or specific toast
    }
  }

  // Task B: Register Logic
  // Returns generic string if error, null if success.
  Future<String?> register(
    String shopName,
    String username,
    String password,
  ) async {
    state = true;
    try {
      // 1. Check if username exists
      final checkRes = await SupabaseService.client
          .from('shopkeepers')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      if (checkRes != null) {
        state = false;
        // Task B: If exists -> show toastUsernameExists (done by view checking this result)
        // Returning specific error code for View to handle
        return 'username_exists';
      }

      // 2. Insert
      await SupabaseService.client.from('shopkeepers').insert({
        'shop_name': shopName,
        'username': username,
        'password': password,
      });

      state = false;
      return null; // Success
    } catch (e) {
      state = false;
      return e.toString();
    }
  }
}
