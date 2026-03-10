import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/chat_controller.dart';
import 'package:pulse_ledger/widgets/chat_bubble.dart';
import 'package:pulse_ledger/widgets/pulse_text_field.dart';

class ChatView extends ConsumerWidget {
  const ChatView({
    super.key,
    required this.chatId,
    required this.participantName,
  });

  final String chatId;
  final String participantName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatControllerProvider(chatId));
    final currentUser = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(participantName, style: theme.textTheme.titleMedium),
                Text('Active now',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.greenAccent)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (list) {
                if (list.isEmpty) {
                  return const _WelcomeChatBanner();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  reverse: false, // We stream ascending from Firestore order
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final msg = list[index];
                    return ChatBubble(
                      text: msg.text,
                      isSent: msg.senderId == currentUser?.uid,
                      timestamp: msg.timestamp,
                      senderName: msg.senderName,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          ChatInputField(
            onSend: (text) => ref.read(chatSendProvider.notifier).send(
                  chatId: chatId,
                  text: text,
                ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeChatBanner extends StatelessWidget {
  const _WelcomeChatBanner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security_rounded,
                  color: Colors.white24, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Your messages are secure',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white38),
            ),
            const SizedBox(height: 8),
            const Text(
              'This chat is exclusively for business transactions and ledger updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
