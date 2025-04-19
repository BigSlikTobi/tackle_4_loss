import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tackle_4_loss/core/navigation/app_navigation.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart';
import 'package:tackle_4_loss/features/article_detail/logic/article_detail_provider.dart';
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';

// --- Import the new sheet content widget ---
import 'package:tackle_4_loss/features/more/ui/more_options_sheet_content.dart';

const double kMobileLayoutBreakpoint = 720.0;
const double kMaxContentWidth = 1200.0;

// TeamAwareGlobalAppBar remains the same...
class TeamAwareGlobalAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final List<Widget>? actions;

  const TeamAwareGlobalAppBar({
    super.key,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTeamState = ref.watch(selectedTeamNotifierProvider);
    final String? teamId = selectedTeamState.maybeWhen(
      data: (id) => id,
      orElse: () => null,
    );

    return GlobalAppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      teamId: teamId,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainNavigationWrapper extends ConsumerWidget {
  const MainNavigationWrapper({super.key});

  // --- Helper to show the bottom sheet ---
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // Make it scrollable if content overflows
      isScrollControlled: true,
      // Give it rounded corners matching the theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      // Use a builder to return the content widget
      builder: (BuildContext sheetContext) {
        // Pass the context from the builder
        return const MoreOptionsSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(realtimeServiceProvider);

    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final currentDetailId = ref.watch(currentDetailArticleIdProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;

    final screens = appNavItems.map((item) => item.screen).toList();

    // --- Find the index of the "More" item ---
    final moreItemIndex = appNavItems.indexWhere(
      (item) => item.label == 'More',
    );

    final Widget mainIndexedStack = IndexedStack(
      index: selectedIndex,
      children: screens,
    );

    final Widget bodyContent =
        currentDetailId != null
            ? ArticleDetailScreen(articleId: currentDetailId)
            : mainIndexedStack;

    // --- Build Mobile Layout ---
    if (isMobileLayout) {
      return Scaffold(
        appBar: TeamAwareGlobalAppBar(
          // AppBar setup remains the same...
          automaticallyImplyLeading: false,
          leading: null,
          actions: [
            if (currentDetailId != null) ...[
              // Share/Refresh actions remain...
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed:
                    () =>
                        ref.invalidate(articleDetailProvider(currentDetailId)),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share Article',
                onPressed: () async {
                  final articleAsyncValue = ref.read(
                    articleDetailProvider(currentDetailId),
                  );
                  final article = articleAsyncValue.valueOrNull;

                  if (article != null) {
                    final headline = article.getLocalizedHeadline(
                      currentLocale.languageCode,
                    );
                    final url = article.sourceUrl;
                    final shareText =
                        url != null ? '$headline\n\n$url' : headline;
                    try {
                      await Share.share(shareText);
                    } catch (e) {
                      debugPrint("Error sharing: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not start sharing.'),
                          ),
                        );
                      }
                    }
                  } else {
                    debugPrint("Share pressed but article data not available.");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Article not loaded yet.'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ],
        ),
        bottomNavigationBar:
            currentDetailId ==
                    null // Only show nav bar if not in detail view
                ? BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    // --- If "More" is tapped, show sheet, otherwise navigate ---
                    if (index == moreItemIndex) {
                      _showMoreOptions(context);
                    } else {
                      ref.read(currentDetailArticleIdProvider.notifier).state =
                          null;
                      ref.read(selectedNavIndexProvider.notifier).state = index;
                    }
                    // --- End modification ---
                  },
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items:
                      appNavItems.asMap().entries.map((entry) {
                        final item = entry.value;
                        // My Team Logo logic remains the same...
                        if (item.label == 'My Team') {
                          final selectedTeamState = ref.watch(
                            selectedTeamNotifierProvider,
                          );
                          final String? teamId = selectedTeamState.maybeWhen(
                            data: (id) => id,
                            orElse: () => null,
                          );
                          if (teamId != null &&
                              teamLogoMap.containsKey(teamId)) {
                            debugPrint(
                              'BottomNav: Showing team logo for My Team tab: teamId=' +
                                  teamId,
                            );
                            return BottomNavigationBarItem(
                              icon: Image.asset(
                                'assets/team_logos/' +
                                    teamLogoMap[teamId]! +
                                    '.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                    'BottomNav: Error loading team logo for teamId=' +
                                        teamId,
                                  );
                                  return Icon(item.icon);
                                },
                              ),
                              label: '',
                            );
                          } else {
                            debugPrint(
                              'BottomNav: No team selected, using default icon for My Team tab',
                            );
                            return BottomNavigationBarItem(
                              icon: Icon(item.icon),
                              label: '',
                            );
                          }
                        } else {
                          return BottomNavigationBarItem(
                            icon: Icon(item.icon),
                            label: '',
                          );
                        }
                      }).toList(),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Colors.grey[600],
                )
                : null,
        body: bodyContent,
      );
    }
    // --- Build Desktop/Tablet Layout ---
    else {
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

      return Scaffold(
        key: scaffoldKey,
        appBar: TeamAwareGlobalAppBar(
          // AppBar setup remains the same...
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open Menu',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            if (currentDetailId != null) ...[
              // Share/Refresh actions remain...
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed:
                    () =>
                        ref.invalidate(articleDetailProvider(currentDetailId)),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share Article',
                onPressed: () async {
                  final articleAsyncValue = ref.read(
                    articleDetailProvider(currentDetailId),
                  );
                  final article = articleAsyncValue.valueOrNull;

                  if (article != null) {
                    final headline = article.getLocalizedHeadline(
                      currentLocale.languageCode,
                    );
                    final url = article.sourceUrl;
                    final shareText =
                        url != null ? '$headline\n\n$url' : headline;
                    try {
                      final box = context.findRenderObject() as RenderBox?;
                      await Share.share(
                        shareText,
                        sharePositionOrigin:
                            box != null
                                ? box.localToGlobal(Offset.zero) & box.size
                                : null,
                      );
                    } catch (e) {
                      debugPrint("Error sharing: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not start sharing.'),
                          ),
                        );
                      }
                    }
                  } else {
                    debugPrint("Share pressed but article data not available.");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Article not loaded yet.'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ],
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
                  leading: Icon(appNavItems[i].icon),
                  title: Text(appNavItems[i].label),
                  selected: i == selectedIndex && currentDetailId == null,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  selectedTileColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(26),
                  onTap: () {
                    // --- Close drawer FIRST ---
                    Navigator.pop(context);
                    // --- If "More" is tapped, show sheet, otherwise navigate ---
                    if (i == moreItemIndex) {
                      // Use a slight delay if needed, otherwise call directly
                      // Future.delayed(Duration(milliseconds: 100), () {
                      _showMoreOptions(context);
                      // });
                    } else {
                      ref.read(currentDetailArticleIdProvider.notifier).state =
                          null;
                      ref.read(selectedNavIndexProvider.notifier).state = i;
                    }
                    // --- End modification ---
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
                  if (value != null && currentLocale != value) {
                    Navigator.pop(context); // Pop drawer first
                    localeNotifier.setLocale(value);
                  } else if (value != null) {
                    Navigator.pop(context); // Pop drawer even if no change
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
                  if (value != null && currentLocale != value) {
                    Navigator.pop(context); // Pop drawer first
                    localeNotifier.setLocale(value);
                  } else if (value != null) {
                    Navigator.pop(context); // Pop drawer even if no change
                  }
                },
                selected: currentLocale.languageCode == 'de',
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: bodyContent,
          ),
        ),
      );
    }
  }
}
