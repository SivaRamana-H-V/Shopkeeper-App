import 'package:cloud_firestore/cloud_firestore.dart';

/// Message types supported by Pulse chat.
enum MessageType {
  text,
  image,
  ledgerEntry; // future: structured transaction messages

  static MessageType fromString(String? value) => switch (value) {
    'image' => MessageType.image,
    'ledgerEntry' => MessageType.ledgerEntry,
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
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final bool isRead;

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
  };

  // ── Convenience ───────────────────────────────────────────────────────────

  MessageModel copyWith({bool? isRead}) => MessageModel(
    id: id,
    senderId: senderId,
    senderName: senderName,
    text: text,
    timestamp: timestamp,
    type: type,
    imageUrl: imageUrl,
    isRead: isRead ?? this.isRead,
  );

  @override
  String toString() =>
      'MessageModel(id: $id, sender: $senderName, text: $text)';
}
