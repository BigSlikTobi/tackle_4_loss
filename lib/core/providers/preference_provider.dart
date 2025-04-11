// lib/core/providers/preference_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/services/preference_service.dart'; // Import your service

// Provider for the PreferenceService instance
final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  return PreferenceService();
});

// StateNotifierProvider to manage the selected team ID state
final selectedTeamNotifierProvider =
    StateNotifierProvider<SelectedTeamNotifier, AsyncValue<String?>>((ref) {
      // Pass the PreferenceService to the notifier
      return SelectedTeamNotifier(ref.watch(preferenceServiceProvider));
    });

class SelectedTeamNotifier extends StateNotifier<AsyncValue<String?>> {
  final PreferenceService _preferenceService;

  SelectedTeamNotifier(this._preferenceService)
    : super(const AsyncValue.loading()) {
    _loadInitialTeam();
  }

  Future<void> _loadInitialTeam() async {
    // ... (loading logic) ...
    try {
      final teamId = await _preferenceService.getSelectedTeam();
      if (mounted) {
        state = AsyncValue.data(teamId);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  Future<void> selectTeam(String? teamId) async {
    final previousState = state; // Store previous state (AsyncValue<String?>)

    // Optimistic update
    state = AsyncValue.data(teamId);
    debugPrint("Team selected in UI: $teamId");

    try {
      await _preferenceService.saveSelectedTeam(teamId);
      debugPrint("Team preference saved successfully.");
    } catch (e, s) {
      debugPrint("Error saving team preference: $e");
      if (mounted) {
        // --- APPLY EXPLICIT CAST HERE ---
        state =
            AsyncValue.error(e, s).copyWithPrevious(previousState)
                as AsyncValue<String?>;
        // --- END FIX ---
        debugPrint(
          "Reverted state due to save error. Previous state value was: ${previousState.valueOrNull}",
        );
      }
    }
  }
}
