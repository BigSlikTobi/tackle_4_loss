// lib/features/my_team/ui/widgets/upcoming_games_card.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart'; // Import constants
import 'package:tackle_4_loss/core/theme/app_colors.dart';

class UpcomingGamesCard extends StatelessWidget {
  final String teamId;

  const UpcomingGamesCard({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Get the correct logo path using the helper function
    getTeamLogoPath(teamId);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 1.0,
      // Use Color.fromARGB instead of withOpacity
      shadowColor: Color.fromARGB((255 * 0.1).round(), 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ExpansionTile(
        title: Text(
          'Upcoming Games',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: AppColors.grey700,
        backgroundColor: theme.cardColor,
        collapsedBackgroundColor: theme.cardColor,
        shape: const Border(),
        collapsedShape: const Border(),
        initiallyExpanded: false,
        children: <Widget>[
          _buildGameRow(context, 'vs Opponent A', 'Sun, Oct 27 - 1:00 PM'),
          const Divider(height: 16),
          _buildGameRow(context, '@ Opponent B', 'Mon, Nov 4 - 8:15 PM'),
          const Divider(height: 16),
          _buildGameRow(context, 'vs Opponent C', 'Sun, Nov 10 - 4:05 PM'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'View Full Schedule →',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRow(BuildContext context, String opponent, String dateTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(opponent, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          dateTime,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}
