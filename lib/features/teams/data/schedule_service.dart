import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/teams/data/schedule_game_info.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart'; // For teamAbbreviationToNumericId

class ScheduleService {
  final SupabaseClient _supabaseClient;
  static const _functionName = 'schedule_by_team_id';

  ScheduleService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<ScheduleGameInfo>> fetchScheduleByTeamAbbreviation(
      String teamAbbreviation) async {
    final teamId = teamAbbreviationToNumericId[teamAbbreviation.toUpperCase()];
    if (teamId == null) {
      debugPrint(
          'Error: Could not find numeric ID for team abbreviation: $teamAbbreviation');
      throw Exception(
          'Could not find numeric ID for team abbreviation: $teamAbbreviation');
    }

    debugPrint(
        "Fetching schedule for team: $teamAbbreviation (ID: $teamId) from Edge Function: $_functionName");

    try {
      final response = await _supabaseClient.functions.invoke(
        _functionName,
        method: HttpMethod.get,
        queryParameters: {'team_id': teamId.toString()},
      );

      if (response.status != 200) {
        debugPrint(
            "Error fetching schedule: Status ${response.status}, Data: ${response.data}");
        String errorMsg =
            'Failed to load schedule: Status code ${response.status}';
        if (response.data is Map && response.data?['error'] != null) {
          errorMsg = response.data['error'].toString();
        } else if (response.data != null) {
          errorMsg += ' - ${response.data.toString()}';
        }
        throw Exception(errorMsg);
      }

      if (response.data == null || response.data is! List) {
        debugPrint(
            "Error fetching schedule: Response data is null or not a list.");
        throw Exception('Failed to load schedule: Invalid data format.');
      }

      final List<dynamic> scheduleJson = response.data as List<dynamic>;
      final List<ScheduleGameInfo> schedule = scheduleJson.map((json) {
        try {
          if (json is Map<String, dynamic>) {
            return ScheduleGameInfo.fromJson(json);
          } else {
            debugPrint("Skipping invalid schedule item: $json");
            return null;
          }
        } catch (e, s) {
          debugPrint(
              "Error parsing schedule game JSON: $json - Error: $e\n$s");
          return null;
        }
      }).whereType<ScheduleGameInfo>().toList();

      debugPrint(
          "Successfully fetched ${schedule.length} games for team $teamAbbreviation.");
      return schedule;
    } on FunctionException catch (e) {
      debugPrint(
          'Supabase FunctionException fetching schedule: Status: ${e.status}, Details: ${e.details}');
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $_functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint(
          'Generic error fetching schedule for $teamAbbreviation: $e\n$stacktrace');
      throw Exception(
          'An unexpected error occurred fetching the schedule for $teamAbbreviation.');
    }
  }
}
