import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class Customer {
  final String id; // UUID from Supabase
  @JsonKey(name: 'customer_code')
  final String customerCode; // Human-readable code (CUST-...)
  @JsonKey(name: 'shopkeeper_id')
  final String shopkeeperId;
  final String name;
  final String phone;
  @JsonKey(name: 'total_due')
  final double? totalDue;
  final String? token;

  Customer({
    required this.id,
    required this.customerCode,
    required this.shopkeeperId,
    required this.name,
    required this.phone,
    this.totalDue,
    this.token,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer copyWith({
    String? id,
    String? customerCode,
    String? shopkeeperId,
    String? name,
    String? phone,
    double? totalDue,
    String? token,
  }) {
    return Customer(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      shopkeeperId: shopkeeperId ?? this.shopkeeperId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalDue: totalDue ?? this.totalDue,
      token: token ?? this.token,
    );
  }
}
