import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  String? _currentFcmToken;

  Future<void> initialize() async {
    NotificationSettings settings = await _requestPermission();
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification Permissions Authorized.');
      await _getTokenAndInitialSave(); // Renamed for clarity
      _setupForegroundMessageHandler();
    } else {
      debugPrint('User declined or has not accepted notification permissions.');
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(/* ... */);
  }

  // Gets token and saves ONLY token/platform initially
  Future<void> _getTokenAndInitialSave() async {
    try {
      // ... APNS logic ...
      _currentFcmToken = await _firebaseMessaging.getToken();
      if (_currentFcmToken != null) {
        debugPrint("---------- FCM TOKEN ----------");
        debugPrint(_currentFcmToken);
        debugPrint("-------------------------------");
        // Initial save only includes token and platform
        await _upsertTokenRecord(
          _currentFcmToken!,
          null,
        ); // Pass null for team ID initially
      } else {
        debugPrint("Failed to get FCM token.");
      }

      _firebaseMessaging.onTokenRefresh
          .listen((newToken) {
            debugPrint("---------- FCM TOKEN REFRESHED ----------");
            debugPrint(newToken);
            debugPrint("-----------------------------------------");
            String? previousToken = _currentFcmToken; // Keep track of old token
            _currentFcmToken = newToken; // Update local token

            // Upsert the *new* token record, potentially clearing team ID initially
            _upsertTokenRecord(newToken, null).then((_) {
              // Optional: After upserting the new token, delete the old one
              // This requires knowing the old token value.
              if (previousToken != null && previousToken != newToken) {
                _deleteTokenRecord(previousToken);
              }
            });
          })
          .onError((err) {
            /* ... */
          });
    } catch (e) {
      /* ... */
    }
  }

  // --- Central Upsert Function ---
  // Now takes an optional team ID
  Future<void> _upsertTokenRecord(String token, int? teamNumericId) async {
    try {
      final String platformValue;
      // ... platform detection ...
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformValue = 'android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformValue = 'ios';
      } else if (kIsWeb) {
        platformValue = 'web';
      } else {
        platformValue = 'unknown';
      }

      debugPrint(
        "Upserting token record: Token=...${token.substring(token.length - 10)}, Platform=$platformValue, TeamID=$teamNumericId",
      );

      await _supabaseClient
          .from('DeviceToken')
          .upsert(
            {
              'token': token,
              'platform': platformValue,
              'subscribed_team_id': teamNumericId, // Include team ID in upsert
            },
            onConflict: 'token', // Conflict on token ensures update
            ignoreDuplicates: false,
          );
      debugPrint("Token record upserted successfully.");
    } catch (e) {
      debugPrint("Error upserting token record to Supabase: $e");
    }
  }

  // --- Optional: Function to delete old token ---
  Future<void> _deleteTokenRecord(String oldToken) async {
    try {
      await _supabaseClient
          .from('device_tokens')
          .delete()
          .eq('token', oldToken);
      debugPrint(
        "Successfully deleted old token record: ...${oldToken.substring(oldToken.length - 10)}",
      );
    } catch (e) {
      debugPrint("Error deleting old token record: $e");
    }
  }

  // --- UPDATED Method: Uses central upsert ---
  Future<void> updateTeamSubscription(String? teamAbbreviation) async {
    if (_currentFcmToken == null) {
      debugPrint("Cannot update team subscription: FCM token not available.");
      _currentFcmToken = await FirebaseMessaging.instance.getToken();
      if (_currentFcmToken == null) {
        debugPrint(
          "Still cannot update team subscription: FCM token is null after re-check.",
        );
        return;
      }
      debugPrint(
        "Re-fetched FCM token for team subscription update: $_currentFcmToken",
      );
      // We need to ensure this re-fetched token exists in DB before proceeding
      // The initial save should have handled this, but let's be safe
      await _upsertTokenRecord(_currentFcmToken!, null); // Upsert just in case
    }

    final int? teamNumericId =
        (teamAbbreviation != null)
            ? teamAbbreviationToNumericId[teamAbbreviation.toUpperCase()]
            : null;

    if (teamAbbreviation != null && teamNumericId == null) {
      debugPrint(
        "Warning: Could not map team abbreviation '$teamAbbreviation' to numeric ID. Clearing subscription.",
      );
    }

    debugPrint(
      "Requesting upsert for token $_currentFcmToken with team ID: $teamNumericId (Abbr: $teamAbbreviation)",
    );

    // --- Call the central upsert function ---
    // This will insert if not exists, or update if exists, setting the team ID
    await _upsertTokenRecord(_currentFcmToken!, teamNumericId);
    // No separate update call needed anymore
    // --- End call ---
  }
  // --- End Updated Method ---

  void _setupForegroundMessageHandler() {
    /* ... remains same ... */
  }
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    /* ... remains same ... */
  }
  static void setupBackgroundMessageHandler() {
    /* ... remains same ... */
  }
}
