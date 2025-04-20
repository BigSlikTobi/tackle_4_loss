import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/teams/data/team_info.dart';
import 'package:tackle_4_loss/features/teams/data/team_service.dart';
import 'package:collection/collection.dart'; // Import for groupBy

// 1. Provider for the TeamService instance
final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService();
});

// 2. FutureProvider to fetch the raw list of teams
final allTeamsProvider = FutureProvider<List<TeamInfo>>((ref) async {
  final teamService = ref.watch(teamServiceProvider);
  return teamService.fetchTeams();
});

// --- Grouping Logic ---

// Helper class to structure grouped data for the UI
class DivisionGroup {
  final String divisionName; // e.g., "AFC East"
  final List<TeamInfo> teams;

  DivisionGroup({required this.divisionName, required this.teams});
}

class ConferenceGroup {
  final String conferenceName; // e.g., "AFC"
  final List<DivisionGroup> divisions; // Sorted list of divisions

  ConferenceGroup({required this.conferenceName, required this.divisions});
}

// 3. Provider to group and sort the fetched teams
final groupedTeamsProvider = Provider<AsyncValue<List<ConferenceGroup>>>((ref) {
  // Watch the raw teams provider
  final asyncTeams = ref.watch(allTeamsProvider);

  // Transform the AsyncValue
  return asyncTeams.when(
    data: (teams) {
      if (teams.isEmpty) {
        return const AsyncData([]); // Return empty list if no teams fetched
      }

      // Define the desired order for divisions
      const divisionOrder = ['East', 'North', 'South', 'West'];

      // Group by Conference first
      final groupedByConference = teams.groupListsBy((t) => t.conference);

      final List<ConferenceGroup> conferenceGroups = [];

      // Process AFC first, then NFC (or handle dynamic conferences)
      for (final conferenceName in ['AFC', 'NFC']) {
        if (groupedByConference.containsKey(conferenceName)) {
          final conferenceTeams = groupedByConference[conferenceName]!;

          // Group teams within the conference by Division
          final groupedByDivision = conferenceTeams.groupListsBy(
            (t) => t.division,
          );

          final List<DivisionGroup> divisionGroups = [];

          // Sort divisions according to the defined order
          final sortedDivisionNames = groupedByDivision.keys.sorted((a, b) {
            // Extract the direction part (East, North, etc.)
            String directionA = a.split(' ').last;
            String directionB = b.split(' ').last;
            int indexA = divisionOrder.indexOf(directionA);
            int indexB = divisionOrder.indexOf(directionB);
            // Handle cases where division might not be in the order (fallback)
            if (indexA == -1) indexA = divisionOrder.length;
            if (indexB == -1) indexB = divisionOrder.length;
            return indexA.compareTo(indexB);
          });

          for (final divisionName in sortedDivisionNames) {
            final divisionTeams = groupedByDivision[divisionName]!;
            // Sort teams within the division alphabetically by full name
            divisionTeams.sort((a, b) => a.fullName.compareTo(b.fullName));
            divisionGroups.add(
              DivisionGroup(divisionName: divisionName, teams: divisionTeams),
            );
          }

          conferenceGroups.add(
            ConferenceGroup(
              conferenceName: conferenceName,
              divisions: divisionGroups,
            ),
          );
        }
      }

      // Return the final grouped and sorted structure
      return AsyncData(conferenceGroups);
    },
    // Pass through loading and error states
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
  );
});
