import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/navigation/main_navigation_wrapper.dart';
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

// Utility function to create TeamInfo from teamId
TeamInfo createTeamInfoFromId(String teamId) {
  final fullName = getTeamFullName(teamId);

  // Simple division/conference mapping based on well-known data
  // In a real app, this would come from a database or API
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

  final teamInfo = teamDivisions[teamId.toUpperCase()];

  return TeamInfo(
    teamId: teamId.toUpperCase(),
    fullName: fullName,
    division: teamInfo?['division'] ?? 'Unknown Division',
    conference: teamInfo?['conference'] ?? 'Unknown Conference',
  );
}

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  routes: [
    // Main shell route - this contains the primary navigation structure
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationWrapper();
      },
      routes: [
        // Home/News Feed
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder:
              (context, state) => const NoTransitionPage(
                child:
                    SizedBox.shrink(), // MainNavigationWrapper handles the content
              ),
        ),

        // News Feed (explicit route)
        GoRoute(
          path: '/news',
          name: 'news',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: SizedBox.shrink()),
        ),

        // My Team
        GoRoute(
          path: '/my-team',
          name: 'my-team',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: SizedBox.shrink()),
        ),

        // Schedule
        GoRoute(
          path: '/schedule',
          name: 'schedule',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: SizedBox.shrink()),
        ),
      ],
    ),

    // Routes that need their own screens (outside the main navigation)
    // All News
    GoRoute(
      path: '/all-news',
      name: 'all-news',
      builder: (context, state) => AllNewsScreen(),
    ),

    // Teams
    GoRoute(
      path: '/teams',
      name: 'teams',
      builder: (context, state) => TeamsScreen(),
    ),

    // Standings
    GoRoute(
      path: '/standings',
      name: 'standings',
      builder: (context, state) => StandingsScreen(),
    ),

    // Settings
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => SettingsScreen(),
    ),

    // Terms & Privacy
    GoRoute(
      path: '/terms-privacy',
      name: 'terms-privacy',
      builder: (context, state) => TermsPrivacyScreen(),
    ),

    // Article Detail
    GoRoute(
      path: '/article/:articleId',
      name: 'article-detail',
      builder: (context, state) {
        final articleIdStr = state.pathParameters['articleId']!;
        final articleId = int.tryParse(articleIdStr);
        if (articleId == null) {
          // Handle invalid article ID
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Invalid article ID')),
          );
        }
        return ArticleDetailScreen(articleId: articleId);
      },
    ),

    // Team Detail
    GoRoute(
      path: '/team/:teamId',
      name: 'team-detail',
      builder: (context, state) {
        final teamId = state.pathParameters['teamId']!;
        final teamInfo = createTeamInfoFromId(teamId);
        return TeamDetailScreen(teamInfo: teamInfo);
      },
    ),

    // Cluster Detail
    GoRoute(
      path: '/cluster/:clusterId',
      name: 'cluster-detail',
      builder: (context, state) {
        final clusterId = state.pathParameters['clusterId']!;
        return ClusterDetailScreen(clusterId: clusterId);
      },
    ),

    // Cluster Article Detail
    GoRoute(
      path: '/cluster-article/:clusterArticleId',
      name: 'cluster-article-detail',
      builder: (context, state) {
        final clusterArticleId = state.pathParameters['clusterArticleId']!;
        return ClusterArticleDetailScreen(clusterArticleId: clusterArticleId);
      },
    ),

    // Sitemap XML route for SEO
    GoRoute(
      path: '/sitemap.xml',
      name: 'sitemap',
      redirect: (context, state) {
        // For Flutter web, the sitemap.xml file is served directly from the web directory
        // This route exists to ensure GoRouter doesn't handle it as a 404
        // The actual sitemap.xml file will be served by the web server
        return null; // Don't redirect, let the route handle it normally
      },
      builder: (context, state) {
        // This should rarely be called since the web server should serve the static file directly
        return Scaffold(
          appBar: AppBar(title: const Text('Sitemap')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64),
                SizedBox(height: 16),
                Text(
                  'Sitemap XML',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'The sitemap is available for search engines at /sitemap.xml',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    ),

    // Robots.txt route for SEO
    GoRoute(
      path: '/robots.txt',
      name: 'robots',
      redirect: (context, state) {
        // For Flutter web, the robots.txt file is served directly from the web directory
        // This route exists to ensure GoRouter doesn't handle it as a 404
        // The actual robots.txt file will be served by the web server
        return null; // Don't redirect, let the route handle it normally
      },
      builder: (context, state) {
        // This should rarely be called since the web server should serve the static file directly
        return Scaffold(
          appBar: AppBar(title: const Text('Robots')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_toy, size: 64),
                SizedBox(height: 16),
                Text(
                  'Robots.txt',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'The robots.txt file is available for search engines at /robots.txt',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you requested could not be found.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
);

// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) => appRouter);
