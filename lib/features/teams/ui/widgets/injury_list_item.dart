import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/teams/data/player_injury.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';

class InjuryListItem extends StatelessWidget {
  final PlayerInjury injury;

  const InjuryListItem({super.key, required this.injury});

  // Helper to get status color
  Color _getStatusColor(String status, BuildContext context) {
    final statusUpper = status.toUpperCase();
    if (statusUpper.contains("OUT") ||
        statusUpper.contains("INJURY RESERVE") ||
        statusUpper.contains("NFI") ||
        statusUpper.contains("PUP")) {
      return Colors.red.shade700;
    } else if (statusUpper.contains("DOUBTFUL")) {
      return Colors.orange.shade800;
    } else if (statusUpper.contains("QUESTIONABLE")) {
      return Colors.amber.shade800;
    }
    return Theme.of(context).textTheme.bodySmall?.color ??
        Colors.grey; // Default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final statusColor = _getStatusColor(injury.status, context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Image
            SizedBox(
              width: 50,
              height: 50,
              child: ClipOval(
                // Make image circular
                child:
                    injury.playerImgUrl != null &&
                            injury.playerImgUrl!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: injury.playerImgUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: const LoadingIndicator(
                                  key: ValueKey('img_load'),
                                ), // Key for potential testing
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[400],
                                  size: 30,
                                ),
                              ),
                        )
                        : Container(
                          // Fallback if no URL
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),

            // Injury Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player Name
                  if (injury.playerName != null)
                    Text(
                      injury.playerName!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (injury.playerName != null) const SizedBox(height: 4),

                  // Status and Date Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // Status Chip imitation
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha((0.15 * 255).toInt()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          injury.status,
                          style: textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(), // Pushes date to the right
                      if (injury.date != null)
                        Text(
                          injury.formattedDate, // Use formatted date
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(injury.description, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
