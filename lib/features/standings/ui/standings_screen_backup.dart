// lib/features/standings/ui/standings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/constants/layout_constants.dart';
import 'package:tackle_4_loss/features/standings/logic/standings_provider.dart';
import 'package:tackle_4_loss/features/standings/ui/standings_table.dart';
import 'package:tackle_4_loss/features/standings/ui/standings_view_selector.dart';
import 'package:tackle_4_loss/features/standings/data/standing_model.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingsProvider);
    final viewType = ref.watch(standingsViewTypeProvider);

    // Remove Scaffold - ShellNavigationWrapper already provides it
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const StandingsViewSelector(),
              const SizedBox(height: 16),
              Expanded(
                child: standingsAsync.when(
                  data: (standingsResponse) {
                    switch (viewType) {
                      case StandingsViewType.nfl:
                        return SingleChildScrollView(
                          key: const ValueKey('nfl_scroll_view'),
                          child: StandingsTable(
                            title: 'NFL',
                            standings: standingsResponse.overall(),
                            showDivision:
                                false, // No DIV column for NFL overall view
                          ),
                        );
                      case StandingsViewType.conference:
                        // Show a single StandingsTable with conference toggle
                        return SingleChildScrollView(
                          key: const ValueKey('conference_scroll_view'),
                          child: StandingsTable(
                            title: 'Conferences',
                            standings:
                                standingsResponse.standings, // Pass all teams
                            showDivision: false,
                            isConferenceTab: true,
                          ),
                        );
                      case StandingsViewType.division:
                        return _DivisionTab(
                          standingsResponse: standingsResponse,
                        );
                    }
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading standings: ${error.toString()}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.refresh(standingsProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add new widget for Division tab with AFC/NFC toggle and grouped divisions
class _DivisionTab extends StatefulWidget {
  final StandingsResponse standingsResponse;
  const _DivisionTab({required this.standingsResponse});

  @override
  State<_DivisionTab> createState() => _DivisionTabState();
}

class _DivisionTabState extends State<_DivisionTab> {
  String selectedConference = 'AFC';
  static const List<String> divisionOrder = ['East', 'North', 'South', 'West'];

  @override
  Widget build(BuildContext context) {
    // Filter divisions by selected conference
    final divisionMap = widget.standingsResponse.byDivision();
    final divisionNames =
        divisionMap.keys
            .where((d) => d.startsWith(selectedConference))
            .toList();
    // Sort divisions in order East, North, South, West
    divisionNames.sort((a, b) {
      final aDir = a.split(' ').last;
      final bDir = b.split(' ').last;
      return divisionOrder.indexOf(aDir).compareTo(divisionOrder.indexOf(bDir));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildConferenceButton('AFC'),
              const SizedBox(width: 16),
              _buildConferenceButton('NFC'),
            ],
          ),
        ),
        Expanded(
          child:
              divisionNames.isEmpty
                  ? const Center(
                    child: Text('No division standings available.'),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: divisionNames.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final divisionName = divisionNames[index];
                      final standingsList = divisionMap[divisionName] ?? [];
                      return StandingsTable(
                        title: divisionName.replaceFirst(
                          '$selectedConference ',
                          '',
                        ),
                        standings: standingsList,
                        showDivision: false,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildConferenceButton(String conference) {
    final isSelected = selectedConference == conference;
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        foregroundColor:
            isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.colorScheme.primary, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          selectedConference = conference;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/team_logos/${conference.toLowerCase()}.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 24,
                width: 24,
                child: Center(
                  child: Icon(
                    Icons.sports_football,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(conference),
        ],
      ),
    );
  }
}
