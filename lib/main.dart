import 'package:flutter/material.dart';
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
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🔥 Firebase initialized successfully!");

  // --- Set up Background Message Handler ---
  // IMPORTANT: This must be called *outside* the runApp() call,
  // after Firebase.initializeApp, but before other logic that might depend on it.
  NotificationService.setupBackgroundMessageHandler();
  // --- End Background Setup ---

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
