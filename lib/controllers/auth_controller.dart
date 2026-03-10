import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/services/auth_service.dart';
import 'package:pulse_ledger/services/firestore_service.dart';

// ── Service providers ──────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// ── Auth state stream ──────────────────────────────────────────────────────

/// Streams the raw Firebase [User?] — null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── AuthController ─────────────────────────────────────────────────────────

/// Async state: null = signed out, User = signed in.
class AuthController extends AsyncNotifier<User?> {
  late AuthService _authService;

  @override
  Future<User?> build() async {
    _authService = ref.watch(authServiceProvider);
    // Return the current user synchronously; stream handled by authStateProvider.
    return _authService.currentUser;
  }

  /// Triggers Google Sign-In flow.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.signInWithGoogle);
  }

  /// Sends OTP to [phoneNumber].
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  /// Verifies OTP and signs in.
  Future<void> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.verifySmsCode(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await _authService.signOut();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);
