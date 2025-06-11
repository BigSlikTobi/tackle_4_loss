/// Global design tokens for consistent styling across the app.
/// Includes color, spacing, radii, and typography constants.

import 'package:flutter/material.dart';

class DesignColors {
  static const Color primaryGreen = Color(0xFF20452B);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);

  // Additional neutrals and semantic colors
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  static const Color red700 = Color(0xFFD32F2F);
  static const Color orange800 = Color(0xFFEF6C00);
  static const Color amber800 = Color(0xFFFF8F00);
  static const Color green700 = Color(0xFF388E3C);
  static const Color blue700 = Color(0xFF1976D2);

  static const Color textPrimary = darkGrey;
  static const Color textSecondary = Color(0xFF666666);
  static const Color backgroundLight = white;
  static const Color surfaceLight = white;
  static const Color dividerLight = Color(0xFFEEEEEE);
}

class FontSizes {
  static const double xs = 11;
  static const double sm = 13;
  static const double md = 15;
  static const double lg = 17;
  static const double xl = 20;
  static const double xxl = 24;
  static const double headline = 28;
}

class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class Radii {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
}

class Elevations {
  static const double none = 0;
  static const double level1 = 1;
}
