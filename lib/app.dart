// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:tackle_4_loss/core/navigation/main_navigation_wrapper.dart'; // No longer directly used here
import 'package:tackle_4_loss/core/theme/app_theme.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
// --- Import the routerProvider ---
import 'package:tackle_4_loss/core/navigation/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    // Watch the router provider to get the GoRouter instance
    final goRouter = ref.watch(routerProvider);

    debugPrint("[MyApp build] MaterialApp is now MaterialApp.router");

    return MaterialApp.router(
      // Changed to MaterialApp.router
      routerConfig: goRouter, // Use routerConfig
      // title: 'Tackle4Loss', // title is often set by GoRouter's routes or not needed for .router
      theme: AppTheme.lightTheme,

      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      locale: currentLocale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // home: const MainNavigationWrapper(), // home is managed by GoRouter
      debugShowCheckedModeBanner: false,
    );
  }
}
