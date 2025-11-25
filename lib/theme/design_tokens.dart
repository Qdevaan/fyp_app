
import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
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
