import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
// --- ADDED IMPORT for Firebase Core to ensure firebaseMessagingBackgroundHandler can initialize ---
import 'package:firebase_core/firebase_core.dart';
// --- END ADDED IMPORT ---

// --- ADDED: Background Message Handler (must be a top-level function) ---
// It must not be an anonymous function and must be a top-level function (e.g. not a class method which requires initialization).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // However, for just handling the message, it might not be strictly necessary
  // if Firebase.initializeApp was already called in main().
  // To be safe, especially if this handler might evolve:
  await Firebase.initializeApp(); // Ensure Firebase is initialized in this isolate

  debugPrint(
    "🔔 [BACKGROUND FCM] Handling a background message: ${message.messageId}",
  );
  debugPrint("🔔 [BACKGROUND FCM] Message data: ${message.data}");
  if (message.notification != null) {
    debugPrint(
      "🔔 [BACKGROUND FCM] Message also contained a notification: ${message.notification?.title} - ${message.notification?.body}",
    );
  }
  // Here you could, for example, update a badge count or schedule a local notification
  // if your backend sends data-only messages for background notifications.
}
// --- END ADDED Background Message Handler ---

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
      _setupForegroundMessageHandler(); // Setup foreground listener
    } else {
      debugPrint('User declined or has not accepted notification permissions.');
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    // Request permission for iOS, Android, and Web
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // Set to true for provisional authorization on iOS
      sound: true,
    );
  }

  // Gets token and saves ONLY token/platform initially
  Future<void> _getTokenAndInitialSave() async {
    try {
      // For iOS, ensure APNS token is fetched if using FCM directly
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // String? apnsToken = await _firebaseMessaging.getAPNSToken(); // Potentially null
        // if (apnsToken == null) {
        //   debugPrint("Waiting for APNS token...");
        //   // This is a common pattern if the APNS token isn't immediately available.
        //   // Firebase handles this internally, but good to be aware.
        //   await Future<void>.delayed(const Duration(seconds: 1)); // Wait a bit and retry
        //   apnsToken = await _firebaseMessaging.getAPNSToken();
        // }
        // if (apnsToken != null) {
        //   debugPrint("APNS Token: $apnsToken");
        // } else {
        //   debugPrint("Failed to get APNS token even after delay.");
        // }
        // Note: With `flutterfire_cli` setup, direct APNS token handling is often not needed
        // as Firebase SDK manages the FCM token registration which uses APNS underneath.
      }

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
            debugPrint("Error during FCM token refresh: $err");
          });
    } catch (e) {
      debugPrint("Error in _getTokenAndInitialSave: $e");
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
          .from('DeviceToken') // Corrected table name
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

  // --- IMPLEMENTED: Setup for foreground message listening ---
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 [FOREGROUND FCM] Got a message whilst in the foreground!');
      debugPrint('🔔 [FOREGROUND FCM] Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          '🔔 [FOREGROUND FCM] Message also contained a notification: ${message.notification?.title} - ${message.notification?.body}',
        );
        // Here, you would typically show a local notification using a package
        // like flutter_local_notifications, because foreground FCM messages
        // do not display a system notification by default on iOS and Android.
        // For example:
        // showLocalNotification(message.notification.title, message.notification.body);
      } else {
        debugPrint(
          '🔔 [FOREGROUND FCM] Message did not contain a notification.',
        );
      }

      // You can also handle data messages here:
      // if (message.data.isNotEmpty) {
      //   final articleId = message.data['articleId'];
      //   if (articleId != null) {
      //     // Potentially navigate or refresh data
      //   }
      // }
    });

    // Also handle when a notification is tapped and the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        debugPrint(
          '🔔 [INITIAL FCM] App opened from terminated state by tapping notification: ${message.messageId}',
        );
        debugPrint('🔔 [INITIAL FCM] Message data: ${message.data}');
        // Handle navigation or data processing based on message.data
        // For example, if your notification payload includes an 'articleId':
        // final String? articleId = message.data['articleId'];
        // if (articleId != null) {
        //    _navigateToArticle(articleId);
        // }
      }
    });

    // Handle when a notification is tapped and the app is opened from a background state (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '🔔 [ON_MESSAGE_OPENED_APP FCM] App opened from background by tapping notification: ${message.messageId}',
      );
      debugPrint(
        '🔔 [ON_MESSAGE_OPENED_APP FCM] Message data: ${message.data}',
      );
      // Handle navigation or data processing based on message.data
      // final String? screen = message.data['screen'];
      // if (screen == 'articleDetail' && message.data['articleId'] != null) {
      //    _navigateToArticle(message.data['articleId']);
      // }
    });
  }
  // --- END IMPLEMENTED ---

  // --- REPLACED PLACEHOLDER: Static method to set up the background handler ---
  static void setupBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint("🔔 Firebase background message handler set up.");
  }
  // --- END REPLACED ---

  // Example helper for navigation (you'd need to implement the actual navigation logic)
  // void _navigateToArticle(String articleId) {
  //   debugPrint("Navigating to article: $articleId");
  //   // Your navigation logic here, e.g., using a GlobalKey<NavigatorState> or Riverpod state
  // }
}
