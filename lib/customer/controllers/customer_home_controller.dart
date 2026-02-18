import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/customer/models/customer_dashboard_model.dart';
import 'package:shopkeeper_app/shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper_app/shopkeeper/core/auth_session.dart';
import 'package:shopkeeper_app/shopkeeper/services/supabase_service.dart';

final customerHomeControllerProvider =
    AsyncNotifierProvider.autoDispose<
      CustomerHomeController,
      CustomerDashboardData
    >(CustomerHomeController.new);

class CustomerHomeController
    extends AutoDisposeAsyncNotifier<CustomerDashboardData> {
  @override
  FutureOr<CustomerDashboardData> build() async {
    return _fetchDashboardData();
  }

  Future<CustomerDashboardData> _fetchDashboardData() async {
    final phone = AuthSession.customerPhone;
    if (phone == null || phone.isEmpty) {
      // Return empty or throw, depending on flow.
      // Ideally redirect to login if no phone, but here return empty.
      return CustomerDashboardData(
        totalOutstanding: 0,
        shopkeepers: [],
        recentEntries: [],
      );
    }

    // 1. Fetch Customers entries linked to this phone
    // We need to find "customers" table rows where phone == phone
    final customersRes = await SupabaseService.client
        .from(AppStrings.customersTable)
        .select()
        .eq(
          AppStrings.phoneField,
          phone,
        ); // Ensure phone matching is robust (normalization)

    final customers = (customersRes as List);

    if (customers.isEmpty) {
      return CustomerDashboardData(
        totalOutstanding: 0,
        shopkeepers: [],
        recentEntries: [],
      );
    }

    double totalOutstanding = 0;
    final List<ShopkeeperCardData> shopkeepers = [];
    final List<CustomerEntryData> recentEntries = [];

    for (var cust in customers) {
      final custId = cust[AppStrings.idField];
      final shopkeeperId = cust[AppStrings.shopkeeperIdField];
      // We might want shop name.
      // Assuming 'customers' table doesn't have shop name?
      // We need to join or fetch shopkeeper details?
      // AuthSession.shopName is only for logged in shopkeeper.

      // For now, let's assume we can't easily get shop name unless we have a 'shopkeepers' table or similar.
      // But looking at 'customers' table in previous steps, it has 'shopkeeperId'.
      // If we don't have a 'users' or 'shopkeepers' public table, we might just show "Shop #ID" or empty.
      // Let's check if we can get shop name.
      // If not, we'll use placeholder.
      String shopName = "Shop";

      // Fetch entries for this customer-shop link
      final entriesRes = await SupabaseService.client
          .from(AppStrings.entriesTable)
          .select()
          .eq(AppStrings.customerIdField, custId)
          .order(AppStrings.createdAtField, ascending: false);

      final entries = (entriesRes as List);

      double shopTotal = 0;
      for (var entry in entries) {
        final amount = (entry[AppStrings.amountField] as num).toDouble();
        final status = entry[AppStrings.statusField];
        if (status != 'disputed') {
          shopTotal += amount;
        }

        // Add to recent entries (global list, we will sort later or take top 5)
        recentEntries.add(
          CustomerEntryData(
            id: entry[AppStrings.idField],
            shopName: shopName, // Todo: Real shop name
            amount: amount,
            type: amount < 0 ? 'Payment' : 'Credit',
            createdAt: DateTime.parse(entry[AppStrings.createdAtField]),
            status: status,
          ),
        );
      }

      totalOutstanding += shopTotal;
      shopkeepers.add(
        ShopkeeperCardData(
          shopkeeperId: shopkeeperId,
          shopName: shopName,
          totalDue: shopTotal,
          customerId: custId, // We need this to navigate to LedgerView
        ),
      );
    }

    // Sort recent entries
    recentEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return CustomerDashboardData(
      totalOutstanding: totalOutstanding,
      shopkeepers: shopkeepers,
      recentEntries: recentEntries.take(10).toList(),
    );
  }
}
