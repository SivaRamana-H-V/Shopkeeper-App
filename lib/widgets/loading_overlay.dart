import 'package:flutter/material.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';

/// Full-screen loading overlay with a Pulse-branded spinner.
///
/// Stack this on top of a page while async operations are in flight.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message, this.opacity = 0.7});

  final String? message;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: opacity),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsatingRing(),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PulsatingRing extends StatefulWidget {
  @override
  State<_PulsatingRing> createState() => _PulsatingRingState();
}

class _PulsatingRingState extends State<_PulsatingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.royalPurple, width: 3),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.amberGold),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience wrapper: shows [child] with an overlay while [isLoading] is true.
class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) Positioned.fill(child: LoadingOverlay(message: message)),
      ],
    );
  }
}
