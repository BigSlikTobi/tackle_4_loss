// lib/features/my_team/ui/widgets/injury_report_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/features/teams/data/player_injury.dart';
import 'package:tackle_4_loss/features/teams/logic/injury_provider.dart';

class InjuryReportCard extends ConsumerWidget {
  final String teamId;

  const InjuryReportCard({super.key, required this.teamId});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Log constraints for overflow debugging
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint(
          '[InjuryReportCard] Constraints: '
          'maxHeight: ${constraints.maxHeight}, minHeight: ${constraints.minHeight}',
        );

        // Get injury data from provider
        final injuryAsyncValue = ref.watch(injuryProvider(teamId));

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          elevation: 1.0,
          shadowColor: const Color.fromRGBO(0, 0, 0, 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ExpansionTile(
            title: Text(
              'Injury Report',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
              // Show injuries or loading/error state
              injuryAsyncValue.when(
                data: (injuryState) {
                  final injuries = injuryState.injuries;

                  if (injuries.isEmpty && !injuryState.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text("No injury data available")),
                    );
                  }

                  // Sort injuries by date descending (newest first)
                  // DESC: Newest injuries on top
                  final List<PlayerInjury> sortedInjuries = List.from(injuries)
                    ..sort((a, b) {
                      final dateA = a.date ?? a.createdAt;
                      final dateB = b.date ?? b.createdAt;
                      // DESC: Newest first
                      return dateB.compareTo(dateA);
                    });

                  final recentInjuries = sortedInjuries.take(3).toList();

                  return Column(
                    children: [
                      for (int i = 0; i < recentInjuries.length; i++) ...[
                        _buildCompactInjuryRow(context, recentInjuries[i]),
                        if (i < recentInjuries.length - 1)
                          const Divider(height: 16),
                      ],
                    ],
                  );
                },
                loading:
                    () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: LoadingIndicator(),
                    ),
                error:
                    (error, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          "Unable to load injury data",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ),
              ),

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
      },
    );
  }

  Widget _buildCompactInjuryRow(BuildContext context, PlayerInjury injury) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final statusColor = _getStatusColor(injury.status, context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Player Image
        SizedBox(
          width: 40,
          height: 40,
          child: ClipOval(
            child:
                injury.playerImgUrl != null && injury.playerImgUrl!.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: injury.playerImgUrl!,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ),
                    )
                    : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 12),

        // Name and injury details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (injury.playerName != null)
                Text(
                  injury.playerName!,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
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
                  const Spacer(),
                  if (injury.date != null)
                    Text(
                      injury.formattedDate,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
