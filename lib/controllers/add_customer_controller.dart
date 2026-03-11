import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:pulse_ledger/services/contact_service.dart';

final contactServiceProvider = Provider((ref) => ContactService());

final pulseNetworkProvider = FutureProvider<List<UserModel>>((ref) async {
  final service = ref.watch(contactServiceProvider);
  final localContacts = await service.getLocalContacts();
  return await service.syncMatchedUsers(localContacts);
});

class AddCustomerState {
  const AddCustomerState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final Object? error;

  AddCustomerState copyWith({
    bool? isLoading,
    Object? error,
  }) =>
      AddCustomerState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AddCustomerController extends StateNotifier<AddCustomerState> {
  AddCustomerController(this.ref) : super(const AddCustomerState());

  final Ref ref;

  Future<String?> addToLedger(UserModel customer) async {
    if (state.isLoading) {
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Wait for the actual Auth state and Profile to be ready
      final currentUserModel = await ref.read(currentUserProvider.future);

      if (currentUserModel == null) {
        return null;
      }

      final firestoreService = ref.read(firestoreServiceProvider);

      // getOrCreateChat handles forcing a merge write
      final chatId = await firestoreService.getOrCreateChat(
        shopId: currentUserModel.uid,
        shopName: currentUserModel.shopName ?? currentUserModel.displayName,
        customerId: customer.uid,
        customerName: customer.displayName,
      );

      return chatId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final addCustomerControllerProvider =
    StateNotifierProvider<AddCustomerController, AddCustomerState>((ref) {
  return AddCustomerController(ref);
});
