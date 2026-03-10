import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/widgets/loading_overlay.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: LoadingWrapper(
        isLoading: authState.isLoading,
        message: 'Signing you in…',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                // Heading
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 48),
                const SizedBox(height: 24),
                Text(
                  'Welcome to Pulse',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'The chat-first ledger for growing businesses.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const Spacer(),

                // Actions
                GoogleSignInButton(
                  onPressed: () => _handleGoogleSignIn(context, ref),
                ),
                const SizedBox(height: 16),
                PulseButton(
                  label: 'Continue with Phone Number',
                  variant: PulseButtonVariant.secondary,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.phoneVerify),
                ),
                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      // On success, SplashView (which usually wraps this logic or is the entry point)
      // or a listener will trigger navigation.
      // For immediate feedback, we can redirect here too.
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.splash);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    }
  }
}
