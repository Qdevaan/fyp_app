import 'package:flutter/material.dart';

/// Design-system colors matching the Stitch UI mockups.
class AppColors {
  // Primary
  static const Color primary = Color(0xFF13A4EC);
  static const Color primaryDark = Color(0xFF0B8BC9);
  static const Color primaryLight = Color(0xFF6ECBF5);

  // Backgrounds
  static const Color backgroundDark = Color(0xFF101C22);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  // Surfaces (cards / panels)
  static const Color surfaceDark = Color(0xFF192B33);
  static const Color surfaceDarkHighlight = Color(0xFF233C48);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Chat bubbles
  static const Color bubbleDark = Color(0xFF1C2A33);
  static const Color bubbleUser = Color(0x1A13A4EC); // 10% primary

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8); // slate-400
  static const Color textMuted = Color(0xFF64748B);     // slate-500

  // Accents
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 9999;
}

class AppSpacing {
  static const double xs = 6;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

class AppTypography {
  static TextStyle title(BuildContext context) => Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold);
  static TextStyle label(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600);
}
