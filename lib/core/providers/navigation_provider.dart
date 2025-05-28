// lib/core/providers/navigation_provider.dart
import 'package:flutter/material.dart'; // For debugPrint

// --- selectedNavIndexProvider was REMOVED in the previous commit ---

// --- currentDetailArticleIdProvider is REMOVED ---
// final currentDetailArticleIdProvider = StateProvider<int?>((ref) {
//   debugPrint("[navigation_provider] currentDetailArticleIdProvider initialized to null. Its use for showing ArticleDetailScreen in MainNavigationWrapper is deprecated.");
//   return null;
// });

// This file might become empty or be removed if no other navigation-related global providers are needed.
// For now, let's leave it to signify its previous role.
// If we add other global navigation states (e.g., for sidebar visibility on desktop, though that's often local state),
// they could go here.

// Add a log to indicate this file is now lean
// ignore_for_file: file_names
void navigationProviderLog() {
  debugPrint(
    "[navigation_provider.dart] This provider file has been significantly simplified after GoRouter refactor.",
  );
}
