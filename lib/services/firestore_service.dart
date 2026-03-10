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

  /// Creates a new chat thread between two users.
  /// Returns the chatId (reuses if already exists).
  Future<String> getOrCreateChat({
    required String uidA,
    required String uidB,
  }) async {
    try {
      // Canonical chatId: sorted UIDs joined with '_'
      final ids = [uidA, uidB]..sort();
      final chatId = ids.join('_');

      final doc = await _db.collection('chats').doc(chatId).get();
      if (!doc.exists) {
        await _db.collection('chats').doc(chatId).set({
          'participants': ids,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
        });
      }
      return chatId;
    } catch (e) {
      _log.e('getOrCreateChat failed', error: e);
      rethrow;
    }
  }
}
