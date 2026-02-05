import 'package:flutter/material.dart';
import 'package:shopkeeper_app/providers/toast_provider.dart';

class ToastService {
  static void show(BuildContext context, ToastMessage toast) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(toast.message), backgroundColor: bgColor),
    );
  }
}
