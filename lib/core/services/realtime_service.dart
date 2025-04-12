// lib/core/services/realtime_service.dart
import 'dart:async'; // Keep async import
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart'; // To read selected team

// Assuming your table is named 'NewsArticles' in the 'public' schema. Adjust if needed.
const String _newsArticlesTable = 'NewsArticles';
const String _dbSchema = 'public';

// --- TEMPORARY MAPPING (Ensure this is populated correctly!) ---
// You MUST update this map with the correct numeric IDs for ALL your teams
// from your database 'Teams' table.
const Map<String, int> teamAbbreviationToNumericId = {
  'ARI': 1,
  'ATL': 2,
  'BAL': 3,
  'BUF': 4,
  'CAR': 7,
  'CHI': 5,
  'CIN': 6,
  'CLE': 8,
  'DAL': 9,
  'DEN': 10,
  'DET': 11,
  'GB': 12,
  'HOU': 13,
  'IND': 14,
  'JAC': 15,
  'KC': 16,
  'LV': 17,
  'LAC': 18,
  'LAR': 19,
  'MIA': 20,
  'MIN': 21,
  'NE': 22,
  'NO': 23,
  'NYG': 24,
  'NYJ': 25,
  'PHI': 26,
  'PIT': 27,
  'SF': 28,
  'SEA': 29,
  'TB': 30,
  'TEN': 31,
  'WAS': 32,
};
// --- END TEMPORARY MAPPING ---

class RealtimeService {
  final SupabaseClient _supabaseClient;
  final Ref _ref; // Riverpod Ref to read other providers
  RealtimeChannel? _newsArticlesChannel;

  RealtimeService(this._ref) : _supabaseClient = Supabase.instance.client {
    debugPrint("RealtimeService initialized.");
  }

  void initializeListeners() {
    // Avoid duplicate listeners if called multiple times
    if (_newsArticlesChannel != null) {
      debugPrint("Realtime listeners already initialized.");
      return;
    }

    debugPrint("Initializing Realtime listeners for $_newsArticlesTable...");

    final channelName = 'db-$_newsArticlesTable-inserts';

    _newsArticlesChannel = _supabaseClient.channel(channelName);

    // Use the .onPostgresChanges method as you updated
    _newsArticlesChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert, // Listen only for inserts
          schema: _dbSchema,
          table: _newsArticlesTable,
          callback: (payload) {
            // Pass the new record map directly to the handler
            _handleNewsInsert(payload.newRecord);
          },
        )
        .subscribe((status, [error]) async {
          // Subscribe is chained after .onPostgresChanges
          // Handle subscription status changes
          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint("✅ Realtime channel subscribed: $channelName");
          } else if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            String errorMessage = error?.toString() ?? "Unknown error";
            debugPrint(
              "❌ Realtime channel subscription error ($channelName): Status=$status, Error=$errorMessage",
            );
          } else {
            debugPrint("ℹ️ Realtime channel status ($channelName): $status");
          }
        });

    debugPrint(
      "Listening for INSERT events on $_dbSchema.$_newsArticlesTable via callback.",
    );
  }

  // Updated handler function
  void _handleNewsInsert(Map<String, dynamic> newRecord) {
    debugPrint("Received Realtime New Record: ${newRecord.toString()}");

    // --- Extract Release Status, Numeric Team ID, and Article ID ---
    // NOTE: Key names ('release', 'team', 'id') must EXACTLY match your DB column names
    final String? releaseStatus =
        newRecord['release'] as String?; // <<< Read 'release' column
    final int? articleTeamNumericId =
        newRecord['team'] as int?; // <<< Read 'team', expect int
    final int articleId = newRecord['id'] as int? ?? 0;

    // Get the user's currently selected team ABBREVIATION ('CAR', 'DAL', etc.)
    final selectedTeamState = _ref.read(selectedTeamNotifierProvider);
    final String? userSelectedTeamAbbreviation = selectedTeamState.valueOrNull;

    // --- Convert user's selected ABBREVIATION to NUMERIC ID ---
    int? userSelectedTeamNumericId;
    if (userSelectedTeamAbbreviation != null) {
      // Use the temporary map to find the corresponding numeric ID
      userSelectedTeamNumericId =
          teamAbbreviationToNumericId[userSelectedTeamAbbreviation];
      if (userSelectedTeamNumericId == null) {
        debugPrint(
          "Warning: Could not find numeric ID mapping for selected team abbreviation: $userSelectedTeamAbbreviation",
        );
      }
    }

    // Updated debug log to show relevant values
    debugPrint(
      "Checking new article: ID=$articleId, ReleaseStatus=$releaseStatus, ArticleTeamNumericID=$articleTeamNumericId, UserSelectedTeamAbbr=$userSelectedTeamAbbreviation, UserSelectedTeamNumericID=$userSelectedTeamNumericId",
    );

    // --- Perform the check using NUMERIC IDs and 'PUBLISHED' release status ---
    if (releaseStatus ==
            'PUBLISHED' && // <<< Check 'release' column for 'PUBLISHED'
        articleTeamNumericId != null &&
        userSelectedTeamNumericId !=
            null && // Ensure user has a team selected AND it was mapped
        articleTeamNumericId == userSelectedTeamNumericId) {
      // Compare numeric IDs
      // Match found!
      debugPrint(
        "✅ MATCH FOUND! New 'PUBLISHED' article (ID: $articleId) for selected team (Abbr: $userSelectedTeamAbbreviation, NumID: $userSelectedTeamNumericId). Ready for push notification!",
      );

      // **FUTURE STEP:** Trigger push notification here.
    } else {
      // Updated debug log for non-matching criteria
      debugPrint(
        "Realtime insert did not match criteria (Release requires 'PUBLISHED' or Team ID mismatch).",
      );
    }
  }

  void dispose() {
    debugPrint("Disposing RealtimeService and unsubscribing...");
    if (_newsArticlesChannel != null) {
      _supabaseClient.removeChannel(_newsArticlesChannel!);
      _newsArticlesChannel = null;
      debugPrint("Realtime channel removed.");
    } else {
      debugPrint("No active realtime channel to remove.");
    }
  }
}
