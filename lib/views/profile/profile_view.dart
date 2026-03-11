import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/profile_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';
import 'package:pulse_ledger/widgets/pulse_text_field.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _businessController;
  late TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    // Initialize with current values
    final user = ref.read(currentUserProvider).value;
    _nameController = TextEditingController(text: user?.displayName);
    _businessController = TextEditingController(text: user?.businessName);
    _upiController = TextEditingController(text: user?.upiId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final role = ref.watch(roleProvider);
    final isShopOwner = role == UserRole.shopOwner;
    final profileState = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);

    // Initial check for loading or success
    ref.listen(profileControllerProvider, (previous, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(profileControllerProvider.notifier).resetStatus();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(profileControllerProvider.notifier).resetStatus();
      }
    });

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (user) {
        final initials = user?.displayName.isNotEmpty == true
            ? user!.displayName
                .trim()
                .split(' ')
                .where((e) => e.isNotEmpty)
                .map((e) => e[0])
                .take(2)
                .join()
                .toUpperCase()
            : '?';

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header Section ───────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            AppTheme.royalPurple.withValues(alpha: 0.1),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user?.displayName ?? 'No Name',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.amberGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.amberGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          role.label,
                          style: const TextStyle(
                            color: AppTheme.amberGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Edit Form ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERSONAL INFORMATION',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.royalPurple,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PulseTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your name',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      if (isShopOwner) ...[
                        const SizedBox(height: 24),
                        Text(
                          'BUSINESS DETAILS',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.royalPurple,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PulseTextField(
                          controller: _businessController,
                          label: 'Business Name',
                          hint: 'e.g., Pulse General Store',
                          prefixIcon: const Icon(Icons.store_outlined),
                        ),
                        const SizedBox(height: 24),
                        PulseTextField(
                          controller: _upiController,
                          label: 'UPI ID',
                          hint: 'username@bank',
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                      ],
                      const SizedBox(height: 48),

                      // ── Actions ───────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: PulseButton(
                          label: profileState.isLoading
                              ? 'Saving Changes...'
                              : 'Save Changes',
                          onPressed: profileState.isLoading
                              ? null
                              : () {
                                  ref
                                      .read(profileControllerProvider.notifier)
                                      .updateProfile(
                                        name: _nameController.text.trim(),
                                        businessName: isShopOwner
                                            ? _businessController.text.trim()
                                            : null,
                                        upiId: isShopOwner
                                            ? _upiController.text.trim()
                                            : null,
                                      );
                                },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _handleLogout(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
