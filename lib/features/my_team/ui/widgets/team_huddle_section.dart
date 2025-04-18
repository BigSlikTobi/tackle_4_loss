// lib/features/my_team/ui/widgets/team_huddle_section.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/my_team/ui/widgets/upcoming_games_card.dart';
import 'package:tackle_4_loss/features/my_team/ui/widgets/injury_report_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/headline_story_card.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart'; // Import constants
import 'package:tackle_4_loss/core/navigation/main_navigation_wrapper.dart';

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

    // Get logo path using the helper function
    final logoPath = getTeamLogoPath(teamId);
    // Get full name using the helper function (optional if not used in header)
    // final teamFullName = getTeamFullName(teamId);

    // Calculate darker background color
    final Color sectionBackgroundColor = Color.alphaBlend(
      // Use Color.fromARGB instead of withOpacity
      Color.fromARGB((255 * 0.05).round(), 0, 0, 0),
      theme.canvasColor,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4.0,
        // Use Color.fromARGB instead of withOpacity
        shadowColor: Color.fromARGB((255 * 0.2).round(), 0, 0, 0),
        color: sectionBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Header (Logo + "Team Huddle") ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Row(
                children: [
                  // --- CORRECT USAGE ---
                  Image.asset(
                    logoPath, // Use the path directly from the helper function
                    height: 32,
                    width: 32,
                    errorBuilder:
                        (ctx, err, st) => const SizedBox(width: 32, height: 32),
                  ),
                  // --- END CORRECTION ---
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

            // --- Headline Story or No News Available UI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  headlineArticle != null
                      ? HeadlineStoryCard(article: headlineArticle!)
                      : _buildNoNewsAvailableCard(context, logoPath),
            ),

            // --- Expandable Games and Injury Cards ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: _buildTeamInfoSubSection(context, isMobileLayout, teamId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoNewsAvailableCard(BuildContext context, String logoPath) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Adding logging to validate logo path
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
                // Use a larger size for the logo and add better error handling
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) {
                      // Log error for debugging
                      debugPrint('TeamHuddleSection: Error loading logo: $err');

                      // First fallback: Try using a direct reference to the team logo
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
                            // Second fallback: Display NFL logo as a last resort
                            debugPrint(
                              'TeamHuddleSection: Falling back to NFL logo',
                            );
                            return Image.asset(
                              'assets/team_logos/nfl.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx3, err3, st3) {
                                // Final fallback: If all image attempts fail, show team abbreviation
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.primary.withAlpha(
                                      (255 * 0.1).round(),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      teamId.toUpperCase(),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      // If paths are the same, go directly to NFL logo
                      return Image.asset(
                        'assets/team_logos/nfl.png',
                        fit: BoxFit.contain,
                        errorBuilder: (ctx3, err3, st3) {
                          // Final fallback: If all image attempts fail, show team abbreviation
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withAlpha(
                                (255 * 0.1).round(),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                teamId.toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "currently no News available...",
                  style: textTheme.titleMedium?.copyWith(
                    // Use Color.alphaBlend for text color opacity
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
    const cardSpacing = 12.0;
    if (isMobile) {
      return Column(
        children: [
          UpcomingGamesCard(teamId: teamId),
          const SizedBox(height: cardSpacing),
          InjuryReportCard(teamId: teamId),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: UpcomingGamesCard(teamId: teamId)),
          const SizedBox(width: cardSpacing),
          Expanded(child: InjuryReportCard(teamId: teamId)),
        ],
      );
    }
  }
}
