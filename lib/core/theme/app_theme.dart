import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pulse design tokens and ThemeData factory.
class AppTheme {
  AppTheme._();

  // ── Brand colours ────────────────────────────────────────────────────────
  static const Color royalPurple = Color(0xFF6200EE);
  static const Color royalPurpleLight = Color(0xFF9D46FF);
  static const Color royalPurpleDark = Color(0xFF3700B3);
  static const Color amberGold = Color(0xFFFFC107);
  static const Color amberGoldDark = Color(0xFFFFA000);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceCard = Color(0xFF16213E);
  static const Color onSurfaceLight = Color(0xFFEEEEEE);
  static const Color onSurfaceMuted = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFF2A2A3D);

  // ── Chat bubble colours ──────────────────────────────────────────────────
  static const Color bubbleSent = royalPurple;
  static const Color bubbleReceived = Color(0xFF252540);

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme() => GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.outfit(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            color: onSurfaceLight,
          ),
          displayMedium: GoogleFonts.outfit(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: onSurfaceLight,
          ),
          headlineLarge: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: onSurfaceLight,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurfaceLight,
          ),
          titleLarge: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: onSurfaceLight,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: onSurfaceLight,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: onSurfaceLight,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: onSurfaceLight,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: onSurfaceMuted,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      );

  // ── Dark Theme (primary) ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: royalPurple,
        onPrimary: Colors.white,
        primaryContainer: royalPurpleDark,
        secondary: amberGold,
        onSecondary: Colors.black,
        secondaryContainer: amberGoldDark,
        surface: surfaceDark,
        onSurface: onSurfaceLight,
        error: Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: bgDark,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: onSurfaceLight),
        titleTextStyle: textTheme.titleLarge,
      ),

      // ElevatedButton → Pulse primary CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 4,
        ),
      ),

      // OutlinedButton → secondary actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: royalPurple,
          side: const BorderSide(color: royalPurple, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: royalPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceMuted),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: royalPurpleLight,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amberGold,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceCard,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Chip (role badges, etc.)
      chipTheme: ChipThemeData(
        backgroundColor: surfaceCard,
        selectedColor: royalPurple,
        labelStyle: textTheme.labelLarge,
        side: const BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
