import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _betaBannerDismissedKey = 'betaBannerDismissed';

final betaBannerNotifierProvider =
    StateNotifierProvider<BetaBannerNotifier, bool>((ref) {
      return BetaBannerNotifier();
    });

class BetaBannerNotifier extends StateNotifier<bool> {
  SharedPreferences? _prefs;

  BetaBannerNotifier() : super(true) {
    // Default to showing the banner
    _initializeBannerState();
  }

  Future<void> _initializeBannerState() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Always show banner on app startup (reset any previous dismissal)
      await _prefs?.remove(_betaBannerDismissedKey);

      if (mounted) {
        state = true; // Always show on app startup
        debugPrint(
          "Beta banner initialized: visible (resets on each app start)",
        );
      }
    } catch (e) {
      debugPrint("Error initializing beta banner state: $e");
      if (mounted) {
        state = true; // Default to showing on error
      }
    }
  }

  Future<void> dismissBanner() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(_betaBannerDismissedKey, true);

      if (mounted) {
        state = false;
        debugPrint("Beta banner dismissed and preference saved");
      }
    } catch (e) {
      debugPrint("Error saving beta banner dismissal: $e");
    }
  }

  // Method to reset banner (useful for testing or if needed)
  Future<void> resetBanner() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove(_betaBannerDismissedKey);

      if (mounted) {
        state = true;
        debugPrint("Beta banner reset and will show again");
      }
    } catch (e) {
      debugPrint("Error resetting beta banner: $e");
    }
  }
}
