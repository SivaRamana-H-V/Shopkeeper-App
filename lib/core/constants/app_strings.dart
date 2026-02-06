class AppStrings {
  static const String appName = "Nanjil Pay - Shopkeeper";
  static const String loginTitle = "Login";
  static const String registerTitle = "Register";
  static const String customersTitle = "Customers";
  static const String ledgerTitle = "Ledger";
  static const String addCustomerTitle = "Add Customer";
  static const String addEntryTitle = "Add Entry";

  static const String username = "Username";
  static const String password = "Password";
  static const String shopName = "Shop Name";
  static const String customerName = "Customer Name";
  static const String phoneNumber = "Phone Number";
  static const String amount = "Amount";

  static const String loginButton = "Login";
  static const String registerLink = "New User? Register";
  static const String createAccount = "Create Account";

  static const String saveCustomer = "Save Customer";
  static const String saveEntry = "Save Entry";

  static const String searchHint = "Search customer";
  static const String totalCustomers = "Total Customers";
  static const String totalOutstanding = "Total Outstanding";
  static const String totalDue = "Total Due";

  // Session and Hive
  static const String sessionBox = "sessionBox";
  static const String customerBox = "customer";
  static const String entryBox = "entry";
  static const String shopkeeperId = "shopkeeperId";

  // Supabase
  static const String supabaseUrl = 'https://mpwtobxkftamchjjoong.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_Ct4xLzSpXrkQjdNlwEGTcA_1DgRV7on';
  static const String shopkeepersTable = 'shopkeepers';
  static const String customersTable = 'customers';
  static const String entriesTable = 'entries';

  static const String userNameField = 'username';
  static const String passwordField = 'password';
  static const String shopNameField = 'shop_name';
  static const String idField = 'id';
  static const String customerIdField = 'customer_id';
  static const String amountField = 'amount';
  static const String statusField = 'status';
  static const String createdAtField = 'created_at';
  static const String updatedAtField = 'updated_at';
  static const String tokenField = 'token';
  static const String customerCodeField = 'customer_code';
  static const String shopkeeperIdField = 'shopkeeper_id';
  static const String nameField = 'name';
  static const String phoneField = 'phone';
  static const String disputed = 'disputed';
  static const String tokenChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static const String codePrefix = 'CUST-';
  static const String pending = 'pending';

  static const String success = 'success';
  static const String error = 'wrong_password';
  static const String userNotFound = 'user_not_found';
  static const String usernameExists = 'username_exists';

  // Login & Register (New additions)
  static const String registerButton = "Create Account";
  static const String usernameHint = "Enter Username";
  static const String passwordHint = "Enter Password";
  static const String shopNameHint = "Enter Shop Name";

  // Toasts
  static const String toastLoginSuccess = "Login Successful!";
  static const String toastLoginFailed = "Login Failed. Please try again.";
  static const String toastUserNotFound = "User not found";
  static const String toastWrongPassword = "Wrong password";
  static const String toastRegisterSuccess =
      "Registration Successful! Please Login.";
  static const String toastRegisterFailed =
      "Registration Failed. Please try again.";
  static const String toastUsernameExists = "Username already exists";
  static const String validationError = "Please fill all fields";

  static const String emptyCustomerList = "No customers found";
  static const String toastFetchFailed = "Failed to load customers";

  static const String invalidAmount = "Please enter a valid amount";
  static const String emptyAmount = "Amount cannot be empty";

  // Entry Status
  static const String approve = "Approve";
  static const String dispute = "Dispute";
  static const String statusApproved = "Approved";
  static const String statusDisputed = "Disputed";
  static const String statusPending = "Pending";

  // Web Customer
  static const String noEntries = "No transactions found";

  // Sharing
  static const String shareViaWhatsapp = "WhatsApp Share";
  static const String copyLink = "Copy Link";
  static const String linkCopied = "Link copied";
  static const String whatsappNotAvailable = "WhatsApp not installed";
  static const String shareFailed = "Share failed";
}
