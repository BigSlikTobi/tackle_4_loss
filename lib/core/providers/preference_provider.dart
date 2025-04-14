// lib/core/providers/preference_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/services/preference_service.dart'; // Import your service
// --- Import Notification Provider ---
import 'package:tackle_4_loss/core/providers/notification_provider.dart';
// --- End Import ---

// Provider for the PreferenceService instance
final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  return PreferenceService();
});

// StateNotifierProvider to manage the selected team ID state
final selectedTeamNotifierProvider = StateNotifierProvider<
  SelectedTeamNotifier,
  AsyncValue<String?>
>((ref) {
  // --- Pass Ref to the notifier ---
  // The notifier now needs the ref to access other providers (like notificationServiceProvider)
  return SelectedTeamNotifier(ref);
  // --- End Pass Ref ---
});

class SelectedTeamNotifier extends StateNotifier<AsyncValue<String?>> {
  // --- Store Ref ---
  // Hold the ProviderReference to access other providers
  final Ref _ref;
  // --- End Store Ref ---

  // --- Get PreferenceService via Ref ---
  // Use 'late final' because it's initialized in the constructor body
  late final PreferenceService _preferenceService;
  // --- End Get PreferenceService ---

  // Modify constructor to accept and store Ref
  SelectedTeamNotifier(this._ref) // Receive Ref
    : super(const AsyncValue.loading()) {
    // Read the service provider using the passed ref
    _preferenceService = _ref.read(preferenceServiceProvider);
    _loadInitialTeam();
  }

  Future<void> _loadInitialTeam() async {
    // Show loading state initially
    // state = const AsyncValue.loading(); // Already set by constructor

    try {
      final teamId = await _preferenceService.getSelectedTeam();
      // Check if the notifier is still mounted before updating state
      if (mounted) {
        state = AsyncValue.data(teamId);
        // --- Optionally update DB subscription on initial load ---
        // This ensures the DB reflects the persisted preference when the app starts.
        // It's okay if the notification service isn't fully ready yet,
        // the updateTeamSubscription handles null tokens internally.
        if (teamId != null) {
          debugPrint("Attempting initial team subscription sync for $teamId");
          // No need to await here, let it run in the background
          _ref.read(notificationServiceProvider).updateTeamSubscription(teamId);
        }
      }
    } catch (e, s) {
      debugPrint("Error loading initial team preference: $e");
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  Future<void> selectTeam(String? teamId) async {
    // Store previous state in case of error
    final previousState = state;

    // Optimistic UI update
    state = AsyncValue.data(teamId);
    debugPrint("Team selected in UI: $teamId");

    try {
      // 1. Save to SharedPreferences (as before)
      await _preferenceService.saveSelectedTeam(teamId);
      debugPrint("Team preference saved successfully to SharedPreferences.");

      // --- 2. Update Team Subscription in Supabase ---
      // Use the stored ref to read the notification service provider
      // Call the update method using the *newly selected* teamId (abbreviation or null)
      // No need to await here if you don't need to wait for completion
      _ref.read(notificationServiceProvider).updateTeamSubscription(teamId);
      debugPrint("Attempted to update team subscription in DB for $teamId");
      // --- End Update ---
    } catch (e, s) {
      // Catch errors from both SharedPreferences save AND the notification update attempt
      debugPrint(
        "Error saving team preference or updating DB subscription: $e",
      );
      if (mounted) {
        // Revert state if error occurred
        state =
            AsyncValue.error(e, s).copyWithPrevious(previousState)
                as AsyncValue<String?>;
        debugPrint("Reverted state due to save/update error.");
      }
    }
  }
}
