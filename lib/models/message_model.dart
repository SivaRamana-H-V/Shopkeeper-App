import 'package:cloud_firestore/cloud_firestore.dart';

/// Message types supported by Pulse chat.
enum MessageType {
  text,
  image,
  ledgerEntry,
  creditRequest; // specialized financial request

  static MessageType fromString(String? value) => switch (value) {
        'image' => MessageType.image,
        'ledgerEntry' => MessageType.ledgerEntry,
        'creditRequest' => MessageType.creditRequest,
        _ => MessageType.text,
      };
}

/// A single message in a Pulse chat thread.
/// Stored in Firestore: `chats/{chatId}/messages/{messageId}`.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.isRead = false,
    this.metadata = const {},
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final bool isRead;
  final Map<String, dynamic> metadata;

  // Metadata keys for credit_request
  static const String amountKey = 'amount';
  static const String descriptionKey = 'description';
  static const String statusKey = 'status';

  // Status values
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // ── Firestore serialisation ────────────────────────────────────────────────

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.fromString(data['type'] as String?),
      imageUrl: data['imageUrl'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type.name,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isRead': isRead,
        'metadata': metadata,
      };

  // ── Convenience ───────────────────────────────────────────────────────────

  MessageModel copyWith({bool? isRead, Map<String, dynamic>? metadata}) =>
      MessageModel(
        id: id,
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: timestamp,
        type: type,
        imageUrl: imageUrl,
        isRead: isRead ?? this.isRead,
        metadata: metadata ?? this.metadata,
      );

  @override
  String toString() =>
      'MessageModel(id: $id, sender: $senderName, text: $text)';
}
