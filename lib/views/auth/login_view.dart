import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/views/auth/register_view.dart';

import '../../controllers/auth_controller.dart';
import '../../providers/toast_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthController();

  bool loading = false;

  void handleLogin() async {
    setState(() => loading = true);

    try {
      await _auth.login(_username.text.trim(), _password.text.trim());

      ref.read(toastProvider.notifier).showSuccess("Login Successful");

      // TODO → Navigate to Customer List
    } catch (e) {
      ref
          .read(toastProvider.notifier)
          .showError("Invalid Username or Password");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopkeeper Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              onPressed: loading ? null : handleLogin,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterView()),
                );
              },
              child: const Text("New User? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
