class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String customers = '/customers';
  static const String addCustomer = '$customers/add';
  static const String ledger = '/ledger';
  static const String addEntry = '$ledger/add-entry';

  static const String roleSelection = '/role-selection';
  static const String customerLogin = '/customer-login';
  static const String customerHome = '/customer-home';

  static const String customersAdd = 'add';
  static const String ledgerAddEntry = 'add-entry';

  // Parameters
  static const String ledgerCustomerKey = 'customerId';
  static const String ledgerCustomerParam = ':customerId';

  // Full paths with params for Router
  static const String ledgerWithParam = '$ledger/:customerId';
  // Navigation Helpers (to avoid slashes in UI)
  static String ledgerDetail(String customerId) => '$ledger/$customerId';
  static String addEntryTo(String customerId) =>
      '$ledger/$customerId/$ledgerAddEntry';
}
