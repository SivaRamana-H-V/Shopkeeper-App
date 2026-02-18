import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper_app/shopkeeper/models/entry_model.dart';
import 'package:shopkeeper_app/shopkeeper/services/supabase_service.dart';
import 'package:shopkeeper_app/shopkeeper/controllers/ledger_state.dart';
import 'package:shopkeeper_app/shopkeeper/controllers/customer_controller.dart';

/// PROVIDER
final ledgerControllerProvider =
    StateNotifierProvider.family<
      LedgerController,
      AsyncValue<LedgerState>,
      String
    >((ref, customerId) => LedgerController(ref, customerId));

/// CONTROLLER
class LedgerController extends StateNotifier<AsyncValue<LedgerState>> {
  final Ref ref;
  final String customerId;

  LedgerController(this.ref, this.customerId)
    : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      // 1. Fetch Entries
      final entriesResponse = await SupabaseService.client
          .from(AppStrings.entriesTable)
          .select()
          .eq(AppStrings.customerIdField, customerId)
          .order(AppStrings.createdAtField, ascending: false);

      final entries = (entriesResponse as List)
          .map((e) => Entry.fromJson(e))
          .toList();

      // 2. Calculate Total Due
      final totalDue = entries.fold<double>(
        0,
        (sum, item) =>
            sum + (item.status != EntryStatus.disputed ? item.amount : 0),
      );

      // 3. Fetch Customer Details
      // We check if we already have them to avoid flicker if possible, but fetching is safer for now
      final customerRes = await SupabaseService.client
          .from(AppStrings.customersTable)
          .select('${AppStrings.customerCodeField}, ${AppStrings.nameField}')
          .eq(AppStrings.idField, customerId)
          .single();

      final currentCode = customerRes[AppStrings.customerCodeField] as String;
      final currentName = customerRes[AppStrings.nameField] as String;

      state = AsyncValue.data(
        LedgerState(
          entries: entries,
          customerCode: currentCode,
          totalDue: totalDue,
          customerName: currentName,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addEntry(double amount) async {
    final currentState = state.value;
    if (currentState?.customerCode == null) {
      // Ensure we have data
      await loadEntries();
      if (!state.hasValue) return;
    }

    final customerCode = state.value!.customerCode!;

    state = const AsyncValue.loading();
    try {
      await SupabaseService.client.from(AppStrings.entriesTable).insert({
        AppStrings.customerIdField: customerId,
        AppStrings.customerCodeField: customerCode,
        AppStrings.amountField: amount,
        AppStrings.statusField: AppStrings.pending,
      });

      await loadEntries();
      ref.read(customerControllerProvider.notifier).refreshCustomers();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateEntryStatus(String entryId, String newStatus) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.client
          .from(AppStrings.entriesTable)
          .update({AppStrings.statusField: newStatus})
          .eq(AppStrings.idField, entryId);

      await loadEntries();
      ref.read(customerControllerProvider.notifier).refreshCustomers();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> approveEntry(String entryId) async {
    await updateEntryStatus(entryId, AppStrings.dbApproved);
  }

  Future<void> payEntry(String entryId) async {
    await updateEntryStatus(entryId, AppStrings.dbPaid);
  }
}
