// lib/core/navigation/main_navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/core/navigation/app_navigation.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // selectedNavIndexProvider might be deprecated
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
// import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart'; // No longer shown here
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';
import 'package:tackle_4_loss/features/more/ui/more_options_sheet_content.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/widgets/beta_banner.dart';

class MainNavigationWrapper extends ConsumerWidget {
  // Changed to ConsumerWidget as didChangeDependencies is removed
  final StatefulNavigationShell navigationShell;

  const MainNavigationWrapper({super.key, required this.navigationShell});

  // This method is no longer needed as GoRouter and StatefulShellRoute handle URL syncing.
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final location = GoRouter.of(context).routeInformationProvider.value.uri.path;
  //   final currentIndex = _getIndexFromLocation(location);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (currentIndex != -1) {
  //       // ref.read(selectedNavIndexProvider.notifier).state = currentIndex;
  //     }
  //   });
  // }

  // This method is no longer needed as GoRouter manages the active branch index.
  // int _getIndexFromLocation(String location) {
  //   switch (location) {
  //     case '/':
  //     case '/news':
  //       return 0;
  //     case '/my-team':
  //       return 1;
  //     case '/schedule':
  //       return 2;
  //     default:
  //       // Check if it's an article detail opened from a main tab
  //       // This logic might need adjustment with GoRouter handling details
  //       final currentDetailId = ref.read(currentDetailArticleIdProvider);
  //       if (currentDetailId != null && location.startsWith('/article/')) {
  //         // Try to retain the underlying tab's index
  //         // This is tricky and might be better handled by GoRouter's state.
  //         // For now, let's assume if detail is shown, index doesn't change from main content.
  //         // This part will be simplified as ArticleDetailScreen is a top-level route.
  //       }
  //       return ref.read(selectedNavIndexProvider); // Fallback or maintain current
  //   }
  // }

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
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
      "[MainNavigationWrapper build] Current navigationShell index: ${navigationShell.currentIndex}",
    );
    ref.watch(realtimeServiceProvider); // Ensure RealtimeService is initialized

    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    // final currentDetailId = ref.watch(currentDetailArticleIdProvider); // No longer used to show ArticleDetailScreen here
    final selectedTeam = ref.watch(selectedTeamNotifierProvider).valueOrNull;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;

    final moreItemIndex = appNavItems.indexWhere(
      (item) => item.label == 'More',
    );

    // The body is now directly the navigationShell, which GoRouter manages.
    // No need for an IndexedStack here.
    // final Widget bodyContent = currentDetailId != null
    //     ? ArticleDetailScreen(articleId: currentDetailId) // This is removed
    //     : navigationShell;

    if (isMobileLayout) {
      // No longer need to check currentDetailId here for AppBar/Scaffold
      // Top-level routes (like ArticleDetailScreen) will build their own Scaffold.
      // This Scaffold is for the Shell routes.
      return Scaffold(
        appBar: GlobalAppBar(
          automaticallyImplyLeading: false,
          leading: null,
          actions: const [],
        ),
        body: navigationShell, // The content for the current tab/branch
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BetaBanner(),
            BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                debugPrint(
                  "[MainNavigationWrapper BottomNavBar onTap] Tapped index: $index",
                );
                if (index == moreItemIndex) {
                  _showMoreOptions(context);
                } else {
                  // Use goBranch to navigate to the branch associated with the tab
                  // This will also update navigationShell.currentIndex
                  navigationShell.goBranch(
                    index,
                    // `initialLocation: true` will reset the branch's navigation stack to its initial route.
                    // This is often desired for bottom navigation tabs.
                    initialLocation: index == navigationShell.currentIndex,
                  );
                }
              },
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items:
                  appNavItems.map((item) {
                    if (item.label == 'My Team' && selectedTeam != null) {
                      return BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 24,
                          width: 24,
                          child: Image.asset(
                            getTeamLogoPath(selectedTeam),
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    item.assetIconPath != null
                                        ? Image.asset(
                                          item.assetIconPath!,
                                          height: 24,
                                          width: 24,
                                        )
                                        : Icon(item.icon),
                          ),
                        ),
                        label: '',
                      );
                    }
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
      );
    } else {
      // Desktop/Tablet Layout
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
      return Scaffold(
        key: scaffoldKey,
        appBar: GlobalAppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open Menu',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          actions: const [],
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
                  selected:
                      i ==
                      navigationShell
                          .currentIndex, // Selection based on shell index
                  selectedColor: Theme.of(context).colorScheme.primary,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(26),
                  onTap: () {
                    Navigator.pop(context); // Close drawer FIRST
                    debugPrint(
                      "[MainNavigationWrapper Drawer onTap] Tapped index: $i",
                    );
                    if (i == moreItemIndex) {
                      _showMoreOptions(context);
                    } else {
                      navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
                      );
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
                    Navigator.pop(context);
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
                    Navigator.pop(context);
                    localeNotifier.setLocale(value);
                  }
                },
                selected: currentLocale.languageCode == 'de',
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                  child:
                      navigationShell, // The content for the current tab/branch
                ),
              ),
            ),
            const BetaBanner(),
          ],
        ),
      );
    }
  }
}
