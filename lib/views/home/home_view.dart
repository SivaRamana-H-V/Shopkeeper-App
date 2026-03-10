import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/chat_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';

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
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: isShopOwner
          ? FloatingActionButton.extended(
              onPressed: () {
                // Future: Show search/contact picker
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Customer'),
            )
          : null,
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
        leading: CircleAvatar(
          backgroundColor: AppTheme.bubbleReceived,
          child: const Icon(Icons.person_rounded, color: Colors.white70),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isShopOwner});
  final bool isShopOwner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            isShopOwner ? 'No customers yet' : 'No transactions yet',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 8),
          Text(
            isShopOwner
                ? 'Tap the button to add your first customer.'
                : 'Your shop owner will add you here.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white24),
          ),
        ],
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
