import 'package:flutter/material.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';

/// Variants available for [PulseButton].
enum PulseButtonVariant { primary, secondary, ghost }

/// Pulse's branded CTA button.
class PulseButton extends StatelessWidget {
  const PulseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PulseButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width = double.infinity,
    this.backgroundColor,
  });

  /// Creates a button with a leading [icon].
  const PulseButton.icon({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.variant = PulseButtonVariant.secondary,
    this.isLoading = false,
    this.width = double.infinity,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final PulseButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double width;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.amberGold,
            ),
          )
        : _buildLabel(theme);

    return SizedBox(
      width: width,
      height: 52,
      child: switch (variant) {
        PulseButtonVariant.primary => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: backgroundColor != null
                ? ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: child,
          ),
        PulseButtonVariant.secondary => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        PulseButtonVariant.ghost => TextButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
      },
    );
  }

  Widget _buildLabel(ThemeData theme) {
    if (icon == null) {
      return Text(label);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
  }
}

/// A specialised Google Sign-In button following brand guidelines.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(color: AppTheme.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google_logo.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}
