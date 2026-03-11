import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/widgets/loading_overlay.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';
import 'package:pulse_ledger/widgets/pulse_text_field.dart';

class OtpVerificationView extends ConsumerStatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  ConsumerState<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).verifySmsCode(
            verificationId: widget.verificationId,
            smsCode: code,
          );

      // Check if user has a profile in Firestore
      final user = ref.read(authControllerProvider).value;
      if (user != null) {
        final profile =
            await ref.read(firestoreServiceProvider).fetchUser(user.uid);
        if (!mounted) return;
        if (profile != null) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        message: 'Verifying OTP…',
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your identity',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to ${widget.phoneNumber}',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              PulseTextField(
                controller: _otpController,
                label: '6-digit Code',
                hint: '000000',
                maxLength: 6,
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              PulseButton(
                label: 'Verify & Continue',
                onPressed: _verifyCode,
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Change Number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
