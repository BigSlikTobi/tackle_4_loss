import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Required for WidgetsBinding
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Constants and Provider definition remain the same ---
const kDefaultLocale = Locale('en');
const kSupportedLocales = [Locale('en'), Locale('de')];
const String _selectedLocaleKey = 'selectedLocaleCode';

final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale>((
  ref,
) {
  return LocaleNotifier();
});

// --- LocaleNotifier Class ---
class LocaleNotifier extends StateNotifier<Locale> {
  SharedPreferences? _prefs;

  LocaleNotifier() : super(kDefaultLocale) {
    _loadSavedLocale();
  }

  // --- _loadSavedLocale (unchanged from previous correct version) ---
  Future<void> _loadSavedLocale() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = _prefs?.getString(_selectedLocaleKey);
      Locale initialLocale = kDefaultLocale;
      if (savedLanguageCode != null) {
        final potentialLocale = Locale(savedLanguageCode);
        if (kSupportedLocales.contains(potentialLocale)) {
          initialLocale = potentialLocale;
          debugPrint("Loaded saved locale: $savedLanguageCode");
        } else {
          debugPrint(
            "Saved locale '$savedLanguageCode' is not supported, defaulting to English.",
          );
        }
      } else {
        try {
          final deviceLocales = PlatformDispatcher.instance.locales;
          if (deviceLocales.isNotEmpty) {
            final deviceLocale = deviceLocales.first;
            debugPrint("Detected device locale: ${deviceLocale.languageCode}");
            if (kSupportedLocales.any(
              (supported) =>
                  supported.languageCode == deviceLocale.languageCode,
            )) {
              if (deviceLocale.languageCode == 'de') {
                initialLocale = const Locale('de');
                debugPrint(
                  "Setting initial locale to German based on device locale.",
                );
              }
            } else {
              debugPrint(
                "Device locale ${deviceLocale.languageCode} not directly supported, defaulting to English.",
              );
            }
          } else {
            debugPrint(
              "Could not detect device locale, defaulting to English.",
            );
          }
        } catch (e) {
          debugPrint("Error detecting device locale: $e");
        }
      }
      if (!kSupportedLocales.contains(initialLocale)) {
        initialLocale = kDefaultLocale;
      }
      // Use 'mounted' check before updating state after await
      if (mounted && state != initialLocale) {
        state = initialLocale;
        debugPrint("Initial locale state set to: ${state.languageCode}");
      } else if (mounted && state == initialLocale) {
        debugPrint(
          "Initial locale (${initialLocale.languageCode}) already matches current state. No update needed.",
        );
      } else {
        debugPrint("Notifier unmounted before initial locale could be set.");
      }
    } catch (e, stackTrace) {
      debugPrint("Error loading saved locale: $e\n$stackTrace");
      if (mounted) {
        state = kDefaultLocale;
      }
    }
  }

  // --- setLocale: Save Pref -> Schedule State Update Post-Frame ---
  Future<void> setLocale(Locale newLocale) async {
    if (kSupportedLocales.contains(newLocale) && state != newLocale) {
      try {
        _prefs ??= await SharedPreferences.getInstance();
        // 1. Save preference FIRST
        await _prefs?.setString(_selectedLocaleKey, newLocale.languageCode);
        debugPrint("Locale preference saved: ${newLocale.languageCode}");

        // 2. Schedule state update AFTER the current frame finishes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 3. Check if mounted INSIDE the callback
          if (mounted) {
            // 4. Update state safely after the frame
            state = newLocale;
            debugPrint(
              "Locale state updated post-frame to: ${newLocale.languageCode}",
            );
          } else {
            debugPrint(
              "Notifier unmounted before post-frame locale state could be updated.",
            );
          }
        });
      } catch (e, stackTrace) {
        debugPrint("Error saving locale preference: $e\n$stackTrace");
        // Error handling
      }
    } else if (state == newLocale) {
      debugPrint("Locale ${newLocale.languageCode} already selected.");
    } else {
      debugPrint(
        "Attempted to set unsupported locale: ${newLocale.languageCode}",
      );
    }
  }
}
