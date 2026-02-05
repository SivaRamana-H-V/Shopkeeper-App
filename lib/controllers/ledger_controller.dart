import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/entry_model.dart';
import '../services/supabase_service.dart';

/// PROVIDER
final ledgerControllerProvider =
    StateNotifierProvider.family<
      LedgerController,
      AsyncValue<List<Entry>>,
      String
    >((ref, customerId) => LedgerController(customerId));

/// CONTROLLER
class LedgerController extends StateNotifier<AsyncValue<List<Entry>>> {
  final String customerId;

  LedgerController(this.customerId) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      final response = await SupabaseService.client
          .from('entries')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      final list = (response as List).map((e) => Entry.fromJson(e)).toList();

      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addEntry(double amount) async {
    try {
      state = const AsyncValue.loading();

      await SupabaseService.client.from('entries').insert({
        'customer_id': customerId,
        'amount': amount,
        'status': 'pending',
      });

      await loadEntries();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
