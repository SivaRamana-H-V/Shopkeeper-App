class Customer {
  final String id;
  final String shopkeeperId;
  final String name;
  final String phone;
  final double? totalDue; // Optional/Calculated

  Customer({
    required this.id,
    required this.shopkeeperId,
    required this.name,
    required this.phone,
    this.totalDue,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      shopkeeperId: json['shopkeeper_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      // total_due might come from a view or be null
      totalDue: json['total_due'] != null
          ? (json['total_due'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'shopkeeper_id': shopkeeperId, 'name': name, 'phone': phone};
  }
}
