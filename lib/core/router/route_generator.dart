import 'package:flutter/material.dart';
import 'package:pulse_ledger/views/auth/login_view.dart';
import 'package:pulse_ledger/views/auth/otp_verification_view.dart';
import 'package:pulse_ledger/views/chat/chat_view.dart';
import 'package:pulse_ledger/views/home/home_view.dart';
import 'package:pulse_ledger/views/profile/profile_view.dart';
import 'package:pulse_ledger/views/role/role_select_view.dart';
import 'package:pulse_ledger/views/home/add_customer_view.dart';
import 'package:pulse_ledger/views/splash/splash_view.dart';

/// All named route constants for Pulse.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const otpVerify = '/otp-verify';
  static const roleSelect = '/role-select';
  static const home = '/home';
  static const chat = '/chat';
  static const addCustomer = '/add-customer';
  static const profile = '/profile';
}

/// Centralised route factory. The [MaterialApp] uses this exclusively via
/// `onGenerateRoute`. No inline routing is permitted anywhere else.
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Splash ─────────────────────────────────────────────────────────────
      case AppRoutes.splash:
        return _fadeRoute(const SplashView(), settings);

      // ── Auth ───────────────────────────────────────────────────────────────
      case AppRoutes.login:
        return _slideRoute(const LoginView(), settings);

      case AppRoutes.otpVerify:
        final args = settings.arguments as Map<String, dynamic>;
        return _slideRoute(
          OtpVerificationView(
            verificationId: args['verificationId'] as String,
            phoneNumber: args['phoneNumber'] as String,
          ),
          settings,
        );

      // ── Role ───────────────────────────────────────────────────────────────
      case AppRoutes.roleSelect:
        return _slideRoute(const RoleSelectView(), settings);

      // ── App shell ─────────────────────────────────────────────────────────
      case AppRoutes.home:
        return _fadeRoute(const HomeView(), settings);

      case AppRoutes.chat:
        final args = settings.arguments as Map<String, dynamic>;
        return _slideRoute(
          ChatView(
            chatId: args['chatId'] as String,
            participantName: args['participantName'] as String,
          ),
          settings,
        );

      case AppRoutes.addCustomer:
        return _slideRoute(const AddCustomerView(), settings);

      case AppRoutes.profile:
        return _slideRoute(const ProfileView(), settings);

      // ── 404 ───────────────────────────────────────────────────────────────
      default:
        return _errorRoute(settings);
    }
  }

  // ── Route helpers ──────────────────────────────────────────────────────────

  static PageRouteBuilder<dynamic> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static PageRouteBuilder<dynamic> _slideRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static MaterialPageRoute<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
