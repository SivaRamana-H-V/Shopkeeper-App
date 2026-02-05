class Shopkeeper {
  final String id;
  final String username;
  final String shopName;

  Shopkeeper({
    required this.id,
    required this.username,
    required this.shopName,
  });

  factory Shopkeeper.fromJson(Map<String, dynamic> json) {
    return Shopkeeper(
      id: json['id'] as String,
      username: json['username'] as String,
      shopName: json['shop_name'] as String,
    );
  }
}
