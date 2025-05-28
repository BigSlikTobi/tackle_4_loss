// lib/core/providers/navigation_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Holds the currently selected navigation index for the main sections (News, Team, etc.)
// This is now mostly driven by StatefulNavigationShell.currentIndex but can be watched
// by UI elements if they need to react to the current shell tab index.
// Its role in *driving* navigation is removed from MainNavigationWrapper.
final selectedNavIndexProvider = StateProvider<int>((ref) {
  // This provider should ideally reflect the GoRouter's shell current index.
  // However, directly linking it to StatefulNavigationShell's index here is complex
  // without access to the shell instance.
  // For now, it remains as a separate state. If MainNavigationWrapper needs to
  // update this based on navigationShell.currentIndex, it could do so via a listener
  // or by reading the shell's index if a way is found to expose it to this provider's setup.
  // For this commit, we acknowledge its reduced role.
  // If MainNavigationWrapper's BottomNavBar/Drawer updates this on tap, and also calls
  // goBranch, it might stay in sync.
  // We aim to remove or fully decouple this if GoRouter handles all index needs.
  debugPrint(
    "[navigation_provider] selectedNavIndexProvider initialized to 0. Its direct control over navigation is deprecated.",
  );
  return 0;
});

// --- DEPRECATED ---
// This provider was used to conditionally show ArticleDetailScreen within MainNavigationWrapper.
// Since ArticleDetailScreen is now a top-level route handled by GoRouter, this provider
// is no longer needed for that purpose.
// If it's used elsewhere for tracking a "currently viewed article ID" for other UI logic
// (e.g., highlighting in a list), its purpose needs to be re-evaluated.
// For now, we are removing its primary use case.
final currentDetailArticleIdProvider = StateProvider<int?>((ref) {
  debugPrint(
    "[navigation_provider] currentDetailArticleIdProvider initialized to null. Its use for showing ArticleDetailScreen in MainNavigationWrapper is deprecated.",
  );
  return null;
});
