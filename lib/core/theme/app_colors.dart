import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFFE11D48);
  static const Color primaryGradientStart = Color(0xFFF43F5E);
  static const Color primaryGradientEnd = Color(0xFF9F1239);
  static const Color secondary = Color(0xFF1F2937);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFF1F2);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);

  // Helper for input fields (from JSON)
  static const Color inputFill = Color(0xFFF4F6F8);

  // Keep these for compatibility if needed, but mapped to new palette
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightText = textPrimary;

  static const Color darkBackground = Color(
    0xFF121212,
  ); // Dark mode wasn't fully specified in JSON palette, assuming standard dark
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFE0E0E0);
}
