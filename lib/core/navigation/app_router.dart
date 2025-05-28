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

// Utility function to create TeamInfo from teamId (remains the same)
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
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        debugPrint(
          "[GoRouter StatefulShellRoute.builder] Building MainNavigationWrapper. Current shell index: ${navigationShell.currentIndex}, Shell location: ${state.uri}",
        );
        return MainNavigationWrapper(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _shellNavigatorNewsKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) {
                debugPrint(
                  "[GoRouter ShellBranch News ('/')] Building NewsFeedScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                );
                return const NoTransitionPage(child: NewsFeedScreen());
              },
            ),
            GoRoute(
              path: '/news',
              name: 'news',
              pageBuilder: (context, state) {
                debugPrint(
                  "[GoRouter ShellBranch News ('/news')] Building NewsFeedScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                );
                return const NoTransitionPage(child: NewsFeedScreen());
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMyTeamKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/my-team',
              name: 'my-team',
              pageBuilder: (context, state) {
                debugPrint(
                  "[GoRouter ShellBranch MyTeam] Building MyTeamScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                );
                return const NoTransitionPage(child: MyTeamScreen());
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorScheduleKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/schedule',
              name: 'schedule',
              pageBuilder: (context, state) {
                debugPrint(
                  "[GoRouter ShellBranch Schedule] Building ScheduleScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
                );
                return const NoTransitionPage(child: ScheduleScreen());
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMoreKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/more-placeholder',
              name: 'more-placeholder',
              pageBuilder: (context, state) {
                debugPrint(
                  "[GoRouter ShellBranch More] Building More placeholder. Path: ${state.uri}, FullPath: ${state.fullPath}",
                );
                return const NoTransitionPage(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/all-news',
      name: 'all-news',
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building AllNewsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const AllNewsScreen();
      },
    ),
    GoRoute(
      path: '/teams',
      name: 'teams',
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building TeamsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const TeamsScreen();
      },
    ),
    GoRoute(
      path: '/standings',
      name: 'standings',
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building StandingsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const StandingsScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building SettingsScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/terms-privacy',
      name: 'terms-privacy',
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building TermsPrivacyScreen. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return const TermsPrivacyScreen();
      },
    ),
    GoRoute(
      path: '/article/:articleId',
      name: 'article-detail',
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
          "[GoRouter TopLevelRoute] Building ArticleDetailScreen for ID: $articleId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return ArticleDetailScreen(articleId: articleId);
      },
    ),
    GoRoute(
      path: '/team/:teamId',
      name: 'team-detail',
      builder: (context, state) {
        final teamId = state.pathParameters['teamId']!;
        final teamInfo = createTeamInfoFromId(teamId);
        debugPrint(
          "[GoRouter TopLevelRoute] Building TeamDetailScreen for ID: $teamId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return TeamDetailScreen(teamInfo: teamInfo);
      },
    ),
    GoRoute(
      path: '/cluster/:clusterId',
      name: 'cluster-detail',
      builder: (context, state) {
        final clusterId = state.pathParameters['clusterId']!;
        debugPrint(
          "[GoRouter TopLevelRoute] Building ClusterDetailScreen for ID: $clusterId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return ClusterDetailScreen(clusterId: clusterId);
      },
    ),
    GoRoute(
      path: '/cluster-article/:clusterArticleId',
      name: 'cluster-article-detail',
      builder: (context, state) {
        final clusterArticleId = state.pathParameters['clusterArticleId']!;
        debugPrint(
          "[GoRouter TopLevelRoute] Building ClusterArticleDetailScreen for ID: $clusterArticleId. Path: ${state.uri}, FullPath: ${state.fullPath}",
        );
        return ClusterArticleDetailScreen(clusterArticleId: clusterArticleId);
      },
    ),
    GoRoute(
      path: '/sitemap.xml',
      name: 'sitemap',
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building Sitemap placeholder. Path: ${state.uri}, FullPath: ${state.fullPath}",
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
      builder: (context, state) {
        debugPrint(
          "[GoRouter TopLevelRoute] Building Robots placeholder. Path: ${state.uri}, FullPath: ${state.fullPath}",
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
              'Page not found: ${state.error?.message ?? state.uri.toString()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  },
);

final routerProvider = Provider<GoRouter>((ref) => appRouter);
