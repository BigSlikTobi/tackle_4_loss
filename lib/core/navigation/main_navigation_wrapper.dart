import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/core/navigation/app_navigation.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
// --- Use GlobalAppBar directly ---
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart';
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';
import 'package:tackle_4_loss/features/more/ui/more_options_sheet_content.dart';
// --- Import Layout Constants ---
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
// --- Import Beta Banner ---
import 'package:tackle_4_loss/core/widgets/beta_banner.dart';

class MainNavigationWrapper extends ConsumerStatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  ConsumerState<MainNavigationWrapper> createState() =>
      _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends ConsumerState<MainNavigationWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Sync URL with navigation state
    final location =
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    final currentIndex = _getIndexFromLocation(location);

    // Update navigation state if URL changed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentIndex != -1) {
        ref.read(selectedNavIndexProvider.notifier).state = currentIndex;
      }
    });
  }

  int _getIndexFromLocation(String location) {
    switch (location) {
      case '/':
      case '/news':
        return 0; // News Feed
      case '/my-team':
        return 1; // My Team
      case '/schedule':
        return 2; // Schedule
      default:
        return -1; // Unknown route
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext sheetContext) {
        return const MoreOptionsSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Initialize Realtime Service (ensure it runs) ---
    // Reading the provider ensures its initialization logic runs if not already done.
    ref.watch(realtimeServiceProvider);
    // --- End Realtime Service Init ---

    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final currentDetailId = ref.watch(currentDetailArticleIdProvider);
    final selectedTeam = ref.watch(selectedTeamNotifierProvider).valueOrNull;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;

    final screens = appNavItems.map((item) => item.screen).toList();
    final moreItemIndex = appNavItems.indexWhere(
      (item) => item.label == 'More',
    );

    final Widget mainIndexedStack = IndexedStack(
      index: selectedIndex,
      children: screens,
    );

    // If showing detail, the ArticleDetailScreen provides its own Scaffold/AppBar
    // If showing main stack, MainNavigationWrapper provides the Scaffold/AppBar
    final Widget bodyContent =
        currentDetailId != null
            ? ArticleDetailScreen(articleId: currentDetailId)
            : mainIndexedStack;

    // --- Build Mobile Layout ---
    if (isMobileLayout) {
      // Only build Scaffold/AppBar if NOT showing detail view
      if (currentDetailId != null) {
        return bodyContent; // ArticleDetailScreen has its own Scaffold
      }

      // --- Scaffold for Mobile Main View ---
      return Scaffold(
        // --- Use GlobalAppBar directly ---
        appBar: GlobalAppBar(
          // No title needed here, defaults to app logo
          automaticallyImplyLeading: false, // No back button on main screens
          leading: null, // No menu button on mobile
          actions: const [], // No actions needed on main mobile bar
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Beta banner above bottom navigation on mobile
            const BetaBanner(),
            BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                if (index == moreItemIndex) {
                  _showMoreOptions(context);
                } else {
                  ref.read(currentDetailArticleIdProvider.notifier).state =
                      null;
                  ref.read(selectedNavIndexProvider.notifier).state = index;

                  // Update URL based on selected index
                  final router = GoRouter.of(context);
                  switch (index) {
                    case 0:
                      router.go('/');
                      break;
                    case 1:
                      router.go('/my-team');
                      break;
                    case 2:
                      router.go('/schedule');
                      break;
                  }
                }
              },
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items:
                  appNavItems.map((item) {
                    // If this is the "My Team" item and user has a selected team, show team logo
                    if (item.label == 'My Team' && selectedTeam != null) {
                      return BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 24,
                          width: 24,
                          child: Image.asset(
                            getTeamLogoPath(selectedTeam),
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to default icon if team logo can't be loaded
                              return item.assetIconPath != null
                                  ? Image.asset(
                                    item.assetIconPath!,
                                    height: 24,
                                    width: 24,
                                  )
                                  : Icon(item.icon);
                            },
                          ),
                        ),
                        label: '', // Keep labels empty
                      );
                    }
                    // Use asset icon if provided
                    if (item.assetIconPath != null) {
                      return BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 24,
                          width: 24,
                          child: Image.asset(
                            item.assetIconPath!,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    item.icon != null
                                        ? Icon(item.icon)
                                        : const Icon(Icons.help_outline),
                          ),
                        ),
                        label: '',
                      );
                    }
                    // Fallback to IconData
                    return BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: '',
                    );
                  }).toList(),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey[600],
            ),
          ],
        ),
        body: bodyContent, // This is the IndexedStack
      );
    }
    // --- Build Desktop/Tablet Layout ---
    else {
      // Only build Scaffold/AppBar if NOT showing detail view
      if (currentDetailId != null) {
        return bodyContent; // ArticleDetailScreen has its own Scaffold
      }

      // --- Scaffold for Desktop/Tablet Main View ---
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

      return Scaffold(
        key: scaffoldKey,
        // --- Use GlobalAppBar directly ---
        appBar: GlobalAppBar(
          // No title needed here, defaults to app logo
          automaticallyImplyLeading: false, // We provide custom leading
          leading: IconButton(
            // Menu button to open drawer
            icon: const Icon(Icons.menu),
            tooltip: 'Open Menu',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          actions: const [], // No actions needed on main desktop bar
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).appBarTheme.backgroundColor ??
                      Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Image.asset('assets/images/logo.jpg', height: 150),
                ),
              ),
              for (int i = 0; i < appNavItems.length; i++)
                ListTile(
                  leading:
                      i == 1 && selectedTeam != null
                          ? Image.asset(
                            getTeamLogoPath(selectedTeam),
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to asset icon or IconData
                              final item = appNavItems[i];
                              if (item.assetIconPath != null) {
                                return Image.asset(
                                  item.assetIconPath!,
                                  height: 24,
                                  width: 24,
                                );
                              }
                              return item.icon != null
                                  ? Icon(item.icon)
                                  : const Icon(Icons.help_outline);
                            },
                          )
                          : appNavItems[i].assetIconPath != null
                          ? Image.asset(
                            appNavItems[i].assetIconPath!,
                            height: 24,
                            width: 24,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    appNavItems[i].icon != null
                                        ? Icon(appNavItems[i].icon)
                                        : const Icon(Icons.help_outline),
                          )
                          : Icon(appNavItems[i].icon),
                  title: Text(appNavItems[i].label),
                  selected: i == selectedIndex, // Selection based on index only
                  selectedColor: Theme.of(context).colorScheme.primary,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(26),
                  onTap: () {
                    Navigator.pop(context); // Close drawer FIRST
                    if (i == moreItemIndex) {
                      _showMoreOptions(context);
                    } else {
                      ref.read(currentDetailArticleIdProvider.notifier).state =
                          null;
                      ref.read(selectedNavIndexProvider.notifier).state = i;

                      // Update URL based on selected index
                      final router = GoRouter.of(context);
                      switch (i) {
                        case 0:
                          router.go('/');
                          break;
                        case 1:
                          router.go('/my-team');
                          break;
                        case 2:
                          router.go('/schedule');
                          break;
                      }
                    }
                  },
                ),
              const Divider(indent: 16, endIndent: 16),
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  "Language / Sprache",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    Navigator.pop(context); // Pop drawer first
                    localeNotifier.setLocale(value);
                  }
                },
                selected: currentLocale.languageCode == 'en',
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              RadioListTile<Locale>(
                title: const Text('Deutsch'),
                value: const Locale('de'),
                groupValue: currentLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    Navigator.pop(context); // Pop drawer first
                    localeNotifier.setLocale(value);
                  }
                },
                selected: currentLocale.languageCode == 'de',
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        // --- Apply layout constraints to body ---
        body: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                  child: bodyContent, // This is the IndexedStack
                ),
              ),
            ),
            // Beta banner at bottom for desktop/web
            const BetaBanner(),
          ],
        ),
      );
    }
  }
}
