import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import delegates
import 'package:tackle_4_loss/core/navigation/main_navigation_wrapper.dart';
import 'package:tackle_4_loss/core/theme/app_theme.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart'; // Import locale provider

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the locale provider to make MaterialApp rebuild when locale changes
    final currentLocale = ref.watch(localeNotifierProvider);

    return MaterialApp(
      title: 'Tackle4Loss',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,

      // --- Localization Setup ---
      locale: currentLocale, // Set the current locale from the provider
      supportedLocales: kSupportedLocales, // Define supported locales
      localizationsDelegates: const [
        // Provides localized strings for Material widgets (like back buttons)
        GlobalMaterialLocalizations.delegate,
        // Provides localized strings for Cupertino widgets
        GlobalWidgetsLocalizations.delegate,
        // Provides localized layout directions (LTR/RTL)
        GlobalCupertinoLocalizations.delegate,
        // Add other delegates if you use packages like `intl` for app strings
      ],

      // --- End Localization Setup ---
      home: const MainNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
