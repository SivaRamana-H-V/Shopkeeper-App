import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../providers/toast_provider.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _shopName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  final _auth = AuthController();
  bool loading = false;

  void handleRegister() async {
    setState(() => loading = true);

    try {
      await _auth.register(
        _shopName.text.trim(),
        _username.text.trim(),
        _password.text.trim(),
      );

      ref.read(toastProvider.notifier).showSuccess("Account Created");
      if (mounted) {
        Navigator.pop(context); // back to login
      }
    } catch (e) {
      ref.read(toastProvider.notifier).showError("Registration Failed");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Shop")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _shopName,
              decoration: const InputDecoration(labelText: "Shop Name"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: "Username"),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : handleRegister,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
