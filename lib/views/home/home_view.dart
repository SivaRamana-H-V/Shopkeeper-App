import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/chat_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: 'Profile',
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
                Navigator.pushNamed(context, AppRoutes.addCustomer);
              },
              backgroundColor: AppTheme.amberGold,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_rounded),
            )
          : null,
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
                  Navigator.pushNamed(context, AppRoutes.addCustomer);
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

class _ChatCard extends ConsumerWidget {
  const _ChatCard({required this.chat});

  final Map<String, dynamic> chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authStateProvider).value;

    // Resolve Identity
    final isShopOwner = chat['shopId'] == currentUser?.uid;
    final displayName = isShopOwner
        ? (chat['customerName'] ?? 'Customer')
        : (chat['shopName'] ?? 'Shop Owner');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppTheme.bubbleReceived,
          child: Icon(Icons.person_rounded, color: Colors.white70),
        ),
        title: Text(
          displayName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          (chat['lastMessage'] != null &&
                  chat['lastMessage'].toString().isNotEmpty)
              ? chat['lastMessage']
              : 'Start a conversation',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat['totalBalance'] != null && chat['totalBalance'] != 0)
              Text(
                '₹${chat['totalBalance']}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: (chat['totalBalance'] as num) > 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (chat['lastMessageAt'] != null)
              Text(
                _formatTimestamp(chat['lastMessageAt']),
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.white24),
              ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.chat,
            arguments: {
              'chatId': chat['id'],
              'participantName': displayName,
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dt;
    if (timestamp is DateTime) {
      dt = timestamp;
    } else if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else {
      return '';
    }
    var hour = dt.hour;
    final isPm = hour >= 12;
    final amPm = isPm ? 'pm' : 'am';

    // Convert to 12h
    hour = hour % 12;
    if (hour == 0) hour = 12;

    final h = hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $amPm';
  }
}
