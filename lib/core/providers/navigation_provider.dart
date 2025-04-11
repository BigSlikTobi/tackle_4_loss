import 'package:flutter_riverpod/flutter_riverpod.dart';

// Holds the currently selected navigation index
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

// Holds the state of the sidebar (expanded or collapsed) for non-mobile layouts
final isSidebarExtendedProvider = StateProvider<bool>(
  (ref) => false,
); // Start collapsed
