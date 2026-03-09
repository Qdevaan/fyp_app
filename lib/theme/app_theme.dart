import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
//  Bubbles Design Tokens — Glassmorphism UI System v2.0
// ============================================================

class BubblesColors {
  BubblesColors._();

  // Brand
  static const primary = Color(0xFF13bdec);
  static const primaryDark = Color(0xFF0B8BC9);

  // Backgrounds
  static const bgDark = Color(0xFF101e22);
  static const bgLight = Color(0xFFF6F8F8);

  // Glass (Dark Mode)
  static const glassDark = Color(0x08FFFFFF);       // rgba(255,255,255,0.03)
  static const glassBorderDark = Color(0x14FFFFFF);  // rgba(255,255,255,0.08)
  static const glassHeaderDark = Color(0xB3101E22);  // rgba(16,30,34,0.70)

  // Glass Primary Tint
  static const glassPrimary = Color(0x2613BDEC);     // rgba(19,189,236,0.15)
  static const glassPrimaryBorder = Color(0x4D13BDEC); // rgba(19,189,236,0.30)

  // Text (Dark Mode)
  static const textPrimaryDark = Color(0xFFF1F5F9);  // slate-100
  static const textSecondaryDark = Color(0xFF94A3B8); // slate-400
  static const textMutedDark = Color(0xFF64748B);     // slate-500

  // Text (Light Mode)
  static const textPrimaryLight = Color(0xFF0F172A);  // slate-900
  static const textSecondaryLight = Color(0xFF475569); // slate-600
  static const textMutedLight = Color(0xFF94A3B8);    // slate-400

  // Status
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF818CF8);

  // Special
  static const transparent = Colors.transparent;
}

class BubblesTheme {
  BubblesTheme._();

  static TextTheme _buildTextTheme(Color primary, Color secondary, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 30, fontWeight: FontWeight.w800,
        color: primary, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 26, fontWeight: FontWeight.w800,
        color: primary, letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.manrope(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 15, fontWeight: FontWeight.w500,
        color: primary, height: 1.5,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: secondary, height: 1.5,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: primary, letterSpacing: 1.2,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: muted, letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: muted, letterSpacing: 1.5,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: BubblesColors.primary,
      onPrimary: BubblesColors.bgDark,
      surface: BubblesColors.bgDark,
      onSurface: BubblesColors.textPrimaryDark,
      error: BubblesColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BubblesColors.bgDark,
      textTheme: _buildTextTheme(
        BubblesColors.textPrimaryDark,
        BubblesColors.textSecondaryDark,
        BubblesColors.textMutedDark,
      ),
      iconTheme: const IconThemeData(color: BubblesColors.textSecondaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: BubblesColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: BubblesColors.textPrimaryDark),
      ),
      extensions: const [BubblesThemeExtension.dark],
    );
  }

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: BubblesColors.primary,
      onPrimary: Colors.white,
      surface: BubblesColors.bgLight,
      onSurface: BubblesColors.textPrimaryLight,
      error: BubblesColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BubblesColors.bgLight,
      textTheme: _buildTextTheme(
        BubblesColors.textPrimaryLight,
        BubblesColors.textSecondaryLight,
        BubblesColors.textMutedLight,
      ),
      iconTheme: const IconThemeData(color: BubblesColors.textSecondaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: BubblesColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: BubblesColors.textPrimaryLight),
      ),
      extensions: const [BubblesThemeExtension.light],
    );
  }
}

// Theme extension for glassmorphism values
class BubblesThemeExtension extends ThemeExtension<BubblesThemeExtension> {
  final Color glassBackground;
  final Color glassBorder;
  final Color meshBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final bool isDark;

  const BubblesThemeExtension({
    required this.glassBackground,
    required this.glassBorder,
    required this.meshBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.isDark,
  });

  static const dark = BubblesThemeExtension(
    glassBackground: Color(0x08FFFFFF),
    glassBorder: Color(0x14FFFFFF),
    meshBg: BubblesColors.bgDark,
    textPrimary: BubblesColors.textPrimaryDark,
    textSecondary: BubblesColors.textSecondaryDark,
    textMuted: BubblesColors.textMutedDark,
    isDark: true,
  );

  static const light = BubblesThemeExtension(
    glassBackground: Color(0x80FFFFFF),
    glassBorder: Color(0xCCFFFFFF),
    meshBg: BubblesColors.bgLight,
    textPrimary: BubblesColors.textPrimaryLight,
    textSecondary: BubblesColors.textSecondaryLight,
    textMuted: BubblesColors.textMutedLight,
    isDark: false,
  );

  @override
  ThemeExtension<BubblesThemeExtension> copyWith({
    Color? glassBackground, Color? glassBorder, Color? meshBg,
    Color? textPrimary, Color? textSecondary, Color? textMuted, bool? isDark,
  }) {
    return BubblesThemeExtension(
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      meshBg: meshBg ?? this.meshBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ThemeExtension<BubblesThemeExtension> lerp(
    covariant ThemeExtension<BubblesThemeExtension>? other, double t) {
    return this;
  }
}
