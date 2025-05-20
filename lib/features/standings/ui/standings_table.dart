// lib/features/standings/ui/standings_table.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/standings/data/standing_model.dart'; // Ensure this path is correct

/// A widget to display a table of team standings.
/// This version is designed to render its full content and not be independently scrollable.
/// Its root is a Column(mainAxisSize: MainAxisSize.min) and internal list uses shrinkWrap.
class StandingsTable extends StatefulWidget {
  final String title;
  final List<TeamStanding> standings;
  final bool showDivision;
  final bool
  isConferenceTab; // New parameter to identify if we're in the Conferences tab

  const StandingsTable({
    super.key,
    required this.title,
    required this.standings,
    this.showDivision = false,
    this.isConferenceTab =
        false, // Default to false for backwards compatibility
  });

  @override
  State<StandingsTable> createState() => _StandingsTableState();
}

class _StandingsTableState extends State<StandingsTable> {
  String selectedConference = 'AFC';

  List<TeamStanding> get filteredStandings {
    if (!widget.isConferenceTab) return widget.standings;
    return widget.standings
        .where((standing) => standing.division.startsWith(selectedConference))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Log when StandingsTable builds and what conference is selected
    debugPrint(
      '[StandingsTable] build: isConferenceTab=[32m[1m[4m[0m${widget.isConferenceTab}, selectedConference=$selectedConference, title=${widget.title}',
    );
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title section
        if (!widget.isConferenceTab)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.title == 'NFL' ||
                    widget.title == 'AFC' ||
                    widget.title == 'NFC')
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset(
                      'assets/team_logos/${widget.title.toLowerCase()}.png',
                      height: 36,
                      width: 36,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 36,
                          width: 36,
                          child: Center(
                            child: Icon(
                              Icons.sports_football,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Text(
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

        // Conference selection buttons - only show in Conferences tab
        if (widget.isConferenceTab)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildConferenceButton('AFC'),
                const SizedBox(width: 16),
                _buildConferenceButton('NFC'),
              ],
            ),
          ),

        // Table header
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 30,
                child: Text(
                  'RK',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'TEAM',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              if (widget.showDivision) const SizedBox(width: 12),
              SizedBox(
                width: widget.showDivision ? 220 : 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.showDivision)
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'DIV',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 40,
                      child: Text(
                        'W',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                      child: Text(
                        'L',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                      child: Text(
                        'T',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      width: 60,
                      child: Text(
                        'PCT',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Table content
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          itemCount: filteredStandings.length,
          separatorBuilder:
              (context, index) => Divider(
                height: 1,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                indent: 16,
                endIndent: 16,
              ),
          itemBuilder: (context, index) {
            final standing = filteredStandings[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          standing.logoPath,
                          height: 32,
                          width: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 32,
                              width: 32,
                              child: Center(
                                child: Icon(
                                  Icons.sports_football,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            standing.teamName,
                            style: const TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showDivision) const SizedBox(width: 12),
                  SizedBox(
                    width: widget.showDivision ? 220 : 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.showDivision)
                          Expanded(
                            flex: 2,
                            child: Text(
                              standing.division
                                  .replaceFirst('NFC ', '')
                                  .replaceFirst('AFC ', ''),
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${standing.wins}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${standing.losses}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${standing.ties}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            standing.winPercentage.toStringAsFixed(3),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // USAGE NOTE:
        // To show a single conference table with a toggle, only create ONE StandingsTable with isConferenceTab: true and the full standings list.
        // Do NOT create two StandingsTable widgets for AFC and NFC separately.
        // The toggle is handled internally by this widget.
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
