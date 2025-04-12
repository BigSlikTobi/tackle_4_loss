// lib/core/navigation/main_navigation_wrapper.dart
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
import 'package:tackle_4_loss/core/providers/realtime_provider.dart'; // <-- Import the new provider

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Ensure RealtimeService is initialized ---
    // Reading the provider here ensures its creation logic runs.
    // Since MainNavigationWrapper is likely always present, this is a decent spot.
    ref.read(realtimeServiceProvider);
    // --- End Initialization ---

    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final currentDetailId = ref.watch(currentDetailArticleIdProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;

    final screens = appNavItems.map((item) => item.screen).toList();

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
      // ... rest of mobile layout remains the same
      return Scaffold(
        appBar: TeamAwareGlobalAppBar(
          automaticallyImplyLeading: false,
          leading: null,
          actions: [
            if (currentDetailId != null) ...[
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
            currentDetailId == null
                ? BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    ref.read(currentDetailArticleIdProvider.notifier).state =
                        null;
                    ref.read(selectedNavIndexProvider.notifier).state = index;
                  },
                  items:
                      appNavItems
                          .map(
                            (item) => BottomNavigationBarItem(
                              icon: Icon(item.icon),
                              label: item.label,
                            ),
                          )
                          .toList(),
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
      // ... rest of desktop/tablet layout remains the same
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

      return Scaffold(
        key: scaffoldKey,
        appBar: TeamAwareGlobalAppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open Menu',
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            if (currentDetailId != null) ...[
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
                    ref.read(currentDetailArticleIdProvider.notifier).state =
                        null;
                    ref.read(selectedNavIndexProvider.notifier).state = i;
                    Navigator.pop(context);
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
                    Navigator.pop(context);
                    localeNotifier.setLocale(value);
                  } else if (value != null) {
                    Navigator.pop(context);
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
                    Navigator.pop(context);
                    localeNotifier.setLocale(value);
                  } else if (value != null) {
                    Navigator.pop(context);
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
