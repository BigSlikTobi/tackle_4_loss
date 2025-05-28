// lib/features/my_team/ui/widgets/team_huddle_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/headline_story_card.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
// import 'package:tackle_4_loss/core/navigation/main_navigation_wrapper.dart'; // Removed

class TeamHuddleSection extends StatelessWidget {
  final String teamId;
  final ArticlePreview? headlineArticle;

  const TeamHuddleSection({
    super.key,
    required this.teamId,
    this.headlineArticle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < kMobileLayoutBreakpoint;
    final logoPath = getTeamLogoPath(teamId);
    final Color sectionBackgroundColor = Color.alphaBlend(
      Color.fromARGB((255 * 0.05).round(), 0, 0, 0),
      theme.canvasColor,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4.0,
        shadowColor: Color.fromARGB((255 * 0.2).round(), 0, 0, 0),
        color: sectionBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Row(
                children: [
                  Image.asset(
                    logoPath,
                    height: 32,
                    width: 32,
                    errorBuilder:
                        (ctx, err, st) => const SizedBox(width: 32, height: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Team Huddle",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  headlineArticle != null
                      ? InkWell(
                        // Wrap HeadlineStoryCard with InkWell for navigation
                        onTap: () {
                          debugPrint(
                            "[TeamHuddleSection onTap] Navigating to /article/${headlineArticle!.id}",
                          );
                          context.push('/article/${headlineArticle!.id}');
                        },
                        child: HeadlineStoryCard(article: headlineArticle!),
                      )
                      : _buildNoNewsAvailableCard(context, logoPath, teamId),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: _buildTeamInfoSubSection(context, isMobileLayout, teamId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoNewsAvailableCard(
    BuildContext context,
    String logoPath,
    String teamId,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    debugPrint(
      'TeamHuddleSection: Attempting to load logo from path: $logoPath',
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        shadowColor: Colors.black.withAlpha((255 * 0.2).round()),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: theme.colorScheme.surface,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) {
                      debugPrint('TeamHuddleSection: Error loading logo: $err');
                      final String directPath =
                          'assets/team_logos/${teamLogoMap[teamId.toUpperCase()]?.toLowerCase() ?? 'nfl'}.png';
                      if (directPath != logoPath) {
                        debugPrint(
                          'TeamHuddleSection: Trying alternate path: $directPath',
                        );
                        return Image.asset(
                          directPath,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx2, err2, st2) {
                            debugPrint(
                              'TeamHuddleSection: Falling back to NFL logo',
                            );
                            return Image.asset(
                              'assets/team_logos/nfl.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx3, err3, st3) {
                                return Container(/* Fallback UI */);
                              },
                            );
                          },
                        );
                      }
                      return Image.asset('assets/team_logos/nfl.png' /* ... */);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "currently no Breaking News",
                  style: textTheme.titleMedium?.copyWith(
                    color: Color.alphaBlend(
                      Color.fromARGB((255 * 0.7).round(), 0, 0, 0),
                      theme.colorScheme.onSurface,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfoSubSection(
    BuildContext context,
    bool isMobile,
    String teamId,
  ) {
    if (isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildTabletLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        // UpcomingGamesCard(teamId: teamId),
        // InjuryReportCard(teamId: teamId),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        // Expanded(child: UpcomingGamesCard(teamId: teamId)),
        // Expanded(child: InjuryReportCard(teamId: teamId)),
      ],
    );
  }
}
