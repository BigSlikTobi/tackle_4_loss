import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/teams/data/player_info.dart';
// --- Need main roster provider for retry ---
import 'package:tackle_4_loss/features/teams/logic/roster_provider.dart';
import 'package:tackle_4_loss/features/teams/ui/widgets/player_list_item.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:collection/collection.dart';

// --- Changed to ConsumerWidget (Stateless) ---
class PlayerGroupList extends ConsumerWidget {
  final String teamAbbreviation;
  final AsyncValue<List<PlayerInfo>> playerListAsyncValue;

  const PlayerGroupList({
    super.key,
    required this.teamAbbreviation,
    required this.playerListAsyncValue,
  });

  // --- REMOVED ScrollController and related methods/state ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return playerListAsyncValue.when(
      data: (players) {
        if (players.isEmpty) {
          // If the main provider isn't loading/error, it means this group is genuinely empty
          final mainRosterState = ref.watch(rosterProvider(teamAbbreviation));
          if (mainRosterState is AsyncLoading) {
            return const LoadingIndicator();
          }
          if (mainRosterState is AsyncError) {
            /* Error handled below */
          }
          return const Center(
            child: Text("No players found in this category."),
          );
        }

        // --- Grouping and Flattening logic remains the same ---
        final playersGroupedByPosition = players.groupListsBy(
          (player) => player.position ?? 'N/A',
        );
        final List<dynamic> listItems = [];
        final sortedPositions = playersGroupedByPosition.keys.toList();
        sortedPositions.sort((a, b) {
          final firstPlayerA = players.firstWhereOrNull((p) => p.position == a);
          final firstPlayerB = players.firstWhereOrNull((p) => p.position == b);
          final indexA =
              firstPlayerA != null ? players.indexOf(firstPlayerA) : 9999;
          final indexB =
              firstPlayerB != null ? players.indexOf(firstPlayerB) : 9999;
          return indexA.compareTo(indexB);
        });
        for (int i = 0; i < sortedPositions.length; i++) {
          final position = sortedPositions[i];
          final groupPlayers = playersGroupedByPosition[position]!;
          listItems.addAll(groupPlayers);
          if (i < sortedPositions.length - 1) {
            listItems.add(const _Separator());
          }
        }
        // --- End Grouping/Flattening ---

        // --- Build simpler ListView ---
        return ListView.builder(
          // --- REMOVED controller ---
          // --- itemCount is just listItems.length ---
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            // --- REMOVED loading indicator logic ---
            final item = listItems[index];
            if (item is PlayerInfo) {
              return PlayerListItem(player: item);
            } else if (item is _Separator) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor.withOpacity(0.5),
                ),
              );
            }
            return Container(); // Fallback
          },
        );
      },
      // Loading/Error for the *initial* load of this group
      loading: () => const LoadingIndicator(),
      error:
          (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorMessageWidget(
                message: 'Failed to load players: ${error.toString()}',
                // Retry invalidates the main future provider
                onRetry: () => ref.invalidate(rosterProvider(teamAbbreviation)),
              ),
            ),
          ),
    );
  }
}

// Helper class (remains same)
class _Separator {
  const _Separator();
}
