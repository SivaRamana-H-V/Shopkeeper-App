import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/chat_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/message_model.dart';
import 'package:pulse_ledger/services/upi_service.dart';
import 'package:pulse_ledger/widgets/chat_bubble.dart';
import 'package:pulse_ledger/widgets/credit_request_card.dart';
import 'package:pulse_ledger/widgets/pulse_text_field.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({
    super.key,
    required this.chatId,
    required this.participantName,
  });

  final String chatId;
  final String participantName;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider).value;
    final isShopOwner = ref.watch(isShopOwnerProvider);
    final theme = Theme.of(context);

    final chatMetadata = ref.watch(chatMetadataProvider(widget.chatId)).value;
    final totalBalance =
        (chatMetadata?['totalBalance'] as num?)?.toDouble() ?? 0.0;
    final shopId = chatMetadata?['shopId'] as String?;

    // Listen to message updates to auto-scroll
    ref.listen(chatControllerProvider(widget.chatId), (previous, next) {
      next.whenData((list) {
        final prevLength = previous?.value?.length ?? 0;
        if (list.length > prevLength) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
      });
    });

    void handleUpiPayment([double? amountToPay]) async {
      if (shopId == null) return;

      // Fetch shop owner details
      final shopOwner =
          await ref.read(firestoreServiceProvider).fetchUser(shopId);

      if (shopOwner == null ||
          shopOwner.upiId == null ||
          shopOwner.upiId!.isEmpty) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('UPI Not Linked'),
            content: const Text(
                'The shop owner hasn\'t linked their UPI yet. Please pay by cash.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        try {
          await UpiService.launchUpiPayment(
            upiId: shopOwner.upiId!,
            name: shopOwner.businessName ?? shopOwner.displayName,
            amount: amountToPay ?? totalBalance,
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }

    void showCreditRequestSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: CreditRequestSheet(
            onSendRequest: (amount, desc) {
              ref.read(chatSendProvider.notifier).sendCreditRequest(
                    chatId: widget.chatId,
                    amount: amount,
                    description: desc,
                  );
              _scrollToBottom();
            },
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                Text(
                  widget.participantName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.royalPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Active Ledger',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.greenAccent)),
              ],
            ),
          ],
        ),
        actions: [
          if (!isShopOwner && totalBalance > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                onPressed: () => handleUpiPayment(),
                icon: const Icon(Icons.payment, size: 18),
                label: Text('Pay ₹${totalBalance.toStringAsFixed(0)}'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  foregroundColor: Colors.greenAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (list) {
                if (list.isEmpty) {
                  return _WelcomeChatBanner(
                    isShopOwner: isShopOwner,
                    participantName: widget.participantName,
                    onAction: () => showCreditRequestSheet(context),
                  );
                }
                // Reverse the list for reverse: true ListView
                final reversedList = list.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  reverse: true,
                  itemCount: reversedList.length,
                  itemBuilder: (context, index) {
                    final msg = reversedList[index];
                    final isSent = msg.senderId == currentUser?.uid;

                    if (msg.type == MessageType.creditRequest) {
                      final amount =
                          (msg.metadata[MessageModel.amountKey] as num?)
                                  ?.toDouble() ??
                              0.0;
                      return CreditRequestCard(
                        message: msg,
                        isShopOwner: isShopOwner,
                        isSender: isSent,
                        onApprove: () => _handleApproval(
                          ref,
                          msg.id,
                          amount,
                          currentUser?.uid ?? '',
                        ),
                        onReject: () => _updateStatus(
                          ref,
                          msg.id,
                          MessageModel.statusRejected,
                        ),
                        onPay: (!isShopOwner &&
                                !isSent &&
                                msg.metadata[MessageModel.statusKey] ==
                                    MessageModel.statusApproved)
                            ? () => handleUpiPayment(amount)
                            : null,
                      );
                    }

                    return ChatBubble(
                      text: msg.text,
                      isSent: isSent,
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
          SafeArea(
            top: false,
            child: ChatInputField(
              showCreditTools: ref.watch(isShopOwnerProvider),
              onSend: (text) {
                ref.read(chatSendProvider.notifier).send(
                      chatId: widget.chatId,
                      text: text,
                    );
                _scrollToBottom();
              },
              onCreditRequest: (amount, desc) {
                ref.read(chatSendProvider.notifier).sendCreditRequest(
                      chatId: widget.chatId,
                      amount: amount,
                      description: desc,
                    );
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(WidgetRef ref, String messageId, String status) {
    ref.read(firestoreServiceProvider).updateMessageStatus(
          chatId: widget.chatId,
          messageId: messageId,
          status: status,
        );
  }

  void _handleApproval(
    WidgetRef ref,
    String messageId,
    double amount,
    String customerId,
  ) {
    ref.read(firestoreServiceProvider).approveCreditRequest(
          chatId: widget.chatId,
          messageId: messageId,
          amount: amount,
          customerId: customerId,
        );
  }
}

class _WelcomeChatBanner extends StatelessWidget {
  const _WelcomeChatBanner({
    required this.participantName,
    required this.onAction,
    required this.isShopOwner,
  });

  final String participantName;
  final VoidCallback onAction;
  final bool isShopOwner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.amberGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.amberGold,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isShopOwner
                  ? 'Start your ledger with $participantName by requesting the first credit.'
                  : 'Start your ledger with $participantName by accepting the first credit.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            if (isShopOwner)
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.amberGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Request Credit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
