import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../services/supabase_service.dart';
import '../core/auth_session.dart';

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
        .from('customers')
        .select()
        .eq('shopkeeper_id', shopkeeperId)
        .order('created_at', ascending: false);

    final data = res as List<dynamic>;
    return data.map((e) => Customer.fromJson(e)).toList();
  }

  Future<void> addCustomer(String name, String phone) async {
    final shopkeeperId = AuthSession.shopkeeperId;
    if (shopkeeperId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SupabaseService.client.from('customers').insert({
        'shopkeeper_id': shopkeeperId,
        'name': name,
        'phone': phone,
      });
      return _getCustomers();
    });
  }

  // Method to refresh manually if needed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getCustomers());
  }
}
