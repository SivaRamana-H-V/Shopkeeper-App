import 'package:flutter/material.dart';
import 'package:pulse_ledger/core/router/route_generator.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Use the centralized RouteGenerator for ALL navigation
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
