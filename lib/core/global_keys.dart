import 'package:flutter/material.dart';

/// Global key to access the root ScaffoldMessenger state
/// used for showing SnackBars/Toasts from anywhere in the app,
/// even outside the widget tree or above MaterialApp.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
