import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported user roles in Pulse.
enum UserRole {
  shopOwner,
  customer;

  String get label => switch (this) {
    UserRole.shopOwner => 'Shop Owner',
    UserRole.customer => 'Customer',
  };

  static UserRole fromString(String? value) => switch (value) {
    'shopOwner' => UserRole.shopOwner,
    'customer' => UserRole.customer,
    _ => UserRole.customer,
  };
}

/// Represents a Pulse user stored in Firestore `users/{uid}`.
class UserModel {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.role,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;

  // ── Firestore serialisation ────────────────────────────────────────────────

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.fromString(data['role'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    if (phone != null) 'phone': phone,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'role': role.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  // ── Convenience ───────────────────────────────────────────────────────────

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    UserRole? role,
  }) => UserModel(
    uid: uid,
    displayName: displayName ?? this.displayName,
    email: email,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    role: role ?? this.role,
    createdAt: createdAt,
  );

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $displayName, role: ${role.name})';
}
