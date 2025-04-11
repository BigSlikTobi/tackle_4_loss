// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF20452B); // Your main brand color
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);

  // Define some shades for text or subtle elements (adjust as needed)
  static const Color textPrimary = darkGrey; // Or black for higher contrast
  static const Color textSecondary = Color(0xFF666666); // Lighter grey
  static const Color backgroundLight =
      white; // Or a very light grey like F8F8F8
  static const Color surfaceLight = white; // For cards, dialogs etc.
  static const Color dividerLight = Color(0xFFEEEEEE); // Subtle divider

  // Define Dark Mode colors later if needed
  // static const Color backgroundDark = black;
  // static const Color surfaceDark = darkGrey;
  // static const Color textPrimaryDark = white;
}
