import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/add_customer_controller.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';

class AddCustomerView extends ConsumerWidget {
  const AddCustomerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseNetwork = ref.watch(pulseNetworkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
      ),
      body: Stack(
        children: [
          pulseNetwork.when(
            data: (users) {
              if (users.isEmpty) {
                return _EmptyNetworkState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _MatchedUserCard(user: user);
                },
              );
            },
            loading: () => const SizedBox.shrink(), // Handled by overlay
            error: (err, _) {
              debugPrint(err.toString());
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text('Could not sync contacts.'),
                    TextButton(
                      onPressed: () => ref.invalidate(pulseNetworkProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
          if (pulseNetwork.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                        color: AppTheme.royalPurple),
                    const SizedBox(height: 24),
                    Text(
                      'Pulse Registry Syncing...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.royalPurple,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Matching digits with Pulse Network',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchedUserCard extends ConsumerWidget {
  const _MatchedUserCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(addCustomerControllerProvider);
    final authLoading = ref.watch(authControllerProvider).isLoading;
    final isLoading = controllerState.isLoading || authLoading;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.royalPurple.withValues(alpha: 0.2),
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: AppTheme.royalPurple),
          ),
        ),
        title: Row(
          children: [
            Text(user.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle,
                size: 16, color: AppTheme.royalPurple),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.phone ?? 'No phone number'),
            Text(
              user.email,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
        trailing: SizedBox(
            width: 140,
            child: PulseButton(
              label: 'Add',
              isLoading: isLoading,
              backgroundColor: AppTheme.royalPurple,
              onPressed: isLoading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final chatId = await ref
                          .read(addCustomerControllerProvider.notifier)
                          .addToLedger(user);

                      if (chatId != null && context.mounted) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/chat',
                          arguments: {
                            'chatId': chatId,
                            'participantName': user.displayName,
                          },
                        );
                      } else if (context.mounted) {
                        final error =
                            ref.read(addCustomerControllerProvider).error;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Handshake failed: ${error ?? "Unknown error"}'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
            )),
      ),
    );
  }
}

class _EmptyNetworkState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.amberGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: AppTheme.amberGold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'None of your contacts are on Pulse yet.\nTime to invite them!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Invite your customers to Pulse to start tracking their balances securely.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Future: Share invite link
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.amberGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text('Invite Friends',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
