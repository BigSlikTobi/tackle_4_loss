import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/team_constants.dart'; // Added
import '../data/schedule_model.dart';

class GameCard extends StatelessWidget {
  final ScheduleGame game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('E, MMM d');
    final timeFormat = DateFormat('h:mm a');
    
    // Format date and time
    final formattedDate = dateFormat.format(game.date);
    final formattedTime = game.time != null ? 
        timeFormat.format(DateFormat('HH:mm:ss').parse(game.time!)) : 'TBD';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$formattedDate • $formattedTime',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              game.stadium,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildTeamInfo(context, game.awayTeamName, game.awayTeamName, true), // Pass awayTeamName as abbreviation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    "at",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                _buildTeamInfo(context, game.homeTeamName, game.homeTeamName, false), // Pass homeTeamName as abbreviation
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context, String teamName, String teamAbbreviation, bool isAway) { // Changed teamId to teamAbbreviation
    return Expanded(
      child: Row(
        mainAxisAlignment: isAway ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAway) _buildTeamLogo(teamAbbreviation), // Changed teamId to teamAbbreviation
          if (!isAway) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: isAway ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  teamName, // Use teamName (abbreviation) directly
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  getTeamFullName(teamName), // Use getTeamFullName from constants
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isAway) const SizedBox(width: 8),
          if (isAway) _buildTeamLogo(teamAbbreviation), // Changed teamId to teamAbbreviation
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String teamAbbreviation) { // Changed teamId to teamAbbreviation
    // Use getTeamLogoPath from constants
    final logoPath = getTeamLogoPath(teamAbbreviation);
    // Debug log for validation
    // ignore: avoid_print
    print('[_buildTeamLogo] abbr: $teamAbbreviation, path: $logoPath');
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.asset(
          logoPath, // Use logoPath from constants
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.sports_football, size: 32),
        ),
      ),
    );
  }
}
