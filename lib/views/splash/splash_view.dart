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
  Future<void>? _minDelay;

  @override
  void initState() {
    super.initState();
    // Start minimum delay
    _minDelay = Future.delayed(const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStateCheck(ref.read(currentUserProvider));
    });
  }

  void _handleStateCheck(AsyncValue<UserModel?> profileState) {
    profileState.when(
      data: (userModel) {
        if (userModel != null) {
          _navigateTo(AppRoutes.home);
        } else {
          // No profile yet, check if they are even signed in
          final authUser = ref.read(authStateProvider).value;

          if (authUser == null) {
            _navigateTo(AppRoutes.login);
          } else {
            // Signed in but no Firestore document
            _navigateTo(AppRoutes.roleSelect);
          }
        }
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.amberGold),
      ),
      error: (err, stack) {
        debugPrint('❌ Splash Error: $err');
        debugPrint(stack.toString());

        final authUser = ref.read(authStateProvider).value;
        if (authUser != null) {
          _navigateTo(AppRoutes.roleSelect);
        } else {
          _navigateTo(AppRoutes.login);
        }
      },
    );
  }

  Future<void> _navigateTo(String route) async {
    if (!mounted) return;
    // Wait for minimum display time
    await _minDelay;
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
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.royalPurple, Color(0xFF3700B3)],
          ),
        ),
        child: Stack(
          children: [
            // Splash Logo
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                  "assets/splash_logo.png",
                ),
              ),
            ),
            const Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
