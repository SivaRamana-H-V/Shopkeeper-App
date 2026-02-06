import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper_app/controllers/auth_controller.dart';
import 'package:shopkeeper_app/providers/toast_provider.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/core/router/app_routes.dart';
import 'package:shopkeeper_app/core/ui/gradient_button.dart';
import 'package:shopkeeper_app/core/ui/custom_text_field.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ref.read(toastProvider.notifier).showInfo(AppStrings.validationError);
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authControllerProvider.notifier)
        .login(username, password);

    if (result == 'success') {
      ref
          .read(toastProvider.notifier)
          .showSuccess(AppStrings.toastLoginSuccess);
      if (mounted) {
        context.go(AppRoutes.customers);
      } else if (result == 'wrong_password') {
        ref
            .read(toastProvider.notifier)
            .showError(AppStrings.toastWrongPassword);
      } else if (result == 'user_not_found') {
        ref
            .read(toastProvider.notifier)
            .showError(AppStrings.toastUserNotFound);
      }
    } else {
      ref.read(toastProvider.notifier).showError(result ?? 'Login Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(authControllerProvider, (previous, next) {
      // Could handle side effects here if preferred, but doing it in _handleLogin is simpler for now
    });

    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Image.asset(
                'assets/logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.store, size: 80, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Form
              CustomTextField(
                controller: _usernameController,
                hintText: AppStrings.usernameHint,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: AppStrings.passwordHint,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // Login Button
              GradientButton(
                label: AppStrings.loginButton,
                isLoading: isLoading,
                onPressed: () {
                  _handleLogin();
                },
              ),
              const SizedBox(height: 16),

              // Register Link
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.register);
                },
                child: const Text(
                  AppStrings.registerLink,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
