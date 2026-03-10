import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:pulse_ledger/widgets/loading_overlay.dart';

class RoleSelectView extends ConsumerStatefulWidget {
  const RoleSelectView({super.key});

  @override
  ConsumerState<RoleSelectView> createState() => _RoleSelectViewState();
}

class _RoleSelectViewState extends ConsumerState<RoleSelectView> {
  bool _isLoading = false;

  Future<void> _selectRole(UserRole role) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Create initial profile model
      final userModel = UserModel.fromAuth(user, role);

      // Upsert into Firestore
      await ref.read(firestoreServiceProvider).createUserProfile(userModel);

      if (mounted) {
        // Clear splash/auth hang by refreshing the provider or navigating
        ref.invalidate(currentUserProvider);
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set role: $e')),
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
        message: 'Setting up your profile…',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'How will you use Pulse?',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select your primary role to customize your experience.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                _RoleCard(
                  title: 'Shop Owner',
                  subtitle: 'I want to manage my ledger and collect payments.',
                  icon: Icons.store_rounded,
                  color: AppTheme.royalPurpleLight,
                  onTap: () => _selectRole(UserRole.shopOwner),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  title: 'Customer',
                  subtitle: 'I want to track my purchases and settle dues.',
                  icon: Icons.person_rounded,
                  color: AppTheme.amberGold,
                  onTap: () => _selectRole(UserRole.customer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
