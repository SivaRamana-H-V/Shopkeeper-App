import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:pulse_ledger/models/user_model.dart';
import 'package:pulse_ledger/services/firestore_service.dart';

/// Handles all Firebase Authentication flows:
///   1. Google Sign-In
///   2. Phone number OTP verification
///   3. Sign-Out
///
/// Business logic only — no BuildContext or UI concerns.
class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirestoreService? firestoreService,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestoreService = firestoreService ?? FirestoreService();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;
  final Logger _log = Logger();

  // ── Auth state ─────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  /// Initiates Google OAuth flow. Returns the signed-in [User] or throws.
  Future<User> signInWithGoogle() async {
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) throw Exception('Google sign-in cancelled');

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Create Firestore profile on first sign-in.
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestoreService.createUserProfile(
          UserModel(
            uid: user.uid,
            displayName: user.displayName ?? googleAccount.displayName ?? '',
            email: user.email ?? '',
            photoUrl: user.photoURL,
            role: UserRole.customer, // default role; changed on role-select
            createdAt: DateTime.now(),
          ),
        );
      }

      _log.i('Google sign-in success: ${user.uid}');
      return user;
    } catch (e) {
      _log.e('Google sign-in failed', error: e);
      rethrow;
    }
  }

  // ── Phone Verification ─────────────────────────────────────────────────────

  /// Sends OTP to [phoneNumber] (E.164 format, e.g. +919876543210).
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android — sign in immediately.
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _log.e('OTP verification failed', error: e);
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _log.i('OTP sent to $phoneNumber');
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _log.w('OTP auto-retrieval timeout');
        },
      );
    } catch (e) {
      _log.e('sendOtp error', error: e);
      onError(e.toString());
    }
  }

  /// Verifies the [smsCode] against [verificationId] and signs the user in.
  Future<User> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestoreService.createUserProfile(
          UserModel(
            uid: user.uid,
            displayName: user.displayName ?? 'Pulse User',
            email: user.email ?? '',
            phone: user.phoneNumber,
            role: UserRole.customer,
            createdAt: DateTime.now(),
          ),
        );
      }

      _log.i('Phone sign-in success: ${user.uid}');
      return user;
    } catch (e) {
      _log.e('verifySmsCode failed', error: e);
      rethrow;
    }
  }

  // ── Sign-Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      _log.i('User signed out');
    } catch (e) {
      _log.e('Sign-out error', error: e);
      rethrow;
    }
  }
}
