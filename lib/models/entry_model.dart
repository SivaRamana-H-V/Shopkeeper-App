class Entry {
  final String id;
  final String customerId;
  final double amount;
  final String status; // Pending, Approved, Disputed
  final DateTime createdAt;

  Entry({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'amount': amount,
      'status': status,
      // created_at is usually handled by DB default
    };
  }
}
