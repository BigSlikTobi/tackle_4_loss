// lib/core/providers/navigation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Holds the currently selected navigation index for the main sections (News, Team, etc.)
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

// --- NEW: Holds the ID of the article currently being viewed in detail ---
// Null means no detail screen is shown, displaying the main IndexedStack content.
final currentDetailArticleIdProvider = StateProvider<int?>((ref) => null);


// Holds the state of the sidebar (expanded or collapsed) for non-mobile layouts - REMOVED as it wasn't used per README.md
// final isSidebarExtendedProvider = StateProvider<bool>(
//   (ref) => false,
// ); // Start collapsed