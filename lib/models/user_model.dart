import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    this.shopName,
    this.businessName,
    this.upiId,
    this.totalOutstanding = 0.0,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final String? shopName;
  final String? businessName;
  final String? upiId;
  final double totalOutstanding;
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
      shopName: data['shopName'] as String?,
      businessName: data['businessName'] as String?,
      upiId: data['upiId'] as String?,
      totalOutstanding: (data['totalOutstanding'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromAuth(User user, UserRole role, {String? shopName}) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
      role: role,
      shopName: shopName,
      businessName: shopName, // Default business name to shop name if provided
      totalOutstanding: 0.0,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        if (phone != null) 'phone': phone,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'role': role.name,
        if (shopName != null) 'shopName': shopName,
        if (businessName != null) 'businessName': businessName,
        if (upiId != null) 'upiId': upiId,
        'totalOutstanding': totalOutstanding,
        'createdAt': FieldValue.serverTimestamp(),
      };

  // ── Convenience ───────────────────────────────────────────────────────────

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    UserRole? role,
    String? shopName,
    String? businessName,
    String? upiId,
    double? totalOutstanding,
  }) =>
      UserModel(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email,
        phone: phone ?? this.phone,
        photoUrl: photoUrl ?? this.photoUrl,
        role: role ?? this.role,
        shopName: shopName ?? this.shopName,
        businessName: businessName ?? this.businessName,
        upiId: upiId ?? this.upiId,
        totalOutstanding: totalOutstanding ?? this.totalOutstanding,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $displayName, role: ${role.name})';
}
