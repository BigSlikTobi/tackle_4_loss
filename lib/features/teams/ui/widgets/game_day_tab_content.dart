import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/injury_tab_content.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/upcoming_games_tab_content.dart';

class GameDayTabContent extends StatelessWidget {
  final String teamAbbreviation;

  const GameDayTabContent({super.key, required this.teamAbbreviation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Tab> gameDayTabs = [
      // const Tab(text: 'Last Games'), // Hide Last Games tab
      const Tab(text: 'Upcoming'),
      const Tab(text: 'Injuries'),
    ];

    return DefaultTabController(
      length: gameDayTabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1.0),
              ),
            ),
            child: TabBar(
              tabs: gameDayTabs,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 2.0,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // const PlaceholderContent(title: 'Last Games'), // Hide Last Games content
                // --- Replace Upcoming Game placeholder ---
                UpcomingGamesTabContent(teamAbbreviation: teamAbbreviation),
                // --- End Replacement ---
                InjuryTabContent(teamAbbreviation: teamAbbreviation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
