import 'package:flutter/material.dart';

/// Extension methods for [ColorScheme]
extension ColorSchemeExtension on ColorScheme {
  /// Returns the surface color with specified opacity
  /// This is a custom method to provide functionality similar to withOpacity
  Color withValues(double opacity) {
    return surface.withOpacity(opacity);
  }
}
