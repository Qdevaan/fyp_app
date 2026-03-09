import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
//  Bubbles Design Tokens — Glassmorphism UI System v2.0
// ============================================================

class BubblesColors {
  BubblesColors._();

  static const primary = Color(0xFF13bdec);
  static const primaryDark = Color(0xFF0B8BC9);
  static const bgDark = Color(0xFF101e22);
  static const bgLight = Color(0xFFF6F8F8);

  // Glass surfaces
  static const glassDark = Color(0x08FFFFFF);
  static const glassBorderDark = Color(0x14FFFFFF);
  static const glassHeaderDark = Color(0xB3101E22);
  static const glassHeaderBorderDark = Color(0x1A13BDEC);

  static const glassLight = Color(0x80FFFFFF);
  static const glassBorderLight = Color(0xCCFFFFFF);

  // Glass primary tint
  static const glassPrimary = Color(0x2613BDEC);
  static const glassPrimaryBorder = Color(0x4D13BDEC);

  // Text dark
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textMutedDark = Color(0xFF64748B);

  // Text light
  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF475569);
  static const textMutedLight = Color(0xFF94A3B8);

  // Status
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const indigo = Color(0xFF6366F1);
  static const purple = Color(0xFFA855F7);
  static const rose = Color(0xFFF43F5E);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

class BubblesTheme {
  BubblesTheme._();

  static TextTheme _buildTextTheme(Color primary, Color secondary, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(fontSize: 30, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.5),
      displaySmall: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
      headlineSmall: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: primary),
      titleMedium: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w500, color: primary, height: 1.5),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: secondary, height: 1.5),
      bodySmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: muted),
      labelLarge: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: primary, letterSpacing: 1.2),
      labelMedium: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.0),
      labelSmall: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.5),
    );
  }

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: BubblesColors.primary,
      onPrimary: BubblesColors.bgDark,
      surface: BubblesColors.bgDark,
      onSurface: BubblesColors.textPrimaryDark,
      error: BubblesColors.error,
    ),
    scaffoldBackgroundColor: BubblesColors.bgDark,
    textTheme: _buildTextTheme(
      BubblesColors.textPrimaryDark,
      BubblesColors.textSecondaryDark,
      BubblesColors.textMutedDark,
    ),
    iconTheme: const IconThemeData(color: BubblesColors.textSecondaryDark, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: BubblesColors.textPrimaryDark),
      iconTheme: const IconThemeData(color: BubblesColors.textPrimaryDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      hintStyle: GoogleFonts.manrope(color: BubblesColors.textMutedDark, fontWeight: FontWeight.w500),
    ),
    dividerColor: BubblesColors.glassBorderDark,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: BubblesColors.primary,
      onPrimary: Colors.white,
      surface: BubblesColors.bgLight,
      onSurface: BubblesColors.textPrimaryLight,
      error: BubblesColors.error,
    ),
    scaffoldBackgroundColor: BubblesColors.bgLight,
    textTheme: _buildTextTheme(
      BubblesColors.textPrimaryLight,
      BubblesColors.textSecondaryLight,
      BubblesColors.textMutedLight,
    ),
    iconTheme: const IconThemeData(color: BubblesColors.textSecondaryLight, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: BubblesColors.textPrimaryLight),
      iconTheme: const IconThemeData(color: BubblesColors.textPrimaryLight),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      hintStyle: GoogleFonts.manrope(color: BubblesColors.textMutedLight, fontWeight: FontWeight.w500),
    ),
    dividerColor: BubblesColors.glassBorderLight,
  );
}

// ============================================================
//  Compatibility aliases — used by ThemeProvider
// ============================================================

class AppColors {
  AppColors._();
  static const primary = BubblesColors.primary;
  static const slate900 = Color(0xFF0F172A);
  static const slate200 = Color(0xFFE2E8F0);
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceDark = Color(0xFF1E293B);
  static const backgroundLight = BubblesColors.bgLight;
  static const backgroundDark = BubblesColors.bgDark;
  static const glassWhite = Color(0x0DFFFFFF);
  static const glassBorder = BubblesColors.glassBorderDark;
  static const glassInput = Color(0x10FFFFFF);
}

class AppRadius {
  AppRadius._();
  static const double xxl = 24.0;
  static const double lg = 12.0;
  static const double full = 999.0;
}
