import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'providers/toast_provider.dart';
import 'core/ui/toast_service.dart';
import 'core/router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isDark = ref.watch(themeProvider);

    ref.listen(
      toastProvider,
      (prev, next) {
        if (next != null) {
          ToastService.show(context, next);
          ref.read(toastProvider.notifier).clear();
        }
      },
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
