import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/toast_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/ui/gradient_button.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _shopNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final shopName = _shopNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (shopName.isEmpty || username.isEmpty || password.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .showInfo(AppStrings.validationError); // Generic validation msg
      return;
    }

    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authControllerProvider.notifier)
        .register(shopName, username, password);

    if (result == null) {
      // Success
      ref
          .read(toastProvider.notifier)
          .showSuccess(AppStrings.toastRegisterSuccess);
      if (mounted) {
        context.go(AppRoutes.login); // Navigate to login as requested
      }
    } else if (result == 'username_exists') {
      ref
          .read(toastProvider.notifier)
          .showError(AppStrings.toastUsernameExists);
    } else {
      ref.read(toastProvider.notifier).showError(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.registerTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Form
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  hintText: AppStrings.shopNameHint,
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: AppStrings.usernameHint,
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: AppStrings.passwordHint,
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const Spacer(),

              // Create Account Button
              GradientButton(
                label: AppStrings.registerButton,
                isLoading: isLoading,
                onPressed: () {
                  _handleRegister();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
