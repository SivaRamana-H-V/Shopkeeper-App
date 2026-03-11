import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:pulse_ledger/models/message_model.dart';
import 'package:pulse_ledger/models/user_model.dart';

/// All Firestore read/write operations for Pulse.
///
/// Collection layout:
///   users/{uid}                      → UserModel
///   chats/{chatId}/messages/{msgId}  → MessageModel
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final Logger _log = Logger();

  // ── Collection references ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  // ── Users ──────────────────────────────────────────────────────────────────

  /// Creates (or merges) a user document in Firestore.
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _users
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
      _log.i('User profile created: ${user.uid}');
    } catch (e) {
      _log.e('createUserProfile failed', error: e);
      rethrow;
    }
  }

  /// Streams a single user document in real-time.
  Stream<UserModel?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserModel.fromFirestore(snap);
    });
  }

  /// Fetches a user document once.
  Future<UserModel?> fetchUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      _log.e('fetchUser failed', error: e);
      rethrow;
    }
  }

  /// Updates the role field for [uid].
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _users.doc(uid).update({'role': role.name});
      _log.i('Updated role for $uid → ${role.name}');
    } catch (e) {
      _log.e('updateUserRole failed', error: e);
      rethrow;
    }
  }

  /// Updates user profile details.
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _users.doc(uid).update(data);
      _log.i('Updated profile for $uid');
    } catch (e) {
      _log.e('updateUserProfile failed', error: e);
      rethrow;
    }
  }

  // ── Chat / Messages ────────────────────────────────────────────────────────

  /// Streams messages for [chatId] ordered by timestamp ascending.
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _messages(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => MessageModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  /// Sends a new [message] to the [chatId] thread.
  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      await _messages(chatId).add(message.toFirestore());
    } catch (e) {
      _log.e('sendMessage failed', error: e);
      rethrow;
    }
  }

  /// Sends a message and updates the parent chat document atomically.
  Future<void> sendTransactionalMessage({
    required String chatId,
    required MessageModel message,
    String? lastMessagePreview,
  }) async {
    try {
      final chatRef = _db.collection('chats').doc(chatId);
      final msgRef = _messages(chatId).doc(); // Auto-ID

      await _db.runTransaction((transaction) async {
        // 1. Add the message
        transaction.set(msgRef, message.toFirestore());

        // 2. Update the chat summary
        transaction.update(chatRef, {
          'lastMessage': lastMessagePreview ?? message.text,
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      });
      _log.i('Transactional message sent: ${msgRef.id}');
    } catch (e) {
      _log.e('sendTransactionalMessage failed', error: e);
      rethrow;
    }
  }

  /// Updates the metadata status of a specific message.
  Future<void> updateMessageStatus({
    required String chatId,
    required String messageId,
    required String status,
  }) async {
    try {
      await _messages(chatId).doc(messageId).update({
        'metadata.${MessageModel.statusKey}': status,
      });
      _log.i('Message $messageId status updated to $status');
    } catch (e) {
      _log.e('updateMessageStatus failed', error: e);
      rethrow;
    }
  }

  /// Atomically approves a credit request and updates ledger balances.
  Future<void> approveCreditRequest({
    required String chatId,
    required String messageId,
    required double amount,
    required String customerId,
  }) async {
    try {
      final chatRef = _db.collection('chats').doc(chatId);
      final msgRef = _messages(chatId).doc(messageId);
      final customerRef = _users.doc(customerId);

      await _db.runTransaction((transaction) async {
        // 1. Update message status
        transaction.update(msgRef, {
          'metadata.${MessageModel.statusKey}': MessageModel.statusApproved,
        });

        // 2. Increment chat balance
        transaction.update(chatRef, {
          'totalBalance': FieldValue.increment(amount),
          'lastMessage': '₹${amount.toStringAsFixed(0)} Credit Approved',
          'lastMessageAt': FieldValue.serverTimestamp(),
        });

        // 3. Increment customer outstanding
        transaction.update(customerRef, {
          'totalOutstanding': FieldValue.increment(amount),
        });
      });
      _log.i('Credit approved and balances synced for $chatId');
    } catch (e) {
      _log.e('approveCreditRequest failed', error: e);
      rethrow;
    }
  }

  /// Streams all chat room documents that involve [uid].
  /// Assumes each chat doc has a `participants` array field.
  Stream<List<Map<String, dynamic>>> streamUserChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }

  /// Streams metadata for a single chat room.
  Stream<Map<String, dynamic>?> streamChatDetail(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return {'id': snap.id, ...snap.data()!};
    });
  }

  /// Creates (or merges) a chat thread between two users.
  /// Returns the chatId using shopId_customerId format.
  /// Uses a direct .set(merge: true) to bypass permission traps on .get().
  Future<String> getOrCreateChat({
    required String shopId,
    required String shopName,
    required String customerId,
    required String customerName,
  }) async {
    final chatId = '${shopId}_$customerId';
    try {
      final data = {
        'participants': [shopId, customerId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'shopId': shopId,
        'shopName': shopName,
        'customerId': customerId,
        'customerName': customerName,
        'status': 'active',
      };

      _log.d('🚀 Handshake: Force merging into chats/$chatId');
      _log.d('📦 Handshake Data: $data');

      // Attempt immediate write with merge. This avoids a .get()
      // which often fails on non-existent docs due to security rules.
      await _db.collection('chats').doc(chatId).set(
            data,
            SetOptions(merge: true),
          );

      _log.i('✅ Handshake successful: $chatId');
      return chatId;
    } catch (e, stack) {
      _log.e('⛔ Handshake failed for chatId: $chatId',
          error: e, stackTrace: stack);
      rethrow;
    }
  }
}
