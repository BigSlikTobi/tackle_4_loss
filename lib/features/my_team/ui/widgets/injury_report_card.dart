// lib/features/my_team/ui/widgets/injury_report_card.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart'; // Import constants

class InjuryReportCard extends StatelessWidget {
  final String teamId;

  const InjuryReportCard({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Get the correct logo path using the helper function
    final logoPath = getTeamLogoPath(teamId);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 1.0,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.1), // Use Color.fromRGBO
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ExpansionTile(
        leading: // --- CORRECT USAGE ---
            Image.asset(
          logoPath, // Use the path directly from the helper function
          height: 24,
          width: 24,
          errorBuilder:
              (context, error, stackTrace) =>
                  const SizedBox(width: 24, height: 24),
        ),
        // --- END CORRECTION ---
        title: Text(
          'Injury Report',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: Colors.grey[700],
        backgroundColor: theme.cardColor,
        collapsedBackgroundColor: theme.cardColor,
        shape: const Border(),
        collapsedShape: const Border(),
        initiallyExpanded: false,
        children: <Widget>[
          _buildInjuryRow(context, 'Player One', 'WR', 'Questionable (Knee)'),
          const Divider(height: 16),
          _buildInjuryRow(context, 'Player Two', 'CB', 'Out (Ankle)'),
          const Divider(height: 16),
          _buildInjuryRow(context, 'Player Three', 'OT', 'Doubtful (Shoulder)'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'View Full Report →',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuryRow(
    BuildContext context,
    String name,
    String pos,
    String status,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$name ($pos)', style: Theme.of(context).textTheme.bodyMedium),
        Text(
          status,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.red[700]),
        ),
      ],
    );
  }
}
