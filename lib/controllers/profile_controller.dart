import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pulse_ledger/controllers/auth_controller.dart';

/// State for the profile update process.
class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  final bool isLoading;
  final String? error;
  final bool success;

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState());

  final Ref ref;

  Future<void> updateProfile({
    required String name,
    String? businessName,
    String? upiId,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final updateData = {
        'displayName': name,
        if (businessName != null) 'businessName': businessName,
        if (upiId != null) 'upiId': upiId,
      };

      await ref.read(firestoreServiceProvider).updateUserProfile(
            uid: user.uid,
            data: updateData,
          );

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetStatus() {
    state = const ProfileState();
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});
