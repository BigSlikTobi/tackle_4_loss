import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/teams/data/player_info.dart';
import 'package:tackle_4_loss/features/teams/data/roster_service.dart';
// --- Import position grouping logic ---
import 'package:tackle_4_loss/features/teams/logic/position_groups.dart';
import 'package:collection/collection.dart'; // For groupBy

// 1. Provider for the RosterService instance (existing)
final rosterServiceProvider = Provider<RosterService>((ref) {
  return RosterService();
});

// --- REMOVED RosterState class ---

// --- FIX: Changed provider type to FutureProvider.family ---
// It now directly returns the list of players or an error.
final rosterProvider = FutureProvider.family<
  List<PlayerInfo>, // Return type is the full list
  String // Family parameter: string team abbreviation
>((ref, teamAbbreviation) async {
  // --- FIX: Call fetchAllRoster ---
  final rosterService = ref.watch(rosterServiceProvider);
  return rosterService.fetchAllRoster(teamAbbreviation: teamAbbreviation);
});
// --- REMOVED RosterNotifier class ---

// --- Derived Providers for Grouped and Sorted Players (Logic Updated) ---

// Helper function to sort players within a group (remains same)
List<PlayerInfo> _sortPlayers(List<PlayerInfo> players, PositionGroup group) {
  return players.sorted((a, b) {
    int posCompare = getPositionSortIndex(
      a.position,
      group,
    ).compareTo(getPositionSortIndex(b.position, group));
    if (posCompare != 0) return posCompare;
    int numA = a.number ?? 999;
    int numB = b.number ?? 999;
    int numCompare = numA.compareTo(numB);
    if (numCompare != 0) return numCompare;
    return (a.name ?? "").compareTo(b.name ?? "");
  });
}

// Provider for grouped players (Map<PositionGroup, List<PlayerInfo>>)
// --- FIX: Watches the new FutureProvider ---
final groupedRosterProvider =
    Provider.family<AsyncValue<Map<PositionGroup, List<PlayerInfo>>>, String>((
      ref,
      teamAbbreviation,
    ) {
      // Watch the new future provider
      final asyncRosterList = ref.watch(rosterProvider(teamAbbreviation));

      return asyncRosterList.when(
        data: (allPlayers) {
          // Directly receives the list on success
          if (allPlayers.isEmpty) {
            return const AsyncData({}); // Return empty map if no players
          }
          // Group all fetched players
          final grouped = allPlayers.groupListsBy(
            (player) => getPositionGroup(player.position),
          );
          // Sort players within each group
          final sortedGroups = grouped.map((group, players) {
            return MapEntry(group, _sortPlayers(players, group));
          });
          // Return the sorted map wrapped in AsyncData
          return AsyncData(sortedGroups);
        },
        // Pass through loading and error states
        loading: () => const AsyncLoading(),
        error: (err, stack) => AsyncError(err, stack),
      );
    });

// Convenience providers (remain conceptually the same, just watch the new grouped provider)
final offensePlayersProvider = Provider.family<
  AsyncValue<List<PlayerInfo>>,
  String
>((ref, teamAbbreviation) {
  final groupedAsync = ref.watch(groupedRosterProvider(teamAbbreviation));
  return groupedAsync.whenData((groups) => groups[PositionGroup.offense] ?? []);
});

final defensePlayersProvider = Provider.family<
  AsyncValue<List<PlayerInfo>>,
  String
>((ref, teamAbbreviation) {
  final groupedAsync = ref.watch(groupedRosterProvider(teamAbbreviation));
  return groupedAsync.whenData((groups) => groups[PositionGroup.defense] ?? []);
});

final specialTeamsPlayersProvider = Provider.family<
  AsyncValue<List<PlayerInfo>>,
  String
>((ref, teamAbbreviation) {
  final groupedAsync = ref.watch(groupedRosterProvider(teamAbbreviation));
  return groupedAsync.whenData((groups) => groups[PositionGroup.special] ?? []);
});

final otherPlayersProvider = Provider.family<
  AsyncValue<List<PlayerInfo>>,
  String
>((ref, teamAbbreviation) {
  final groupedAsync = ref.watch(groupedRosterProvider(teamAbbreviation));
  return groupedAsync.whenData((groups) => groups[PositionGroup.other] ?? []);
});
