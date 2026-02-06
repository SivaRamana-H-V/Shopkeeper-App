import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopkeeper_app/core/auth_session.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
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
          .from(AppStrings.shopkeepersTable)
          .select()
          .eq(AppStrings.userNameField, username)
          .maybeSingle();

      if (res != null) {
        // Task C: Compare password in Dart
        final dbPassword = res[AppStrings.passwordField] as String;
        if (dbPassword == password) {
          AuthSession.shopkeeperId = res[AppStrings.idField] as String;
          AuthSession.shopName = res[AppStrings.shopNameField] as String;

          // Task B: Save Session
          var box = Hive.box(AppStrings.sessionBox);
          box.put(AppStrings.shopkeeperId, AuthSession.shopkeeperId);
          box.put(AppStrings.shopName, AuthSession.shopName);

          state = false;
          return AppStrings.success;
        } else {
          // Wrong password
          state = false;
          return AppStrings.error;
        }
      } else {
        // User not found
        state = false;
        return AppStrings.userNotFound;
      }
    } catch (e) {
      state = false;
      return e.toString();
    }
  }

  // Task E: Logout
  Future<void> logout() async {
    var box = Hive.box(AppStrings.sessionBox);
    await box.clear();
    AuthSession.shopkeeperId = null;
    AuthSession.shopName = null;
    state = false;
  }

  // Task B: Register Logic
  Future<String?> register(
    String shopName,
    String username,
    String password,
  ) async {
    state = true;
    try {
      // 1. Check if username exists
      final checkRes = await SupabaseService.client
          .from(AppStrings.shopkeepersTable)
          .select('id')
          .eq(AppStrings.userNameField, username)
          .maybeSingle();
      if (checkRes != null) {
        state = false;
        return AppStrings.usernameExists;
      }

      // 2. Insert
      await SupabaseService.client.from(AppStrings.shopkeepersTable).insert({
        AppStrings.shopNameField: shopName,
        AppStrings.userNameField: username,
        AppStrings.passwordField: password,
      });

      state = false;
      return null; // Success
    } catch (e) {
      state = false;
      return e.toString();
    }
  }
}
