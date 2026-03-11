import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

class UpiService {
  static final _logger = Logger();

  /// Launches a UPI payment app using a deep link.
  ///
  /// [upiId] - The recipient's UPI ID (e.g., recipient@upi).
  /// [name] - The name of the recipient/business.
  /// [amount] - The transaction amount.
  static Future<void> launchUpiPayment({
    required String upiId,
    required String name,
    required double amount,
  }) async {
    // Construct the UPI URI string exactly as specified with robust fallback for 'pn'
    final encodedName =
        Uri.encodeComponent(name.isNotEmpty ? name : 'Pulse Shop');
    final url =
        'upi://pay?pa=$upiId&pn=$encodedName&am=${amount.toStringAsFixed(2)}&cu=INR&tn=Pulse%20Ledger%20Settlement';

    final uri = Uri.parse(url);

    try {
      // On some Android 11+ devices, canLaunchUrl returns false for 'upi://'
      // even with queries. We try to launch anyway and catch the platform exception.
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(
            'Could not launch UPI payment app. Please ensure a UPI app is installed.');
      }
    } catch (e) {
      _logger.e('Error launching UPI payment: $e');
      rethrow;
    }
  }
}
