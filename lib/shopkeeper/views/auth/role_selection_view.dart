import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopkeeper_app/shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper_app/shopkeeper/core/router/app_routes.dart';
import 'package:shopkeeper_app/shopkeeper/core/theme/app_colors.dart';

class RoleSelectionView extends ConsumerStatefulWidget {
  const RoleSelectionView({super.key});

  @override
  ConsumerState<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends ConsumerState<RoleSelectionView> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    try {
      final box = await Hive.openBox(AppStrings.sessionBox);
      await box.put('role', role);

      if (mounted) {
        if (role == 'shopkeeper') {
          context.go(AppRoutes.login);
        } else {
          // TODO: Navigate to Customer Home
          context.go(AppRoutes.customerHome);
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to ${AppStrings.appName}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Text(
                'Select your role',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                _RoleCard(
                  title: 'Shopkeeper',
                  icon: Icons.store,
                  onTap: () => _selectRole('shopkeeper'),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  title: 'Customer',
                  icon: Icons.person,
                  onTap: () => _selectRole('customer'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
