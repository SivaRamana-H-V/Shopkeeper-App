import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/models/entry_model.dart';
import 'package:shopkeeper_app/services/supabase_service.dart';
import 'package:shopkeeper_app/controllers/ledger_state.dart';
import 'package:shopkeeper_app/controllers/customer_controller.dart';

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

      // 3. Fetch Customer Details (only if not already in state)
      String? currentCode;
      String? currentName;
      if (state.hasValue) {
        currentCode = state.value!.customerCode;
        currentName = state.value!.customerName;
      }

      if (currentCode == null || currentName == null) {
        final customerRes = await SupabaseService.client
            .from(AppStrings.customersTable)
            .select('${AppStrings.customerCodeField}, ${AppStrings.nameField}')
            .eq(AppStrings.idField, customerId)
            .single();
        currentCode = customerRes[AppStrings.customerCodeField] as String;
        currentName = customerRes[AppStrings.nameField] as String;
      }

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
    try {
      // We need the code to insert
      if (!state.hasValue || state.value!.customerCode == null) {
        // This shouldn't happen if loadEntries finished, but for safety:
        await loadEntries();
      }

      final customerCode = state.value!.customerCode!;

      state = const AsyncValue.loading();

      await SupabaseService.client.from(AppStrings.entriesTable).insert({
        AppStrings.customerIdField: customerId,
        AppStrings.customerCodeField: customerCode,
        AppStrings.amountField: amount,
        AppStrings.statusField: AppStrings.pending,
      });

      await loadEntries();

      // Refresh customer list to update totals
      await ref.read(customerControllerProvider.notifier).refreshCustomers();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
