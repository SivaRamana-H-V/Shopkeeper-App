import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/chat_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:pulse_ledger/widgets/pulse_button.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    final chatList = ref.watch(chatListProvider);
    final isShopOwner = role == UserRole.shopOwner;
    // final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(isShopOwner ? 'My Shop' : 'My Ledger'),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: chatList.when(
        data: (chats) {
          if (chats.isEmpty) {
            return _EmptyState(isShopOwner: isShopOwner);
          }

          if (isLargeScreen) {
            return _MasterDetailLayout(chats: chats);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatCard(chat: chat);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.amberGold),
        ),
        error: (err, _) {
          return Center(child: Text('Connection Issue: $err'));
        },
      ),
      floatingActionButton: isShopOwner
          ? FloatingActionButton.extended(
              label: const Text('Add'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () {
                // Future: Show search/contact picker
              },
              backgroundColor: AppTheme.amberGold,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from Pulse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          SizedBox(
            width: 120,
            child: PulseButton(
              label: 'Sign Out',
              onPressed: () {
                Navigator.pop(context);
                ref.read(authControllerProvider.notifier).signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.splash,
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isShopOwner});
  final bool isShopOwner;

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
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppTheme.amberGold,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No active ledgers yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              isShopOwner
                  ? 'Start by adding your first customer to track their balances.'
                  : 'Your shop owner hasn\'t added your ledger yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            if (isShopOwner) ...[
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  // Future: Add customer logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.amberGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text(
                  'Add Customer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MasterDetailLayout extends StatelessWidget {
  const _MasterDetailLayout({required this.chats});
  final List<Map<String, dynamic>> chats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) => _ChatCard(chat: chats[index]),
          ),
        ),
        const VerticalDivider(width: 1),
        const Expanded(
          child: Center(
            child: Text('Select a chat to view messages'),
          ),
        ),
      ],
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.chat});

  final Map<String, dynamic> chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppTheme.bubbleReceived,
          child: Icon(Icons.person_rounded, color: Colors.white70),
        ),
        title: Text(
          chat['counterpartyName'] ?? 'Business Chat',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          chat['lastMessage'] ?? 'Start a conversation',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.chat,
            arguments: {
              'chatId': chat['id'],
              'participantName': chat['counterpartyName'] ?? 'Business Chat',
            },
          );
        },
      ),
    );
  }
}
