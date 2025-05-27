import 'package:flutter/foundation.dart';

/// Environment configuration class that handles web vs mobile differences
class EnvironmentConfig {
  static const String _supabaseUrlWeb =
      'https://yqtiuzhedkfacwgormhn.supabase.co';
  static const String _supabaseAnonKeyWeb =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxdGl1emhlZGtmYWN3Z29ybWhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4NzcwMDgsImV4cCI6MjA1NzQ1MzAwOH0.h2FYangQNOdEJWq8ExWBABiphzoLObWcj5B9Z-uIgQc';

  /// Get Supabase URL based on platform
  static String? get supabaseUrl {
    if (kIsWeb) {
      // For web, we use compile-time constants
      // In production, you can set these via build-time variables
      return _supabaseUrlWeb;
    } else {
      // For mobile, we use the .env file approach
      return null; // Will be loaded from .env
    }
  }

  /// Get Supabase Anonymous Key based on platform
  static String? get supabaseAnonKey {
    if (kIsWeb) {
      // For web, we use compile-time constants
      return _supabaseAnonKeyWeb;
    } else {
      // For mobile, we use the .env file approach
      return null; // Will be loaded from .env
    }
  }

  /// Check if we should use environment config for the current platform
  static bool get shouldUseEnvironmentConfig {
    return !kIsWeb; // Only use .env for non-web platforms
  }

  /// Get configuration summary for debugging
  static Map<String, dynamic> get debugInfo {
    return {
      'platform': kIsWeb ? 'web' : 'mobile',
      'useEnvFile': shouldUseEnvironmentConfig,
      'supabaseUrlSource': kIsWeb ? 'compile-time' : 'env-file',
      'supabaseAnonKeySource': kIsWeb ? 'compile-time' : 'env-file',
    };
  }
}
