import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/models/user_model.dart';

/// Streams the full [UserModel] of the currently authenticated user.
/// Returns null if the user is signed out or the document doesn't exist.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.read(firestoreServiceProvider).streamUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Global provider exposing the current user's [UserRole].
/// Defaults to [UserRole.customer] when no data is available.
final roleProvider = Provider<UserRole>((ref) {
  return ref
      .watch(currentUserProvider)
      .when(
        data: (user) => user?.role ?? UserRole.customer,
        loading: () => UserRole.customer,
        error: (_, __) => UserRole.customer,
      );
});

/// True when the current user is a Shop Owner.
final isShopOwnerProvider = Provider<bool>((ref) {
  return ref.watch(roleProvider) == UserRole.shopOwner;
});
