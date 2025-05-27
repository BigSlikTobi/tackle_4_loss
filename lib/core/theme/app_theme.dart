// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart'; // Import your colors

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
          fontSize: 18.0, // Adjust size as needed
          fontWeight:
              FontWeight
                  .w600, // Medium weight (SF Pro Text Semibold equivalent)
        ),
      ),

      // Text Theme - Define default text styles
      // Consider using google_fonts package for more font options later
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        // Titles
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ), // Semibold
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ), // Semibold
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ), // Semibold
        // Body Text
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          height: 1.4,
        ), // Slightly larger body
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ), // Standard body
        bodySmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.3,
        ), // Secondary/caption text
        // Labels (for buttons etc.)
        labelLarge: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ), // Button text
        labelMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 1.0, // Subtle elevation
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent, // Avoid M3 tinting if not desired
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ), // Rounded corners
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ), // Default margin
      ),

      // Chip Theme (useful for status tags)
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200], // Default background
        labelStyle: TextStyle(color: AppColors.textPrimary, fontSize: 11),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen, // Primary action color
          foregroundColor: AppColors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen, // Link color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      // Input Decoration Theme (for TextFields later)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
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
