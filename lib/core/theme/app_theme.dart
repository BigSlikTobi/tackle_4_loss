// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/theme/design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Primary defines the main branding elements
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen, // Generate scheme from your green
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white, // Text/icons on primary color
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimary,
        // You can override other colors like secondary, error etc. if needed
      ),

      // Scaffold Background
      scaffoldBackgroundColor: const Color.fromARGB(255, 248, 247, 247),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen, // Green background
        foregroundColor: AppColors.white, // White icons and title
        elevation: 0, // Flat app bar (Apple style)
        centerTitle:
            false, // iOS often uses centered titles, but false is common too
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: FontSizes.xl,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Text Theme - Define default text styles
      // Consider using google_fonts package for more font options later
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: FontSizes.headline,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: FontSizes.xxl,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: FontSizes.xl,
        ),
        // Titles
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: FontSizes.xl,
        ), // Semibold
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: FontSizes.lg,
        ), // Semibold
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: FontSizes.md,
        ), // Semibold
        // Body Text
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: FontSizes.lg,
          height: 1.4,
        ), // Slightly larger body
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: FontSizes.md,
          height: 1.4,
        ), // Standard body
        bodySmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: FontSizes.sm,
          height: 1.3,
        ), // Secondary/caption text
        // Labels (for buttons etc.)
        labelLarge: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: FontSizes.lg,
        ), // Button text
        labelMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: FontSizes.xs,
        ),
        labelSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: FontSizes.xs,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: Elevations.level1,
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(Radii.lg),
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
      ),

      // Chip Theme (useful for status tags)
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200],
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: FontSizes.xs,
        ),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.md,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen, // Link color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),

      // Input Decoration Theme (for TextFields later)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          vertical: Spacing.md,
          horizontal: Spacing.lg,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1, // Minimal space usually
      ),

      // Add other widget themes as needed...
    );
  }

  // Define darkTheme later if needed
  // static ThemeData get darkTheme { ... }
}
