import 'package:flutter/material.dart';
import 'package:shopkeeper_app/providers/toast_provider.dart';
import '../global_keys.dart';

class ToastService {
  static void show(ToastMessage toast) {
    Color bgColor;

    switch (toast.type) {
      case ToastType.success:
        bgColor = Colors.green;
        break;
      case ToastType.error:
        bgColor = Colors.red;
        break;
      case ToastType.info:
        bgColor = Colors.blue;
        break;
    }

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(toast.message),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
