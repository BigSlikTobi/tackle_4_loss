// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tackle_4_loss/app.dart'; // Your MyApp widget

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- Import Notification Service and Provider ---
import 'package:tackle_4_loss/core/services/notification_service.dart';
import 'package:tackle_4_loss/core/providers/notification_provider.dart';
// --- Import Environment Config ---
import 'package:tackle_4_loss/core/config/environment_config.dart'; // Corrected import path
// --- Import for URL Strategy ---
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ADDED: Set URL strategy (try PathStrategy first for cleaner URLs) ---
  // This should be called before Firebase or Supabase initialization if it
  // might influence any routing aspects during their setup, though typically
  // it's most critical before runApp().
  if (kIsWeb) {
    // Only set URL strategy for web
    usePathUrlStrategy();
    debugPrint("✅ PathUrlStrategy set for web.");
    // Alternatively, to ensure hash strategy (default, but explicit):
    // useHashUrlStrategy();
    // debugPrint("✅ HashUrlStrategy explicitly set for web.");
  }
  // --- END URL Strategy ---

  debugPrint("=== MAIN.DART ENV DEBUG START ===");
  debugPrint("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
  debugPrint("Default Target Platform: $defaultTargetPlatform");
  debugPrint("Environment Config Info: ${EnvironmentConfig.debugInfo}");

  String? supabaseUrl;
  String? supabaseAnonKey;

  if (EnvironmentConfig.shouldUseEnvironmentConfig) {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("✅ .env file loaded successfully");

      supabaseUrl = dotenv.env['SUPABASE_URL'];
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      debugPrint(
        "SUPABASE_URL: ${supabaseUrl != null ? 'LOADED' : 'NULL'} (${supabaseUrl?.substring(0, supabaseUrl.length > 20 ? 20 : supabaseUrl.length) ?? 'null'}...)",
      );
      debugPrint(
        "SUPABASE_ANON_KEY: ${supabaseAnonKey != null ? 'LOADED' : 'NULL'} (${supabaseAnonKey?.substring(0, supabaseAnonKey.length > 10 ? 10 : supabaseAnonKey.length) ?? 'null'}...)",
      );

      debugPrint("Total env vars loaded: ${dotenv.env.length}");
      debugPrint("Env keys: ${dotenv.env.keys.toList()}");
    } catch (e) {
      debugPrint("❌ Error loading .env file: $e");
      debugPrint("This might be the root cause of mobile vs web differences!");
    }
  } else {
    supabaseUrl = EnvironmentConfig.supabaseUrl;
    supabaseAnonKey = EnvironmentConfig.supabaseAnonKey;

    debugPrint("✅ Using web compile-time environment config");
    debugPrint(
      "SUPABASE_URL: ${supabaseUrl != null ? 'LOADED' : 'NULL'} (${supabaseUrl?.substring(0, supabaseUrl.length > 20 ? 20 : supabaseUrl.length) ?? 'null'}...)",
    );
    debugPrint(
      "SUPABASE_ANON_KEY: ${supabaseAnonKey != null ? 'LOADED' : 'NULL'} (${supabaseAnonKey?.substring(0, supabaseAnonKey.length > 10 ? 10 : supabaseAnonKey.length) ?? 'null'}...)",
    );
  }
  debugPrint("=== MAIN.DART ENV DEBUG END ===");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🔥 Firebase initialized successfully!");

  NotificationService.setupBackgroundMessageHandler();

  debugPrint("=== SUPABASE INIT DEBUG START ===");
  try {
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        "Missing required environment variables: SUPABASE_URL=${supabaseUrl != null ? 'set' : 'missing'}, SUPABASE_ANON_KEY=${supabaseAnonKey != null ? 'set' : 'missing'}",
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    debugPrint("✅ Supabase initialized successfully");
    debugPrint(
      "Supabase client configured with URL: ${supabaseUrl.substring(0, supabaseUrl.length > 30 ? 30 : supabaseUrl.length)}...",
    );
  } catch (e) {
    debugPrint("❌ Error initializing Supabase: $e");
  }
  debugPrint("=== SUPABASE INIT DEBUG END ===");

  final container = ProviderContainer();
  try {
    await container.read(notificationServiceProvider).initialize();
    debugPrint("Notification Service initialized via temporary container.");
  } catch (e) {
    debugPrint("Error initializing NotificationService early: $e");
  } finally {
    container.dispose();
  }

  runApp(const ProviderScope(child: MyApp()));
}

final supabase = Supabase.instance.client;
