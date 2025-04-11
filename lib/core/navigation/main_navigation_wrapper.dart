// lib/core/navigation/main_navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/navigation/app_navigation.dart'; // Updated import
import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // Updated import
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart'; // Updated import
import 'package:tackle_4_loss/core/providers/locale_provider.dart'; // Import locale provider
// Assuming AppColors might be needed for Divider or other styling
// Updated import

// Define breakpoints and max width
const double kMobileLayoutBreakpoint = 720.0;
const double kMaxContentWidth = 1200.0; // Max width for the main content area

class MainNavigationWrapper extends ConsumerWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch necessary providers
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);

    // Determine layout based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;

    // Define the list of screens from navigation items
    final screens = appNavItems.map((item) => item.screen).toList();

    // Define the main content widget (IndexedStack)
    // This holds the currently selected screen based on the navigation index
    final Widget mainContent = IndexedStack(
      index: selectedIndex,
      children: screens,
    );

    // --- Build Mobile Layout ---
    if (isMobileLayout) {
      return Scaffold(
        appBar: GlobalAppBar(
          automaticallyImplyLeading:
              false, // No back/menu button on root mobile screen
          // Actions are handled within GlobalAppBar (like language picker)
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap:
              (index) =>
                  ref.read(selectedNavIndexProvider.notifier).state = index,
          items:
              appNavItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
          type:
              BottomNavigationBarType.fixed, // Ensure labels are always visible
          selectedItemColor:
              Theme.of(
                context,
              ).colorScheme.primary, // Use theme color for selection
          unselectedItemColor: Colors.grey[600], // Color for unselected items
          // Consider setting background color if needed:
          // backgroundColor: Theme.of(context).canvasColor,
        ),
        body: mainContent, // Body is just the selected screen on mobile
      );
    }
    // --- Build Desktop/Tablet Layout ---
    else {
      // Key to control the Drawer programmatically
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

      return Scaffold(
        key: scaffoldKey,
        appBar: GlobalAppBar(
          automaticallyImplyLeading: false, // No default back button
          // Provide the hamburger menu icon to open the drawer
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open Menu',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          // Actions (like language picker) are already part of GlobalAppBar
        ),
        // Drawer acts as the sidebar navigation for desktop
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero, // Remove default padding
            children: [
              // Drawer Header with Logo
              DrawerHeader(
                decoration: BoxDecoration(
                  // Use AppBar color or a slightly different shade if desired
                  color:
                      Theme.of(context).appBarTheme.backgroundColor ??
                      Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.jpg', // Ensure this uses the correct logo for the header bg
                    height: 150,
                    // Consider using logo_light.png if header is dark
                  ),
                ),
              ),
              // Standard Navigation List Tiles
              for (int i = 0; i < appNavItems.length; i++)
                ListTile(
                  leading: Icon(appNavItems[i].icon),
                  title: Text(appNavItems[i].label),
                  selected: i == selectedIndex, // Highlight selected item
                  selectedColor: Theme.of(context).colorScheme.primary,
                  selectedTileColor: Theme.of(context).colorScheme.primary
                      .withAlpha(26), // Use integer alpha value (10% of 255)
                  onTap: () {
                    ref.read(selectedNavIndexProvider.notifier).state = i;
                    Navigator.pop(context); // Close the drawer after selection
                  },
                ),
              // Divider before language settings
              const Divider(indent: 16, endIndent: 16),
              // Language Selection Section
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  "Language / Sprache", // Consider localization later if needed
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // English Language Radio Button
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: currentLocale, // Checked state based on provider
                onChanged: (Locale? value) {
                  if (value != null && currentLocale != value) {
                    Navigator.pop(context); // Close drawer FIRST
                    localeNotifier.setLocale(
                      value,
                    ); // Update locale AFTER closing
                  } else if (value != null) {
                    Navigator.pop(context); // Close drawer even if not changing
                  }
                },
                // Make selected item more prominent
                selected: currentLocale.languageCode == 'en',
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              // German Language Radio Button
              RadioListTile<Locale>(
                title: const Text('Deutsch'),
                value: const Locale('de'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null && currentLocale != value) {
                    Navigator.pop(context); // Close drawer FIRST
                    localeNotifier.setLocale(
                      value,
                    ); // Update locale AFTER closing
                  } else if (value != null) {
                    Navigator.pop(context); // Close drawer even if not changing
                  }
                },
                selected: currentLocale.languageCode == 'de',
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        // --- Apply Conditional Constraint to the Body for Desktop ---
        body: Center(
          // 1. Center the constrained box horizontally
          child: ConstrainedBox(
            // 2. Limit the maximum width
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: mainContent, // 3. Display the selected screen (IndexedStack)
          ),
        ),
        // --- End Body Modification ---
      );
    }
  }
}
