class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String customers = '/customers';
  static const String addCustomer = '$customers/add';
  static const String ledger = '/ledger';
  static const String addEntry = '$ledger/add-entry';

  static const String customersAdd = 'add';
  static const String ledgerAddEntry = 'add-entry';

  // Parameters
  static const String ledgerCustomerKey = 'customerId';
  static const String ledgerCustomerParam = ':customerId';

  // Full paths with params for Router
  static const String ledgerWithParam = '$ledger/:customerId';
  static const String customerWebBase = '/c';
  static const String customerLedgerWeb = '$customerWebBase/:token';

  // Navigation Helpers (to avoid slashes in UI)
  static String ledgerDetail(String customerId) => '$ledger/$customerId';
  static String addEntryTo(String customerId) =>
      '$ledger/$customerId/$ledgerAddEntry';
  static String customerWebPath(String token) => '$customerWebBase/$token';
}
