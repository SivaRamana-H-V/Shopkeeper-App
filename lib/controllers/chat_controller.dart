import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/models/message_model.dart';

/// Streams the message list for a given [chatId].
final chatControllerProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
      return ref.read(firestoreServiceProvider).streamMessages(chatId);
    });

/// Streams all chats for the currently signed-in user.
final chatListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(firestoreServiceProvider).streamUserChats(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Notifier used to send a message in a chat thread.
class ChatSendNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> send({required String chatId, required String text}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final userModel = await ref
        .read(firestoreServiceProvider)
        .fetchUser(user.uid);

    final message = MessageModel(
      id: '',
      senderId: user.uid,
      senderName: userModel?.displayName ?? user.displayName ?? 'Me',
      text: text,
      timestamp: DateTime.now(),
    );

    await ref.read(firestoreServiceProvider).sendMessage(chatId, message);
  }
}

final chatSendProvider = NotifierProvider<ChatSendNotifier, void>(
  ChatSendNotifier.new,
);
