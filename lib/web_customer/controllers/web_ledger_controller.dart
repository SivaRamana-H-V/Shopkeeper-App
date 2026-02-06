import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/models/entry_model.dart';
import 'package:shopkeeper_app/services/supabase_service.dart';
import 'package:shopkeeper_app/web_customer/models/web_ledger_state.dart';

final webLedgerControllerProvider =
    StateNotifierProvider.family<
      CustomerWebLedgerController,
      AsyncValue<WebLedgerState>,
      String
    >((ref, token) => CustomerWebLedgerController(ref, token));

class CustomerWebLedgerController
    extends StateNotifier<AsyncValue<WebLedgerState>> {
  final Ref ref;
  final String token;

  CustomerWebLedgerController(this.ref, this.token)
    : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      // 1. Fetch customer by token
      final customerRes = await SupabaseService.client
          .from('customers')
          .select('id, name, shopkeeper_id')
          .eq('token', token)
          .single();

      final customerId = customerRes['id'] as String;
      final customerName = customerRes['name'] as String;
      final shopkeeperId = customerRes['shopkeeper_id'] as String;

      // 2. Fetch shop name
      final shopRes = await SupabaseService.client
          .from('shopkeepers')
          .select('shop_name')
          .eq('id', shopkeeperId)
          .single();
      final shopName = shopRes['shop_name'] as String;

      // 3. Fetch entries
      final entriesRes = await SupabaseService.client
          .from('entries')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      final entries = (entriesRes as List)
          .map((e) => Entry.fromJson(e))
          .toList();

      // 4. Calculate total (Pending + Approved)
      final totalDue = entries.fold<double>(
        0,
        (sum, item) =>
            sum + (item.status != EntryStatus.disputed ? item.amount : 0),
      );

      state = AsyncValue.data(
        WebLedgerState(
          customerName: customerName,
          shopName: shopName,
          entries: entries,
          totalDue: totalDue,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> approveEntry(String entryId) async {
    try {
      await SupabaseService.client
          .from('entries')
          .update({'status': 'approved'})
          .eq('id', entryId);
      await loadData();
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> disputeEntry(String entryId) async {
    try {
      await SupabaseService.client
          .from('entries')
          .update({'status': 'disputed'})
          .eq('id', entryId);
      await loadData();
    } catch (e) {
      // Handle error if needed
    }
  }
}
