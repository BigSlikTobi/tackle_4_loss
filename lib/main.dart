// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tackle_4_loss/app.dart'; // Import your MyApp widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Wrap your MyApp widget with ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

// Helper Supabase client instance (keep for now, or manage via Riverpod later)
final supabase = Supabase.instance.client;
