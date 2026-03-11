import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/widgets/loading_overlay.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';
import 'package:pulse_ledger/widgets/pulse_text_field.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final phoneInput = _phoneController.text.trim();
    if (phoneInput.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      return;
    }

    final fullPhone = '+91$phoneInput';

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).sendOtp(
            phoneNumber: fullPhone,
            onCodeSent: (verificationId, _) {
              if (!mounted) return;
              Navigator.pushNamed(
                context,
                AppRoutes.otpVerify,
                arguments: {
                  'verificationId': verificationId,
                  'phoneNumber': fullPhone,
                },
              );
              setState(() => _isLoading = false);
            },
            onError: (error) {
              if (!mounted) return;
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
          );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LoadingWrapper(
        isLoading: _isLoading,
        message: 'Sending code…',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // 1. Branding Section
                Text(
                  'Pulse',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppTheme.royalPurple,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  'The smart ledger for your business.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 64),

                // 2. Input Section
                Text(
                  'Log in or sign up',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                PulseTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hint: '98765 43210',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  autofocus: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 8.0, top: 2.0),
                    child: Text(
                      '+91 ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalPurple,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 3. Action Section
                PulseButton(
                  label: 'Continue',
                  onPressed: _handleContinue,
                ),
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
