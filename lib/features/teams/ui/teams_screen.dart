import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/teams/logic/teams_provider.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/features/teams/ui/team_detail_screen.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTeamsAsync = ref.watch(groupedTeamsProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // --- CORRECT: No title provided, should default to logo ---
      appBar: const GlobalAppBar(),
      body: groupedTeamsAsync.when(
        data: (conferenceGroups) {
          if (conferenceGroups.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: const Text("No teams found."),
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: CustomScrollView(
                slivers: [
                  // Iterate through conferences (AFC, NFC)
                  for (final conferenceGroup in conferenceGroups) ...[
                    // Conference Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          24.0,
                          16.0,
                          8.0,
                        ),
                        child: Text(
                          conferenceGroup.conferenceName,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    // Iterate through divisions within the conference
                    for (final divisionGroup in conferenceGroup.divisions) ...[
                      // Division Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            12.0,
                            16.0,
                            4.0,
                          ),
                          child: Text(
                            divisionGroup.divisionName,
                            style: textTheme.titleLarge,
                          ),
                        ),
                      ),
                      // Team List for the division
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final team =
                              divisionGroup.teams[index]; // team is TeamInfo
                          final logoPath = getTeamLogoPath(team.teamId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            child: Card(
                              elevation: 0.5,
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                leading: Image.asset(
                                  logoPath,
                                  height: 30,
                                  width: 30,
                                  errorBuilder: (ctx, err, st) {
                                    debugPrint(
                                      "Error loading logo $logoPath: $err",
                                    );
                                    return const Icon(
                                      Icons.sports_football,
                                      size: 30,
                                    );
                                  },
                                ),
                                title: Text(team.fullName),
                                // --- Updated onTap ---
                                onTap: () {
                                  debugPrint(
                                    "Navigating to details for ${team.fullName}",
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TeamDetailScreen(
                                            teamInfo: team,
                                          ), // Pass the team object
                                    ),
                                  );
                                },
                                // --- End Updated onTap ---
                              ),
                            ),
                          );
                        }, childCount: divisionGroup.teams.length),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          );
        },
        loading:
            () => Center(
              // Loading/Error states are fine within the new Scaffold body
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: const LoadingIndicator(),
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ErrorMessageWidget(
                    message: 'Failed to load teams: $error',
                    onRetry: () => ref.invalidate(allTeamsProvider),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
