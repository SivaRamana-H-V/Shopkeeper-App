import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';
import 'package:pulse_ledger/controllers/role_provider.dart';
import 'package:pulse_ledger/models/user_model.dart';

class RoleSelectState {
  final UserRole? selectedRole;
  final bool isProfileFormVisible;
  final bool isLoading;
  final String? errorMessage;

  RoleSelectState({
    this.selectedRole,
    this.isProfileFormVisible = false,
    this.isLoading = false,
    this.errorMessage,
  });

  RoleSelectState copyWith({
    UserRole? selectedRole,
    bool? isProfileFormVisible,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RoleSelectState(
      selectedRole: selectedRole ?? this.selectedRole,
      isProfileFormVisible: isProfileFormVisible ?? this.isProfileFormVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RoleSelectController extends Notifier<RoleSelectState> {
  @override
  RoleSelectState build() => RoleSelectState();

  void selectRole(UserRole role) {
    state = state.copyWith(
      selectedRole: role,
      isProfileFormVisible: true,
    );
  }

  void goBackToRoleSelection() {
    state = state.copyWith(
      isProfileFormVisible: false,
    );
  }

  Future<bool> completeProfile({
    required String name,
    required String email,
  }) async {
    if (name.length < 3) {
      state =
          state.copyWith(errorMessage: 'Name must be at least 3 characters');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      state =
          state.copyWith(errorMessage: 'Please enter a valid email address');
      return false;
    }

    if (state.selectedRole == null) {
      state = state.copyWith(errorMessage: 'Please select a role');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authUser = ref.read(authControllerProvider).value;
      if (authUser == null) throw Exception('No authenticated user found');

      final userModel = UserModel(
        uid: authUser.uid,
        displayName: name,
        email: email,
        phone: authUser.phoneNumber,
        photoUrl: authUser.photoURL,
        role: state.selectedRole!,
        createdAt: DateTime
            .now(), // Will be overwritten by FieldValue.serverTimestamp() in toFirestore
      );

      await ref.read(firestoreServiceProvider).createUserProfile(userModel);

      // Invalidate currentUserProvider to trigger navigation in RoleSelectView or similar
      ref.invalidate(currentUserProvider);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final roleSelectControllerProvider =
    NotifierProvider<RoleSelectController, RoleSelectState>(() {
  return RoleSelectController();
});
