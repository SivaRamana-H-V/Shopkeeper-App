import 'package:json_annotation/json_annotation.dart';

part 'entry_model.g.dart';

enum EntryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('disputed')
  disputed,
}

@JsonSerializable()
class Entry {
  final String id;
  @JsonKey(name: 'customer_id')
  final String customerId; // UUID
  @JsonKey(name: 'customer_code')
  final String? customerCode; // CUST-...
  final double amount;
  final EntryStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Entry({
    required this.id,
    required this.customerId,
    this.customerCode,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
  Map<String, dynamic> toJson() => _$EntryToJson(this);
}
