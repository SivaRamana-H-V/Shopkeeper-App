import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'package:shopkeeper_app/views/auth/login_view.dart';
import 'package:shopkeeper_app/views/auth/register_view.dart';
import 'package:shopkeeper_app/views/customers/customer_list_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.login,

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),

      GoRoute(
        path: AppRoutes.customers,
        builder: (context, state) => const CustomerListView(),
      ),
    ],
  );
}
