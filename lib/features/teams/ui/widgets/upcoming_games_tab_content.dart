import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/teams/logic/schedule_provider.dart';
import 'package:tackle_4_loss/features/teams/data/schedule_game_info.dart'; // Import ScheduleGameInfo

class UpcomingGamesTabContent extends ConsumerWidget {
  final String teamAbbreviation;

  const UpcomingGamesTabContent({super.key, required this.teamAbbreviation});

  String _formatWeek(String week) {
    switch (week) {
      case '0':
        return 'HoF Game';
      case '0.1':
        return 'Pre-Season 1';
      case '0.2':
        return 'Pre-Season 2';
      case '0.3':
        return 'Pre-Season 3';
      default:
        // For regular weeks, ensure it's a number and then format
        if (double.tryParse(week) != null && !week.contains('.')) {
          return 'Week $week';
        }
        return 'Wk $week'; // Fallback for any other unexpected format
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsyncValue = ref.watch(teamScheduleProvider(teamAbbreviation));
    final theme = Theme.of(context);

    return scheduleAsyncValue.when(
      data: (games) {
        if (games.isEmpty) {
          return const Center(child: Text('No upcoming games found.'));
        }
        
        // Create a mutable copy for sorting
        final sortedGames = List<ScheduleGameInfo>.from(games);

        // Sort the games:
        // 1. By date (earliest first)
        // 2. If dates are the same, by week (numeric value, e.g., 0, 0.1, 1, 2)
        sortedGames.sort((a, b) {
          try {
            final dateA = DateFormat('yyyy-MM-dd').parse(a.date); 
            final dateB = DateFormat('yyyy-MM-dd').parse(b.date);
            int dateComparison = dateA.compareTo(dateB);
            if (dateComparison != 0) {
              return dateComparison;
            }
          } catch (e) {
            // Log error and potentially fallback or treat as equal for date
            debugPrint("Error parsing dates for sorting ('${a.date}', '${b.date}'): $e");
          }

          // If dates are the same or parsing failed, compare by week as a numeric value
          try {
            final weekValueA = double.parse(a.week); 
            final weekValueB = double.parse(b.week);
            return weekValueA.compareTo(weekValueB);
          } catch (e) {
            // Log error and fallback to string comparison for week
            debugPrint("Error parsing weeks for sorting ('${a.week}', '${b.week}'): $e");
            return a.week.compareTo(b.week);
          }
        });

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: sortedGames.length, // Use sortedGames
          separatorBuilder: (context, index) => const SizedBox(height: 16.0),
          itemBuilder: (context, index) {
            final game = sortedGames[index]; // Use sortedGames

            // ---- DEBUG PRINTS START ----
            debugPrint('Current Team Abbreviation (widget input): $teamAbbreviation');
            debugPrint('Game Data: home_team=${game.homeTeamAbbreviation}, away_team=${game.awayTeamAbbreviation}');
            // ---- DEBUG PRINTS END ----

            final isHomeGame = game.isHomeGame(teamAbbreviation.toUpperCase()); // Ensure comparison is case-insensitive
            final opponentAbbreviation = game.getOpponentAbbreviation(teamAbbreviation.toUpperCase()); // Ensure comparison is case-insensitive
            
            // ---- DEBUG PRINTS START ----
            debugPrint('isHomeGame: $isHomeGame');
            debugPrint('Opponent Abbreviation: $opponentAbbreviation');
            // ---- DEBUG PRINTS END ----

            final opponentLogoPath = getTeamLogoPath(opponentAbbreviation);

            // Date and Time Formatting
            String formattedDate = 'Date N/A';
            String formattedTime = 'Time N/A';
            try {
              final gameDate = DateFormat('yyyy-MM-dd').parse(game.date);
              formattedDate = DateFormat.yMMMMd().format(gameDate); // e.g., September 10, 2023
            } catch (e) {
              debugPrint("Error parsing game date: ${game.date} - $e");
            }
            // Basic time formatting, assuming time is like "7:00 PM ET"
            // More robust parsing might be needed if time formats vary significantly
            formattedTime = game.time; 

            return Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                isHomeGame ? 'Home vs' : 'Away @',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isHomeGame ? Colors.green[700] : Colors.blue[700],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Image.asset(
                                opponentLogoPath,
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.sports_football, size: 24), // Fallback icon
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  getTeamFullName(opponentAbbreviation), // Display full name
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatWeek(game.week), // Use the helper function
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '$formattedDate at $formattedTime',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      game.stadium,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (game.tvNetwork != null && game.tvNetwork!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'TV: ${game.tvNetwork}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) {
        debugPrint("Error loading schedule: $error\n$stack");
        return ErrorMessageWidget(message: 'Could not load schedule: ${error.toString()}'); // Corrected widget name
      },
    );
  }
}
