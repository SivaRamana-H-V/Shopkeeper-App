import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';

/// Route path constants.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
}

/// GoRouter provider with auth-based redirect logic.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated =
          authState.whenOrNull(data: (status) => status is AuthAuthenticated) ??
          false;

      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // If authenticated and on login page, redirect to home.
      if (isAuthenticated && isOnLogin) {
        return AppRoutes.home;
      }

      // If not authenticated and NOT on login page, redirect to login.
      if (!isAuthenticated && !isOnLogin) {
        return AppRoutes.login;
      }

      // No redirect needed.
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
