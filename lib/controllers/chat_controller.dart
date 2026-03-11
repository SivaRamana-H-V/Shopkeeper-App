import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/models/message_model.dart';
import 'package:pulse_ledger/models/user_model.dart';

/// Streams the message list for a given [chatId].
final chatControllerProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.read(firestoreServiceProvider).streamMessages(chatId);
});

/// Streams all chats for the currently signed-in user.
final chatListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.read(firestoreServiceProvider).streamUserChats(user.uid);
    },
    orElse: () => const Stream.empty(),
  );
});

/// Streams metadata for a specific chat.
final chatMetadataProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, chatId) {
  return ref.read(firestoreServiceProvider).streamChatDetail(chatId);
});

/// Streams any user document by UID.
final userProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return ref.read(firestoreServiceProvider).streamUser(uid);
});

/// Notifier used to send a message in a chat thread.
class ChatSendNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> send({required String chatId, required String text}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final userModel =
        await ref.read(firestoreServiceProvider).fetchUser(user.uid);

    final message = MessageModel(
      id: '',
      senderId: user.uid,
      senderName: userModel?.displayName ?? user.displayName ?? 'Me',
      text: text,
      timestamp: DateTime.now(),
    );

    await ref.read(firestoreServiceProvider).sendTransactionalMessage(
          chatId: chatId,
          message: message,
        );
  }

  Future<void> sendCreditRequest({
    required String chatId,
    required double amount,
    required String description,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final userModel =
        await ref.read(firestoreServiceProvider).fetchUser(user.uid);

    final message = MessageModel(
      id: '',
      senderId: user.uid,
      senderName: userModel?.displayName ?? user.displayName ?? 'Me',
      text: '', // No text needed for structured credit request
      timestamp: DateTime.now(),
      type: MessageType.creditRequest,
      metadata: {
        MessageModel.amountKey: amount,
        MessageModel.descriptionKey: description,
        MessageModel.statusKey: MessageModel.statusPending,
      },
    );

    await ref.read(firestoreServiceProvider).sendTransactionalMessage(
          chatId: chatId,
          message: message,
          lastMessagePreview: '₹$amount Credit Requested',
        );
  }
}

final chatSendProvider = NotifierProvider<ChatSendNotifier, void>(
  ChatSendNotifier.new,
);
