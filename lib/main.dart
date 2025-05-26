import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tackle_4_loss/app.dart'; // Your MyApp widget

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- Import Notification Service and Provider ---
// Needed for background handler type
import 'package:tackle_4_loss/core/services/notification_service.dart';
import 'package:tackle_4_loss/core/providers/notification_provider.dart';
// --- End Imports ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add debugging for environment loading
  debugPrint("=== MAIN.DART ENV DEBUG START ===");
  debugPrint("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
  debugPrint("Default Target Platform: ${defaultTargetPlatform}");

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env file loaded successfully");

    // Check specific environment variables
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    debugPrint(
      "SUPABASE_URL: ${supabaseUrl != null ? 'LOADED' : 'NULL'} (${supabaseUrl?.substring(0, 20) ?? 'null'}...)",
    );
    debugPrint(
      "SUPABASE_ANON_KEY: ${supabaseAnonKey != null ? 'LOADED' : 'NULL'} (${supabaseAnonKey?.substring(0, 10) ?? 'null'}...)",
    );

    // Check all loaded environment variables
    debugPrint("Total env vars loaded: ${dotenv.env.length}");
    debugPrint("Env keys: ${dotenv.env.keys.toList()}");
  } catch (e) {
    debugPrint("❌ Error loading .env file: $e");
    debugPrint("This might be the root cause of mobile vs web differences!");
  }
  debugPrint("=== MAIN.DART ENV DEBUG END ===");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🔥 Firebase initialized successfully!");

  // --- Set up Background Message Handler ---
  // IMPORTANT: This must be called *outside* the runApp() call,
  // after Firebase.initializeApp, but before other logic that might depend on it.
  NotificationService.setupBackgroundMessageHandler();
  // --- End Background Setup ---

  // Add debugging for Supabase initialization
  debugPrint("=== SUPABASE INIT DEBUG START ===");
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        "Missing required environment variables: SUPABASE_URL=${supabaseUrl != null ? 'set' : 'missing'}, SUPABASE_ANON_KEY=${supabaseAnonKey != null ? 'set' : 'missing'}",
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    debugPrint("✅ Supabase initialized successfully");
    debugPrint(
      "Supabase client configured with URL: ${supabaseUrl.substring(0, 30)}...",
    );
  } catch (e) {
    debugPrint("❌ Error initializing Supabase: $e");
    // Continue anyway to see what happens
  }
  debugPrint("=== SUPABASE INIT DEBUG END ===");

  // --- Initialize Notification Service (Foreground) ---
  // We need ProviderScope to access the provider
  // Create a ProviderContainer temporarily to initialize
  // Or initialize within the first widget build (e.g., MyApp or MainNavigationWrapper)

  // Option 1: Initialize here using a temporary container
  final container = ProviderContainer();
  try {
    await container.read(notificationServiceProvider).initialize();
    debugPrint("Notification Service initialized via temporary container.");
  } catch (e) {
    debugPrint("Error initializing NotificationService early: $e");
  } finally {
    container.dispose(); // Dispose temporary container
  }

  // Option 2 (Alternative): Initialize later in MyApp or MainNavigationWrapper build
  // (See alternative implementation below if Option 1 causes issues)

  runApp(const ProviderScope(child: MyApp()));
}

// Helper Supabase client instance
final supabase = Supabase.instance.client;
