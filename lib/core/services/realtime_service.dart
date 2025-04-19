// lib/core/services/realtime_service.dart
// Keep async import
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart'; // To read selected team

const String _newsArticlesTable = 'NewsArticles';
const String _dbSchema = 'public';

// --- Temporary Mapping (Still needed for logging/comparison if desired) ---
// Ensure this map is accurate and complete based on your DB 'Teams' table.
const Map<String, int> teamAbbreviationToNumericId = {
  'ARI': 1, 'ATL': 2, 'BAL': 3, 'BUF': 4, 'CAR': 7, 'CHI': 5,
  'CIN': 6, 'CLE': 8, 'DAL': 9, 'DEN': 10, 'DET': 11, 'GB': 12,
  'HOU': 13, 'IND': 14, 'JAC': 15, 'KC': 16, 'LV': 17, 'LAC': 18,
  'LAR': 19, 'MIA': 20, 'MIN': 21, 'NE': 22, 'NO': 23, 'NYG': 24,
  'NYJ': 25, // Was 27 before, ensure 25 is correct from DB
  'PHI': 26, 'PIT': 27, 'SF': 28, 'SEA': 29, 'TB': 30,
  'TEN': 31, 'WAS': 32,
};
// --- End Mapping ---

class RealtimeService {
  final SupabaseClient _supabaseClient;
  final Ref _ref;
  RealtimeChannel? _newsArticlesChannel;

  RealtimeService(this._ref) : _supabaseClient = Supabase.instance.client {
    debugPrint("RealtimeService initialized.");
  }

  void initializeListeners() {
    if (_newsArticlesChannel != null) {
      debugPrint("Realtime listeners already initialized.");
      return;
    }
    debugPrint("Initializing Realtime listeners for $_newsArticlesTable...");
    final channelName = 'db-$_newsArticlesTable-inserts';
    _newsArticlesChannel = _supabaseClient.channel(channelName);
    _newsArticlesChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: _dbSchema,
          table: _newsArticlesTable,
          callback: (payload) {
            debugPrint("---!!! Realtime Event Received by Flutter App !!!---");
            // This callback still runs when the app is in the FOREGROUND.
            // It no longer triggers the push, but can be used for live UI updates.
            _handleNewsInsert(payload.newRecord);
          },
        )
        .subscribe((status, [error]) async {
          // --- Corrected detailed status logging ---
          debugPrint("--- Realtime Subscription Status Changed ---");
          debugPrint("Channel: $channelName, Status: $status");
          if (error != null) {
            // Log the error using toString() for general info
            debugPrint("Error accompanying status change: ${error.toString()}");
            // Avoid specific type checks like 'is RealtimeError' unless the type is guaranteed
          }
          debugPrint("------------------------------------------");
          // --- End Logging ---

          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint("✅ Realtime channel subscribed: $channelName");
          } else if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            // Error already logged above
          } else {
            // Log other statuses if needed (e.g., RealtimeSubscribeStatus.closed)
            debugPrint(
              "ℹ️ Realtime channel status ($channelName) is now: $status",
            );
          }
        });
    debugPrint(
      "Listening for INSERT events on $_dbSchema.$_newsArticlesTable via callback.",
    );
  }

  // This function now only logs or potentially updates UI, DOES NOT trigger push.
  void _handleNewsInsert(Map<String, dynamic> newRecord) {
    debugPrint("--- Entering _handleNewsInsert (Flutter App) ---");
    debugPrint("Received Realtime New Record: ${newRecord.toString()}");

    final String? releaseStatus = newRecord['release'] as String?;
    final int? articleTeamNumericId = newRecord['team'] as int?;
    final int articleId = newRecord['id'] as int? ?? 0;

    final selectedTeamState = _ref.read(selectedTeamNotifierProvider);
    final String? userSelectedTeamAbbreviation = selectedTeamState.valueOrNull;

    int? userSelectedTeamNumericId;
    if (userSelectedTeamAbbreviation != null) {
      userSelectedTeamNumericId =
          teamAbbreviationToNumericId[userSelectedTeamAbbreviation];
      if (userSelectedTeamNumericId == null) {
        debugPrint(
          "Warning: Could not find numeric ID mapping for selected team abbreviation: $userSelectedTeamAbbreviation",
        );
      }
    }

    debugPrint(
      "Checking new article in Flutter: ID=$articleId, ReleaseStatus=$releaseStatus, ArticleTeamNumericID=$articleTeamNumericId, UserSelectedTeamAbbr=$userSelectedTeamAbbreviation, UserSelectedTeamNumericID=$userSelectedTeamNumericId",
    );

    if (releaseStatus == 'PUBLISHED' &&
        articleTeamNumericId != null &&
        userSelectedTeamNumericId != null &&
        articleTeamNumericId == userSelectedTeamNumericId) {
      // Log that a match relevant to the current user was found.
      // The actual push is handled entirely by the backend webhook now.
      debugPrint(
        "✅ Flutter Realtime detected a relevant article insert (ID: $articleId) for the current user. Push notification handled by backend.",
      );

      // --- TODO (Optional): Implement live UI updates here ---
      // For example, invalidate the news feed provider to show the new article
      // without requiring a manual refresh, but be careful about race conditions
      // with the main list fetching.
      // Example: ref.invalidate(paginatedArticlesProvider);
      // --- End Optional ---
    } else {
      debugPrint(
        "Flutter Realtime: Inserted article did not match current user's criteria.",
      );
    }
    debugPrint("--- Exiting _handleNewsInsert (Flutter App) ---");
  }

  // --- REMOVED _triggerSendPushNotification function ---
  // This function is no longer needed as the backend webhook handles triggering.

  void dispose() {
    debugPrint("Disposing RealtimeService and unsubscribing...");
    if (_newsArticlesChannel != null) {
      // removeChannel implicitly handles unsubscribe if needed by the client library
      _supabaseClient.removeChannel(_newsArticlesChannel!);
      _newsArticlesChannel = null;
      debugPrint("Realtime channel removed.");
    } else {
      debugPrint("No active realtime channel to remove.");
    }
  }
}
