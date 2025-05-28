// lib/core/navigation/main_navigation_wrapper.dart
// Quick check: Ensure no lingering selectedNavIndexProvider usage.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/core/navigation/app_navigation.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // selectedNavIndexProvider was here
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';
import 'package:tackle_4_loss/features/more/ui/more_options_sheet_content.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/widgets/beta_banner.dart';

class MainNavigationWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationWrapper({super.key, required this.navigationShell});

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext sheetContext) {
        return MoreOptionsSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
      "[MainNavigationWrapper build] Current navigationShell index: ${navigationShell.currentIndex}. Shell Location: ${GoRouter.of(context).routeInformationProvider.value.uri}",
    );

    ref.watch(realtimeServiceProvider);

    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final selectedTeam = ref.watch(selectedTeamNotifierProvider).valueOrNull;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;

    final moreItemIndex = appNavItems.indexWhere(
      (item) => item.label == 'More',
    );

    if (isMobileLayout) {
      return Scaffold(
        appBar: GlobalAppBar(
          automaticallyImplyLeading: false,
          leading: null,
          actions: const [],
        ),
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BetaBanner(),
            BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                // ref.read(selectedNavIndexProvider.notifier).state = index; // REMOVED: No longer needed to set this
                debugPrint(
                  "[MainNavigationWrapper BottomNavBar onTap] Tapped index: $index. Current shell index: ${navigationShell.currentIndex}",
                );
                if (index == moreItemIndex) {
                  _showMoreOptions(context);
                } else {
                  navigationShell.goBranch(
                    index,
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
                  selected: i == navigationShell.currentIndex,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(26),
                  onTap: () {
                    Navigator.pop(context);
                    // ref.read(selectedNavIndexProvider.notifier).state = i; // REMOVED
                    debugPrint(
                      "[MainNavigationWrapper Drawer onTap] Tapped index: $i. Current shell index: ${navigationShell.currentIndex}",
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
                  child: navigationShell,
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
