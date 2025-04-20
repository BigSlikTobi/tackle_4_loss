import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/teams/data/team_info.dart';

class TeamService {
  final SupabaseClient _supabaseClient;
  static const _teamsFunctionName = 'teams'; // Name of your Edge Function

  TeamService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<TeamInfo>> fetchTeams() async {
    debugPrint("Attempting to fetch teams from Edge Function...");
    try {
      final response = await _supabaseClient.functions.invoke(
        _teamsFunctionName,
        method: HttpMethod.get, // Assuming GET method for your function
      );

      if (response.status != 200) {
        debugPrint(
          "Error fetching teams: Status Code ${response.status}, Data: ${response.data}",
        );
        throw Exception('Failed to load teams: Status code ${response.status}');
      }

      if (response.data == null || response.data['data'] == null) {
        debugPrint(
          "Error fetching teams: Response data or 'data' key is null.",
        );
        throw Exception('Failed to load teams: Received invalid data format.');
      }

      // Expecting {"data": [...]} structure based on your description
      final List<dynamic> teamListJson = response.data['data'] as List<dynamic>;

      final List<TeamInfo> teams =
          teamListJson
              .map((json) {
                try {
                  return TeamInfo.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint("Error parsing team JSON: $json - Error: $e");
                  return null; // Handle parsing errors for individual items
                }
              })
              .whereType<TeamInfo>()
              .toList(); // Filter out nulls from parsing errors

      debugPrint("Successfully fetched and parsed ${teams.length} teams.");
      return teams;
    } on FunctionException catch (e) {
      // Log the details for debugging purposes
      debugPrint('Supabase FunctionException fetching teams: ${e.details}');
      // FIX: Use toString() instead of message for the re-thrown exception
      throw Exception('Error invoking teams function: ${e.toString()}');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching teams: $e\n$stacktrace');
      throw Exception('An unexpected error occurred fetching teams.');
    }
  }
}
