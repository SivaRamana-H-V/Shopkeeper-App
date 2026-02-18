import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'package:shopkeeper_app/shopkeeper/views/auth/login_view.dart';
import 'package:shopkeeper_app/shopkeeper/views/auth/register_view.dart';
import 'package:shopkeeper_app/shopkeeper/views/customers/customer_list_view.dart';
import 'package:shopkeeper_app/shopkeeper/views/customers/add_customer_view.dart';
import 'package:shopkeeper_app/shopkeeper/views/ledger/ledger_view.dart';
import 'package:shopkeeper_app/shopkeeper/views/ledger/add_entry_view.dart';
import 'package:shopkeeper_app/shopkeeper/views/auth/role_selection_view.dart';
import 'package:shopkeeper_app/customer/views/auth/customer_login_view.dart';
import 'package:shopkeeper_app/customer/views/customer_home_view.dart';
import 'package:shopkeeper_app/shopkeeper/core/auth_session.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: _getInitialLocation(),

    routes: [
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionView(),
      ),

      GoRoute(
        path: AppRoutes.customerLogin,
        builder: (context, state) => const CustomerLoginView(),
      ),

      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeView(),
      ),

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
    ],
  );

  static String _getInitialLocation() {
    if (AuthSession.role == null) {
      return AppRoutes.roleSelection;
    }

    if (AuthSession.role == 'customer') {
      if (AuthSession.customerPhone == null) {
        return AppRoutes.customerLogin;
      }
      return AppRoutes.customerHome;
    }

    // Role is shopkeeper
    if (AuthSession.shopkeeperId != null) {
      return AppRoutes.customers;
    }

    return AppRoutes.login;
  }
}
