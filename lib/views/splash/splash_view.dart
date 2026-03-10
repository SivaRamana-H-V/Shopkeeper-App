import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStateCheck(ref.read(currentUserProvider));
    });
  }

  void _handleStateCheck(AsyncValue<UserModel?> profileState) {
    profileState.when(
      data: (userModel) {
        if (userModel != null) {
          debugPrint('💡 User profile found. Navigating to Home.');
          _navigateTo(AppRoutes.home);
        } else {
          // No profile yet, check if they are even signed in
          final authUser = ref.read(authStateProvider).value;
          debugPrint('💡 No profile found. Auth user: ${authUser?.uid}');

          if (authUser == null) {
            _navigateTo(AppRoutes.login);
          } else {
            // Signed in but no Firestore document
            _navigateTo(AppRoutes.roleSelect);
          }
        }
      },
      loading: () => debugPrint('⏳ Splash: Loading user state...'),
      error: (err, stack) {
        debugPrint('❌ Splash Error: $err');
        debugPrint(stack.toString());

        // If we have an auth user but Firestore fails (likely permissions),
        // try to go to RoleSelect as a fallback to see if we can create the profile.
        final authUser = ref.read(authStateProvider).value;
        if (authUser != null) {
          _navigateTo(AppRoutes.roleSelect);
        } else {
          _navigateTo(AppRoutes.login);
        }
      },
    );
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to profile/auth state changes
    ref.listen<AsyncValue<UserModel?>>(
      currentUserProvider,
      (previous, next) => _handleStateCheck(next),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.royalPurple, Color(0xFF3700B3)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash Logo
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                "assets/splash_logo.png",
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
            ),
          ],
        ),
      ),
    );
  }
}
