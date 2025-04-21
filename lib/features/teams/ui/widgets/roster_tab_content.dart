import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/teams/logic/roster_provider.dart';
// --- Import the new list widget ---
import 'package:tackle_4_loss/features/teams/ui/widgets/player_group_list.dart';
// --- Import core widgets for main loading/error ---
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';

// RosterTabContent is now the container for the nested tabs
class RosterTabContent extends ConsumerWidget {
  final String teamAbbreviation; // Changed from teamIntegerId

  const RosterTabContent({super.key, required this.teamAbbreviation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the main provider primarily for overall loading/error state
    final rosterAsyncValue = ref.watch(rosterProvider(teamAbbreviation));

    // Define the tabs for the nested controller
    final List<Tab> positionTabs = [
      const Tab(text: 'Offense'),
      const Tab(text: 'Defense'),
      const Tab(text: 'Special Teams'),
      // Optional: Add 'Other' if needed
      // const Tab(text: 'Other'),
    ];

    return rosterAsyncValue.when(
      // Only show initial loading indicator here
      loading: () => const LoadingIndicator(),
      // Show main error message if initial fetch fails
      error:
          (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorMessageWidget(
                message: 'Failed to load roster: ${error.toString()}',
                onRetry: () => ref.invalidate(rosterProvider(teamAbbreviation)),
              ),
            ),
          ),
      // When data (or subsequent loading/error) is available from the main provider
      data: (rosterState) {
        // Use a DefaultTabController for the nested tabs
        return DefaultTabController(
          length: positionTabs.length,
          child: Column(
            children: [
              // The nested TabBar
              Container(
                color: Theme.of(context).colorScheme.surface, // Match theme
                child: TabBar(
                  tabs: positionTabs,
                  isScrollable: false, // Typically fit 3-4 tabs
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              // The nested TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    // Offense List
                    PlayerGroupList(
                      teamAbbreviation: teamAbbreviation,
                      playerListAsyncValue: ref.watch(
                        offensePlayersProvider(teamAbbreviation),
                      ),
                    ),
                    // Defense List
                    PlayerGroupList(
                      teamAbbreviation: teamAbbreviation,
                      playerListAsyncValue: ref.watch(
                        defensePlayersProvider(teamAbbreviation),
                      ),
                    ),
                    // Special Teams List
                    PlayerGroupList(
                      teamAbbreviation: teamAbbreviation,
                      playerListAsyncValue: ref.watch(
                        specialTeamsPlayersProvider(teamAbbreviation),
                      ),
                    ),
                    // Optional: Other List
                    // PlayerGroupList(
                    //   teamAbbreviation: teamAbbreviation,
                    //   playerListAsyncValue: ref.watch(otherPlayersProvider(teamAbbreviation)),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
