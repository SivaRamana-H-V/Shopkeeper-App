import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/role_select_controller.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roleSelectControllerProvider);

    return Scaffold(
      body: LoadingWrapper(
        isLoading: state.isLoading,
        message: 'Personalizing your account...',
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: state.isProfileFormVisible
                ? _ProfileFormStep(
                    key: const ValueKey('profile_form'),
                    nameController: _nameController,
                    emailController: _emailController,
                    errorMessage: state.errorMessage,
                    onBack: () => ref
                        .read(roleSelectControllerProvider.notifier)
                        .goBackToRoleSelection(),
                    onComplete: () async {
                      final success = await ref
                          .read(roleSelectControllerProvider.notifier)
                          .completeProfile(
                            name: _nameController.text,
                            email: _emailController.text,
                          );
                      if (success && mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    },
                  )
                : _RoleSelectionStep(
                    key: const ValueKey('role_selection'),
                    onRoleSelected: (role) => ref
                        .read(roleSelectControllerProvider.notifier)
                        .selectRole(role),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionStep extends StatelessWidget {
  const _RoleSelectionStep({
    super.key,
    required this.onRoleSelected,
  });

  final Function(UserRole) onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 48),
          _RoleCard(
            title: 'Shop Owner',
            subtitle: 'I want to manage my ledger and collect payments.',
            icon: Icons.store_rounded,
            color: AppTheme.royalPurpleLight,
            onTap: () => onRoleSelected(UserRole.shopOwner),
          ),
          const SizedBox(height: 16),
          _RoleCard(
            title: 'Customer',
            subtitle: 'I want to track my purchases and settle dues.',
            icon: Icons.person_rounded,
            color: AppTheme.amberGold,
            onTap: () => onRoleSelected(UserRole.customer),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormStep extends StatelessWidget {
  const _ProfileFormStep({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.onBack,
    required this.onComplete,
    this.errorMessage,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final VoidCallback onBack;
  final VoidCallback onComplete;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 32),
          Text(
            'Complete Your Profile',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Tell us a bit more about you to get started.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 40),
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Full Name',
            style: theme.textTheme.titleSmall
                ?.copyWith(color: AppTheme.onSurfaceMuted),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Email Address',
            style: theme.textTheme.titleSmall
                ?.copyWith(color: AppTheme.onSurfaceMuted),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amberGold,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Complete Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
