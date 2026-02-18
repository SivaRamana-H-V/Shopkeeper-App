class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException() : super("No Internet Connection");
}

class AuthException extends AppException {
  AuthException() : super("Invalid Credentials");
}

class DatabaseException extends AppException {
  DatabaseException() : super("Database Error");
}
