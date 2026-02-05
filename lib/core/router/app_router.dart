import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'package:shopkeeper_app/views/auth/login_view.dart';
import 'package:shopkeeper_app/views/auth/register_view.dart';
import 'package:shopkeeper_app/views/customers/customer_list_view.dart';
import 'package:shopkeeper_app/views/customers/add_customer_view.dart';
import 'package:shopkeeper_app/views/ledger/ledger_view.dart';
import 'package:shopkeeper_app/views/ledger/add_entry_view.dart';

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
        routes: [
          GoRoute(
            path: 'add', // /customers/add
            builder: (context, state) => const AddCustomerView(),
          ),
        ],
      ),

      GoRoute(
        path: '${AppRoutes.ledger}/:customerId',
        builder: (context, state) =>
            LedgerView(customerId: state.pathParameters['customerId']!),
        routes: [
          GoRoute(
            path: 'add-entry', // /ledger/add-entry
            builder: (context, state) => const AddEntryView(),
          ),
        ],
      ),
    ],
  );
}
