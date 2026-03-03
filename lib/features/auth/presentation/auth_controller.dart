import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

/// Represents the authentication state of the application.
sealed class AuthStatus {
  const AuthStatus();
}

class AuthInitial extends AuthStatus {
  const AuthInitial();
}

class AuthAuthenticated extends AuthStatus {
  const AuthAuthenticated(this.user);
  final Map<String, dynamic> user;
}

class AuthUnauthenticated extends AuthStatus {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthStatus {
  const AuthLoading();
}

class AuthError extends AuthStatus {
  const AuthError(this.message);
  final String message;
}

/// [AsyncNotifier] managing authentication state.
///
/// Exposes:
/// - [signInWithGoogle] — triggers Google OAuth flow
/// - [signOut] — signs out and clears session
/// - [checkSession] — checks for an existing session on app start
class AuthController extends AsyncNotifier<AuthStatus> {
  late final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  FutureOr<AuthStatus> build() {
    _repository = ref.read(authRepositoryProvider);
    _listenToAuthChanges();
    return _checkExistingSession();
  }

  /// Listens to Supabase auth state changes (e.g. after OAuth redirect).
  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _repository.onAuthStateChange.listen((authState) async {
      final event = authState.event;
      final session = authState.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _syncWithBackend();
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AsyncData(AuthUnauthenticated());
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        // Token refreshed, no action needed — interceptor reads latest session.
      }
    });

    ref.onDispose(() => _authSubscription?.cancel());
  }

  /// Checks if there's an existing valid session on app launch.
  Future<AuthStatus> _checkExistingSession() async {
    final session = _repository.currentSession;

    if (session == null) {
      return const AuthUnauthenticated();
    }

    try {
      final user = await _repository.fetchCurrentUser();
      return AuthAuthenticated(user);
    } catch (e) {
      // Session might be expired; let Supabase handle refresh.
      return const AuthUnauthenticated();
    }
  }

  /// Public method to check session — called on app start.
  Future<void> checkSession() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _checkExistingSession());
  }

  /// Triggers Google Sign-In via Supabase OAuth.
  /// The actual session is received through `onAuthStateChange` listener.
  Future<void> signInWithGoogle() async {
    state = const AsyncData(AuthLoading());

    try {
      final launched = await _repository.signInWithGoogle();

      if (!launched) {
        state = const AsyncData(AuthError('Failed to launch Google Sign-In'));
      }
      // If launched successfully, the onAuthStateChange listener
      // will handle the rest when the OAuth redirects back.
    } catch (e) {
      state = AsyncData(AuthError(e.toString()));
    }
  }

  /// Syncs the authenticated user with the backend.
  Future<void> _syncWithBackend() async {
    try {
      final user = await _repository.fetchCurrentUser();
      state = AsyncData(AuthAuthenticated(user));
    } catch (e) {
      state = AsyncData(AuthError('Backend sync failed: ${e.toString()}'));
    }
  }

  /// Signs out from Supabase and resets state.
  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await _repository.signOut();
      state = const AsyncData(AuthUnauthenticated());
    } catch (e) {
      state = AsyncData(AuthError('Sign out failed: ${e.toString()}'));
    }
  }
}

/// Provider for [AuthController].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);
