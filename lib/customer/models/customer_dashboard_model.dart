class CustomerDashboardData {
  final double totalOutstanding;
  final List<ShopkeeperCardData> shopkeepers;
  final List<CustomerEntryData> recentEntries;

  CustomerDashboardData({
    required this.totalOutstanding,
    required this.shopkeepers,
    required this.recentEntries,
  });
}

class ShopkeeperCardData {
  final String shopName;
  final String shopkeeperId;
  final String customerId; // My ID in that shop
  final double totalDue;

  ShopkeeperCardData({
    required this.shopName,
    required this.shopkeeperId,
    required this.customerId,
    required this.totalDue,
  });
}

class CustomerEntryData {
  final String id;
  final String shopName;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String type; // Credit or Payment (implied by amount sign or context)

  CustomerEntryData({
    required this.id,
    required this.shopName,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.type,
  });
}
