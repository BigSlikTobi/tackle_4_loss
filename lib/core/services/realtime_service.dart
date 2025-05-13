// lib/core/services/realtime_service.dart
// Keep async import
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart'; // To read selected team
// --- ADDED IMPORT for paginatedArticlesProvider ---
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
// --- END ADDED IMPORT ---

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
    // Register INSERT event handler and subscribe without callback to avoid type mismatches
    _newsArticlesChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: _dbSchema,
      table: _newsArticlesTable,
      callback: (payload) {
        debugPrint("---!!! Realtime Event Received by Flutter App !!!---");
        _handleNewsInsert(payload.newRecord);
      },
    );
    _newsArticlesChannel!.subscribe();
    debugPrint(
      "✅ Realtime channel subscribed: $channelName. Listening for INSERT events on $_dbSchema.$_newsArticlesTable.",
    );
  }

  // This function now only logs or potentially updates UI, DOES NOT trigger push.
  void _handleNewsInsert(Map<String, dynamic> newRecord) {
    debugPrint("--- Entering _handleNewsInsert (Flutter App) ---");
    debugPrint("Received Realtime New Record: ${newRecord.toString()}");

    // --- MODIFICATION FOR UI UPDATE ---
    final String? articleTeamAbbreviation =
        newRecord['teamId']
            as String?; // Assuming 'teamId' is the abbreviation string like "MIA", "BUF"
    final int? articleId =
        newRecord['id'] as int?; // Assuming 'id' is the article ID

    if (articleTeamAbbreviation != null && articleTeamAbbreviation.isNotEmpty) {
      debugPrint(
        "Realtime: New article (ID: $articleId) for team '$articleTeamAbbreviation' detected. Invalidating paginatedArticlesProvider for this team.",
      );
      // Invalidate the provider for the specific team.
      // This will cause widgets watching it (like TeamNewsTabContent) to refetch.
      _ref.invalidate(paginatedArticlesProvider(articleTeamAbbreviation));

      // Also, if the "My Team" screen is active and showing this team,
      // its direct fetch for the headline might also need invalidation.
      // The paginatedArticlesProvider(selectedTeamId) in MyTeamScreen will handle this.

      // If you have a "general" news feed (like "Other News" that shows *all* articles without team filter)
      // that should also update, you would invalidate its provider too.
      // For example, the main NewsFeedScreen's "Other News" uses paginatedArticlesProvider(null)
      // If a new article *could* appear there, invalidate it too.
      // Check if the source is NOT source 1 (NFL headlines are separate)
      // and if the new article qualifies for "Other News". This depends on your logic.
      // For now, let's assume "Other News" also needs a refresh.
      // The 'other_news' function might be different so this might need more specific handling
      // or rely on the fact that `paginatedArticlesProvider(null)` is for 'Other News' on main feed.
      final int? sourceId = newRecord['source'] as int?;
      if (sourceId != 1) {
        // Assuming 1 is NFL_News, which is handled differently
        debugPrint(
          "Realtime: New article (ID: $articleId) might affect 'Other News'. Invalidating paginatedArticlesProvider(null).",
        );
        _ref.invalidate(paginatedArticlesProvider(null));
      }
    } else {
      debugPrint(
        "Realtime: New article (ID: $articleId) does not have a teamId or it's empty. Not invalidating specific team news provider.",
      );
    }
    // --- END MODIFICATION ---

    final String? releaseStatus = newRecord['release'] as String?;
    final int? articleTeamNumericId =
        newRecord['team'] as int?; // This 'team' might be the numeric ID.

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
      "Checking new article in Flutter: ID=$articleId, ReleaseStatus=$releaseStatus, ArticleTeamNumericID (from 'team' field)=$articleTeamNumericId, UserSelectedTeamAbbr=$userSelectedTeamAbbreviation, UserSelectedTeamNumericID=$userSelectedTeamNumericId",
    );

    if (releaseStatus == 'PUBLISHED' &&
        articleTeamNumericId !=
            null && // This checks the numeric 'team' field if it exists
        userSelectedTeamNumericId != null &&
        articleTeamNumericId == userSelectedTeamNumericId) {
      debugPrint(
        "✅ Flutter Realtime detected a relevant article insert (ID: $articleId) for the current user (MATCHES PUSH LOGIC). Push notification handled by backend. UI update handled by teamId '$articleTeamAbbreviation' invalidation.",
      );
    } else {
      debugPrint(
        "Flutter Realtime: Inserted article (ID: $articleId) did not match push notification criteria for current user, or teamId for UI update was not available.",
      );
    }
    debugPrint("--- Exiting _handleNewsInsert (Flutter App) ---");
  }

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
