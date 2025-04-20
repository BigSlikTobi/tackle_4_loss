import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart'; // For getTeamLogoPath
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/teams/logic/teams_provider.dart'; // Import providers
// --- Import the new layout constant ---
import 'package:tackle_4_loss/core/constants/layout_constants.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTeamsAsync = ref.watch(groupedTeamsProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: const GlobalAppBar(title: Text('NFL Teams')),
      body: groupedTeamsAsync.when(
        data: (conferenceGroups) {
          if (conferenceGroups.isEmpty) {
            // --- Apply Center/ConstrainedBox to empty state too ---
            // --- FIX: Removed const from Center ---
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: const Text("No teams found."), // Text can be const here
              ),
            );
          }
          // --- Wrap the CustomScrollView ---
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: CustomScrollView(
                slivers: [
                  // Iterate through conferences (AFC, NFC)
                  for (final conferenceGroup in conferenceGroups) ...[
                    // Conference Header - Now with Logo
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          24.0,
                          16.0,
                          8.0,
                        ),
                        child: Row(
                          children: [
                            // Conference Logo
                            Image.asset(
                              getTeamLogoPath(conferenceGroup.conferenceName),
                              height: 40,
                              width: 40,
                              errorBuilder: (ctx, err, st) {
                                debugPrint(
                                  "Error loading logo for ${conferenceGroup.conferenceName}: $err",
                                );
                                return const Icon(
                                  Icons.sports_football,
                                  size: 40,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            // Conference Name
                            Expanded(
                              child: Text(
                                getTeamFullName(conferenceGroup.conferenceName),
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
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
                          final team = divisionGroup.teams[index];
                          final logoPath = getTeamLogoPath(team.teamId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal:
                                  8.0, // Padding within the constrained width
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
                                onTap: () {
                                  debugPrint("Tapped on ${team.fullName}");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Team details for ${team.fullName} not implemented yet.',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
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
          // --- End Wrapping ---
        },
        // --- Apply Center/ConstrainedBox to loading/error states ---
        // --- FIX: Removed const from Center ---
        loading:
            () => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                // LoadingIndicator itself is const, so this child can be const
                child: const LoadingIndicator(),
              ),
            ),
        error:
            (error, stackTrace) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: Padding(
                  // Add padding around error message
                  padding: const EdgeInsets.all(16.0),
                  // ErrorMessageWidget is not const because of the callback
                  child: ErrorMessageWidget(
                    message: 'Failed to load teams: $error',
                    onRetry: () => ref.invalidate(allTeamsProvider),
                  ),
                ),
              ),
            ),
        // --- End Wrapping ---
      ),
    );
  }
}
