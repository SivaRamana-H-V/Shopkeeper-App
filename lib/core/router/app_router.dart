import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'package:shopkeeper_app/views/auth/login_view.dart';
import 'package:shopkeeper_app/views/auth/register_view.dart';
import 'package:shopkeeper_app/views/customers/customer_list_view.dart';
import 'package:shopkeeper_app/views/customers/add_customer_view.dart';
import 'package:shopkeeper_app/views/ledger/ledger_view.dart';
import 'package:shopkeeper_app/views/ledger/add_entry_view.dart';
import 'package:shopkeeper_app/web_customer/views/customer_ledger_web_view.dart';
import 'package:shopkeeper_app/web_customer/views/web_portal_view.dart';
import 'package:shopkeeper_app/core/auth_session.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: kIsWeb
        ? AppRoutes.customerWebBase
        : (AuthSession.shopkeeperId != null
              ? AppRoutes.customers
              : AppRoutes.login),

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
            path: AppRoutes.customersAdd, // /customers/add
            builder: (context, state) => const AddCustomerView(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.ledgerWithParam,
        builder: (context, state) => LedgerView(
          customerId: state.pathParameters[AppRoutes.ledgerCustomerKey]!,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.ledgerAddEntry, // /ledger/add-entry
            builder: (context, state) => AddEntryView(
              customerId: state.pathParameters[AppRoutes.ledgerCustomerKey]!,
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.customerWebBase,
        builder: (context, state) => const WebPortalView(),
        routes: [
          GoRoute(
            path: ':token',
            builder: (context, state) {
              final token = state.pathParameters['token']!;
              return CustomerLedgerWebView(token: token);
            },
          ),
        ],
      ),
    ],
  );
}
