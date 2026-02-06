import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/models/customer_model.dart';
import 'package:shopkeeper_app/services/supabase_service.dart';
import 'package:shopkeeper_app/core/auth_session.dart';

final customerControllerProvider =
    AsyncNotifierProvider<CustomerController, List<Customer>>(
      CustomerController.new,
    );

class CustomerController extends AsyncNotifier<List<Customer>> {
  @override
  FutureOr<List<Customer>> build() async {
    return _getCustomers();
  }

  Future<List<Customer>> _getCustomers() async {
    final shopkeeperId = AuthSession.shopkeeperId;
    if (shopkeeperId == null) return []; // Or throw

    final res = await SupabaseService.client
        .from(AppStrings.customersTable)
        .select()
        .eq(AppStrings.shopkeeperIdField, shopkeeperId)
        .order(AppStrings.createdAtField, ascending: false);

    final data = res as List<dynamic>;
    final List<Customer> customers = data
        .map((e) => Customer.fromJson(e))
        .toList();

    // Calculate real totalDue for each customer and handle token migration
    final List<Customer> updatedCustomers = [];
    for (var customer in customers) {
      String? activeToken = customer.token;

      // Auto-migrate null tokens
      if (activeToken == null) {
        activeToken = _generateToken();
        await SupabaseService.client
            .from(AppStrings.customersTable)
            .update({AppStrings.tokenField: activeToken})
            .eq(AppStrings.idField, customer.id);
      }

      final entriesRes = await SupabaseService.client
          .from(AppStrings.entriesTable)
          .select('${AppStrings.amountField}, ${AppStrings.statusField}')
          .eq(AppStrings.customerIdField, customer.id);

      final entriesData = (entriesRes as List<dynamic>)
          .map(
            (e) => {
              AppStrings.amountField: e[AppStrings.amountField],
              AppStrings.statusField: e[AppStrings.statusField],
            },
          )
          .toList();

      final double total = entriesData.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item[AppStrings.statusField] != AppStrings.disputed
                ? (item[AppStrings.amountField] as num).toDouble()
                : 0),
      );

      updatedCustomers.add(
        customer.copyWith(totalDue: total, token: activeToken),
      );
    }

    return updatedCustomers;
  }

  Future<void> addCustomer(String name, String phone) async {
    final customerCode =
        '${AppStrings.codePrefix}${DateTime.now().millisecondsSinceEpoch}';
    final shopkeeperId = AuthSession.shopkeeperId;
    if (shopkeeperId == null) return;

    final token = _generateToken();

    state = const AsyncValue.loading();
    try {
      state = await AsyncValue.guard(() async {
        await SupabaseService.client.from(AppStrings.customersTable).insert({
          AppStrings.customerCodeField: customerCode,
          AppStrings.shopkeeperIdField: shopkeeperId,
          AppStrings.nameField: name,
          AppStrings.phoneField: phone,
          AppStrings.tokenField: token,
        });
        return _getCustomers();
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  String _generateToken() {
    const chars = AppStrings.tokenChars;
    final rnd = DateTime.now().microsecondsSinceEpoch;
    return List.generate(10, (index) {
      return chars[(rnd + index * 7) % chars.length];
    }).join();
  }

  // Method to refresh manually if needed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getCustomers());
  }

  Future<void> refreshCustomers() async {
    state = await AsyncValue.guard(() => _getCustomers());
  }
}
