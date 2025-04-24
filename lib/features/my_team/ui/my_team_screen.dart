// lib/features/my_team/ui/my_team_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart'; // Import team provider
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/my_team/ui/widgets/team_selection_dropdown.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/team_news_tab_content.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/game_day_tab_content.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/roster_tab_content.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/placeholder_content.dart';
import 'package:tackle_4_loss/features/my_team/ui/widgets/team_huddle_section.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state of the selected team provider
    final selectedTeamState = ref.watch(selectedTeamNotifierProvider);

    // The main content depends on the state of the selected team
    return selectedTeamState.when(
      // Loading the initial preference
      loading: () => const LoadingIndicator(),

      // Error loading the initial preference
      error:
          (error, stackTrace) => ErrorMessageWidget(
            message: "Error loading team preference: $error",
            // Optionally add retry for loading preference
            onRetry: () => ref.invalidate(selectedTeamNotifierProvider),
          ),

      // Preference loaded (or updated) successfully
      data: (selectedTeamId) {
        // If no team is selected, show the selection UI
        if (selectedTeamId == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select your favorite team',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const TeamSelectionDropdown(), // Show the dropdown
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
                child: Text(
                  'Your selection will be saved on this device.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        } else {
          // --- TeamHuddleSection on top, then tabbed layout below, all scrollable ---
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TeamHuddleSection(
                    teamId: selectedTeamId,
                    headlineArticle:
                        null, // Optionally fetch headline if needed
                  ),
                  // Tabbed content below
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Transparent TabBar, no shadow
                        Container(
                          color:
                              Colors
                                  .transparent, // fully transparent, no shadow
                          child: TabBar(
                            tabs: const [
                              Tab(text: 'News'),
                              Tab(text: 'General'),
                              Tab(text: 'GameDay'),
                              Tab(text: 'Roster'),
                            ],
                            isScrollable: true,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                            indicatorWeight: 2.5,
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                        ),
                        // Give TabBarView a fixed height to avoid unbounded height error
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                              0.7, // Adjust as needed
                          child: TabBarView(
                            children: [
                              TeamNewsTabContent(
                                teamAbbreviation: selectedTeamId,
                              ),
                              const PlaceholderContent(title: 'General Info'),
                              GameDayTabContent(
                                teamAbbreviation: selectedTeamId,
                              ),
                              RosterTabContent(
                                teamAbbreviation: selectedTeamId,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
