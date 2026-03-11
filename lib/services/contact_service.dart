import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:logger/logger.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Requests permission and fetches all local contacts with phone numbers.
  Future<List<Contact>> getLocalContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      return [];
    }
    return await FlutterContacts.getContacts(withProperties: true);
  }

  /// Normalizes a phone number for consistent Firestore matching.
  String normalizePhoneNumber(String phone) {
    // 1. Scrub: Remove all non-numeric characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // 2. Prepend +91 if 10 digits
    if (digits.length == 10) {
      return '+91$digits';
    }

    // 3. If it was international (started with +), restore the +
    if (phone.startsWith('+')) {
      return '+$digits';
    }

    return digits;
  }

  /// Syncs local contacts with Firestore users collection.
  /// Uses whereIn queries in batches of 30.
  Future<List<UserModel>> syncMatchedUsers(List<Contact> localContacts) async {
    final Set<String> uniquePhones = {};
    for (var contact in localContacts) {
      for (var phone in contact.phones) {
        final normalized = normalizePhoneNumber(phone.number);
        if (normalized.isNotEmpty) {
          uniquePhones.add(normalized);
        }
      }
    }

    if (uniquePhones.isEmpty) return [];

    final List<String> phoneList = uniquePhones.toList();

    final List<UserModel> matchedUsers = [];

    // Firestore whereIn allows up to 30 values
    for (var i = 0; i < phoneList.length; i += 30) {
      final end = (i + 30 < phoneList.length) ? i + 30 : phoneList.length;
      final batch = phoneList.sublist(i, end);

      try {
        final querySnapshot = await _firestore
            .collection('users')
            .where('phone', whereIn: batch)
            .where('role', isEqualTo: 'customer')
            .get();

        for (var doc in querySnapshot.docs) {
          matchedUsers.add(UserModel.fromFirestore(doc));
        }
      } catch (e) {
        _logger.e('Error querying batch: $e');
      }
    }

    return matchedUsers;
  }
}
