import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/widgets/loading_overlay.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';
import 'package:pulse_ledger/widgets/pulse_text_field.dart';

class PhoneVerifyView extends ConsumerStatefulWidget {
  const PhoneVerifyView({super.key, this.prefilledPhone});

  final String? prefilledPhone;

  @override
  ConsumerState<PhoneVerifyView> createState() => _PhoneVerifyViewState();
}

class _PhoneVerifyViewState extends ConsumerState<PhoneVerifyView> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? _verificationId;
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledPhone != null) {
      _phoneController.text = widget.prefilledPhone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // Normalise: Remove spaces, dashes, etc.
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Automatic Prefixing for India (default target)
    // If it's a 10-digit number starting with 6-9, prepend +91
    if (RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      phone = '+91$phone';
    } else if (!phone.startsWith('+')) {
      // If no plus, assume +91 if length is 10
      if (phone.length == 10) {
        phone = '+91$phone';
      } else {
        // Otherwise, error out and ask for full format
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please include country code (e.g., +91...)'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    await ref.read(authControllerProvider.notifier).sendOtp(
          phoneNumber: phone,
          onCodeSent: (id, _) {
            setState(() {
              _verificationId = id;
              _otpSent = true;
              _isLoading = false;
            });
          },
          onError: (err) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        );
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.isEmpty || _verificationId == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).verifySmsCode(
            verificationId: _verificationId!,
            smsCode: code,
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
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
      appBar: AppBar(title: const Text('Phone Verification')),
      body: LoadingWrapper(
        isLoading: _isLoading,
        message: _otpSent ? 'Verifying OTP…' : 'Sending code…',
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _otpSent ? 'Verify your identity' : 'What is your number?',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                _otpSent
                    ? 'We sent a 6-digit code to ${_phoneController.text}'
                    : 'We will send a code to verify your phone number.',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              if (!_otpSent)
                PulseTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+91 98765 43210',
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                )
              else
                PulseTextField(
                  controller: _otpController,
                  label: '6-digit Code',
                  hint: '000000',
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              const SizedBox(height: 24),
              PulseButton(
                label: _otpSent ? 'Verify & Continue' : 'Send Code',
                onPressed: _otpSent ? _verifyCode : _sendCode,
              ),
              if (_otpSent)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _otpSent = false),
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
