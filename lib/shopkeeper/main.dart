import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopkeeper_app/shopkeeper/core/constants/app_strings.dart';
import 'services/supabase_service.dart';
import 'app.dart';
import 'core/auth_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  // Hive Init
  await Hive.initFlutter();
  final sessionBox = await Hive.openBox(AppStrings.sessionBox);

  // Restore Session
  AuthSession.shopkeeperId = sessionBox.get(AppStrings.shopkeeperId) as String?;
  AuthSession.shopName = sessionBox.get(AppStrings.shopName) as String?;
  AuthSession.role = sessionBox.get('role') as String?;
  AuthSession.customerPhone = sessionBox.get('customerPhone') as String?;

  runApp(const ProviderScope(child: MyApp()));
}
