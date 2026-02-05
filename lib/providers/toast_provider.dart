import 'package:flutter_riverpod/legacy.dart';

enum ToastType { success, error, info }

class ToastMessage {
  final String message;
  final ToastType type;

  ToastMessage(this.message, this.type);
}

class ToastNotifier extends StateNotifier<ToastMessage?> {
  ToastNotifier() : super(null);

  void showSuccess(String msg) {
    state = ToastMessage(msg, ToastType.success);
  }

  void showError(String msg) {
    state = ToastMessage(msg, ToastType.error);
  }

  void showInfo(String msg) {
    state = ToastMessage(msg, ToastType.info);
  }

  void clear() {
    state = null;
  }
}

final toastProvider = StateNotifierProvider<ToastNotifier, ToastMessage?>(
  (ref) => ToastNotifier(),
);
