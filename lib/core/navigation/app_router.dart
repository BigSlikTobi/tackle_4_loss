// lib/core/navigation/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/navigation/main_navigation_wrapper.dart';
import 'package:tackle_4_loss/features/news_feed/ui/news_feed_screen.dart';
import 'package:tackle_4_loss/features/my_team/ui/my_team_screen.dart';
import 'package:tackle_4_loss/features/schedule/ui/schedule_screen.dart';
import 'package:tackle_4_loss/features/all_news/ui/all_news_screen.dart';
import 'package:tackle_4_loss/features/teams/ui/teams_screen.dart';
import 'package:tackle_4_loss/features/standings/ui/standings_screen.dart';
import 'package:tackle_4_loss/features/settings/ui/settings_screen.dart';
import 'package:tackle_4_loss/features/terms_privacy/ui/terms_privacy_screen.dart';
import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart';
import 'package:tackle_4_loss/features/teams/ui/team_detail_screen.dart';
import 'package:tackle_4_loss/features/cluster_detail/ui/cluster_detail_screen.dart';
import 'package:tackle_4_loss/features/news_feed/ui/cluster_article_detail_screen.dart';
import 'package:tackle_4_loss/features/teams/data/team_info.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';

TeamInfo createTeamInfoFromId(String teamId) {
  final fullName = getTeamFullName(teamId);
  final Map<String, Map<String, String>> teamDivisions = {
    'BUF': {'conference': 'AFC', 'division': 'AFC East'},
    'MIA': {'conference': 'AFC', 'division': 'AFC East'},
    'NE': {'conference': 'AFC', 'division': 'AFC East'},
    'NYJ': {'conference': 'AFC', 'division': 'AFC East'},
    'BAL': {'conference': 'AFC', 'division': 'AFC North'},
    'CIN': {'conference': 'AFC', 'division': 'AFC North'},
    'CLE': {'conference': 'AFC', 'division': 'AFC North'},
    'PIT': {'conference': 'AFC', 'division': 'AFC North'},
    'HOU': {'conference': 'AFC', 'division': 'AFC South'},
    'IND': {'conference': 'AFC', 'division': 'AFC South'},
    'JAC': {'conference': 'AFC', 'division': 'AFC South'},
    'TEN': {'conference': 'AFC', 'division': 'AFC South'},
    'DEN': {'conference': 'AFC', 'division': 'AFC West'},
    'KC': {'conference': 'AFC', 'division': 'AFC West'},
    'LV': {'conference': 'AFC', 'division': 'AFC West'},
    'LAC': {'conference': 'AFC', 'division': 'AFC West'},
    'DAL': {'conference': 'NFC', 'division': 'NFC East'},
    'NYG': {'conference': 'NFC', 'division': 'NFC East'},
    'PHI': {'conference': 'NFC', 'division': 'NFC East'},
    'WAS': {'conference': 'NFC', 'division': 'NFC East'},
    'CHI': {'conference': 'NFC', 'division': 'NFC North'},
    'DET': {'conference': 'NFC', 'division': 'NFC North'},
    'GB': {'conference': 'NFC', 'division': 'NFC North'},
    'MIN': {'conference': 'NFC', 'division': 'NFC North'},
    'ATL': {'conference': 'NFC', 'division': 'NFC South'},
    'CAR': {'conference': 'NFC', 'division': 'NFC South'},
    'NO': {'conference': 'NFC', 'division': 'NFC South'},
    'TB': {'conference': 'NFC', 'division': 'NFC South'},
    'ARI': {'conference': 'NFC', 'division': 'NFC West'},
    'LAR': {'conference': 'NFC', 'division': 'NFC West'},
    'SF': {'conference': 'NFC', 'division': 'NFC West'},
    'SEA': {'conference': 'NFC', 'division': 'NFC West'},
  };
  final teamInfoData = teamDivisions[teamId.toUpperCase()];
  return TeamInfo(
    teamId: teamId.toUpperCase(),
    fullName: fullName,
    division: teamInfoData?['division'] ?? 'Unknown Division',
    conference: teamInfoData?['conference'] ?? 'Unknown Conference',
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

// Navigator keys for the branches of the StatefulShellRoute
final GlobalKey<NavigatorState> _shellNavigatorNewsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellNews');
final GlobalKey<NavigatorState> _shellNavigatorMyTeamKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellMyTeam');
final GlobalKey<NavigatorState> _shellNavigatorScheduleKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSchedule');
final GlobalKey<NavigatorState> _shellNavigatorMoreKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellMore');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      '/app/news', // Default to the news screen within the app shell
  debugLogDiagnostics: kDebugMode,
  routes: [
    // Redirect from the root '/' to the default shell path '/app/news'
    GoRoute(
      path: '/',
      redirect: (_, __) {
        debugPrint("[GoRouter Redirect] Redirecting from '/' to '/app/news'");
        return '/app/news'; // Redirect to the default nested route
      },
    ),

    // This GoRoute now acts as the parent for the shell, establishing the '/app' base path.
    GoRoute(
      path: '/app',
      // This parent GoRoute for the shell does not need a builder itself if all its children (the branches)
      // are defined within the StatefulShellRoute.
      // Or, if '/app' itself should be navigable and redirect, it can do that.
      // For initialLocation '/app/news', we need a way for '/app' to resolve.
      // One way is to redirect '/app' to '/app/news'.
      redirect: (context, state) {
        // If the user navigates to just '/app', redirect them to the default news tab.
        if (state.uri.toString() == '/app') {
          debugPrint(
            "[GoRouter Redirect] Redirecting from '/app' to '/app/news'",
          );
          return '/app/news';
        }
        return null; // No redirect if path is more specific like /app/news
      },
      routes: [
        // The StatefulShellRoute is now a child of the '/app' GoRoute
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            debugPrint(
              "[GoRouter StatefulShellRoute.builder under /app] Building MainNavigationWrapper. Current shell index: ${navigationShell.currentIndex}, Shell effective path: ${state.uri}, matchedLocation: ${state.matchedLocation}",
            );
            return MainNavigationWrapper(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            // Branch 1: News Feed
            StatefulShellBranch(
              navigatorKey: _shellNavigatorNewsKey,
              routes: <RouteBase>[
                GoRoute(
                  path:
                      'news', // Path is now relative to '/app', so full path is '/app/news'
                  name: 'app-news', // Unique name
                  pageBuilder: (context, state) {
                    debugPrint(
                      "[GoRouter ShellBranch News ('/app/news')] Building NewsFeedScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                    );
                    return const NoTransitionPage(child: NewsFeedScreen());
                  },
                ),
              ],
            ),

            // Branch 2: My Team
            StatefulShellBranch(
              navigatorKey: _shellNavigatorMyTeamKey,
              routes: <RouteBase>[
                GoRoute(
                  path: 'my-team', // Relative, full path is '/app/my-team'
                  name: 'app-my-team',
                  pageBuilder: (context, state) {
                    debugPrint(
                      "[GoRouter ShellBranch MyTeam ('/app/my-team')] Building MyTeamScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                    );
                    return const NoTransitionPage(child: MyTeamScreen());
                  },
                ),
              ],
            ),

            // Branch 3: Schedule
            StatefulShellBranch(
              navigatorKey: _shellNavigatorScheduleKey,
              routes: <RouteBase>[
                GoRoute(
                  path: 'schedule', // Relative, full path is '/app/schedule'
                  name: 'app-schedule',
                  pageBuilder: (context, state) {
                    debugPrint(
                      "[GoRouter ShellBranch Schedule ('/app/schedule')] Building ScheduleScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                    );
                    return const NoTransitionPage(child: ScheduleScreen());
                  },
                ),
              ],
            ),

            // Branch 4: More (placeholder)
            StatefulShellBranch(
              navigatorKey: _shellNavigatorMoreKey,
              routes: <RouteBase>[
                GoRoute(
                  path:
                      'more-placeholder', // Relative, full path is '/app/more-placeholder'
                  name: 'app-more-placeholder',
                  pageBuilder: (context, state) {
                    debugPrint(
                      "[GoRouter ShellBranch More ('/app/more-placeholder')] Building More placeholder. Path: ${state.uri}, FullPath: ${state.fullPath}",
                    );
                    return const NoTransitionPage(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // --- Top-level routes (screens without the main navigation shell) ---
    // These are siblings to the '/app' route.
    GoRoute(
      path: '/all-news',
      name: 'all-news',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /all-news] Building AllNewsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const AllNewsScreen();
      },
    ),
    GoRoute(
      path: '/teams',
      name: 'teams',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /teams] Building TeamsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const TeamsScreen();
      },
    ),
    GoRoute(
      path: '/standings',
      name: 'standings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /standings] Building StandingsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const StandingsScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /settings] Building SettingsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/terms-privacy',
      name: 'terms-privacy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /terms-privacy] Building TermsPrivacyScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const TermsPrivacyScreen();
      },
    ),
    GoRoute(
      path: '/article/:articleId',
      name: 'article-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final articleIdStr = state.pathParameters['articleId']!;
        final articleId = int.tryParse(articleIdStr);
        if (articleId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Invalid article ID')),
          );
        }
        debugPrint(
          "[GoRouter TopLevelRoute /article/:articleId] Building ArticleDetailScreen for ID: $articleId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return ArticleDetailScreen(articleId: articleId);
      },
    ),
    GoRoute(
      path: '/team/:teamId',
      name: 'team-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final teamId = state.pathParameters['teamId']!;
        final teamInfo = createTeamInfoFromId(teamId);
        debugPrint(
          "[GoRouter TopLevelRoute /team/:teamId] Building TeamDetailScreen for ID: $teamId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return TeamDetailScreen(teamInfo: teamInfo);
      },
    ),
    GoRoute(
      path: '/cluster/:clusterId',
      name: 'cluster-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final clusterId = state.pathParameters['clusterId']!;
        debugPrint(
          "[GoRouter TopLevelRoute /cluster/:clusterId] Building ClusterDetailScreen for ID: $clusterId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return ClusterDetailScreen(clusterId: clusterId);
      },
    ),
    GoRoute(
      path: '/cluster-article/:clusterArticleId',
      name: 'cluster-article-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final clusterArticleId = state.pathParameters['clusterArticleId']!;
        debugPrint(
          "[GoRouter TopLevelRoute /cluster-article/:id] Building ClusterArticleDetailScreen for ID: $clusterArticleId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return ClusterArticleDetailScreen(clusterArticleId: clusterArticleId);
      },
    ),
    GoRoute(
      path: '/sitemap.xml',
      name: 'sitemap',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /sitemap.xml] Building Sitemap placeholder. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return Scaffold(
          appBar: AppBar(title: const Text('Sitemap')),
          body: const Center(
            child: Text('Sitemap.xml is served by the web server.'),
          ),
        );
      },
    ),
    GoRoute(
      path: '/robots.txt',
      name: 'robots',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute /robots.txt] Building Robots placeholder. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return Scaffold(
          appBar: AppBar(title: const Text('Robots')),
          body: const Center(
            child: Text('Robots.txt is served by the web server.'),
          ),
        );
      },
    ),
  ],
  errorBuilder: (context, state) {
    debugPrint(
      "[GoRouter ErrorBuilder] Page not found. Error: ${state.error}, Uri: ${state.uri}, FullPath: ${state.fullPath}",
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found for ${state.uri}: ${state.error?.message ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () =>
                      context.go('/app/news'), // Go to the default shell route
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  },
);

final routerProvider = Provider<GoRouter>((ref) => appRouter);
