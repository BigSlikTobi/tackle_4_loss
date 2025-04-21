import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/teams/data/player_info.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart'; // For placeholder

class PlayerListItem extends StatelessWidget {
  final PlayerInfo player;

  const PlayerListItem({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Headshot
            SizedBox(
              width: 60,
              height: 80, // Adjust aspect ratio if needed
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child:
                    player.headshotURL != null && player.headshotURL!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: player.headshotURL!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child:
                                    const LoadingIndicator(), // Small loading
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.grey[500],
                                ),
                              ),
                        )
                        : Container(
                          // Fallback if no URL
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.grey[500],
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            // Player Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Number
                  Text(
                    '${player.name ?? "Unknown Player"} ${player.number != null ? "#${player.number}" : ""}'
                        .trim(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Position
                  Text(
                    player.position ?? 'N/A',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Details Row (Age, Ht, Wt)
                  Row(
                    children: [
                      _buildDetailChip(context, 'Age: ${player.age ?? '-'}'),
                      const SizedBox(width: 6),
                      if (player.height.isNotEmpty)
                        _buildDetailChip(context, player.height),
                      const SizedBox(width: 6),
                      if (player.weight.isNotEmpty)
                        _buildDetailChip(context, player.weight),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // College & Experience
                  if (player.college != null && player.college!.isNotEmpty)
                    Text(
                      'College: ${player.college}',
                      style: textTheme.bodySmall,
                    ),
                  if (player.yearsExp != null)
                    Text(
                      'Exp: ${player.yearsExp} yrs',
                      style: textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for detail chips
  Widget _buildDetailChip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.grey[200],
      side: BorderSide.none,
    );
  }
}
