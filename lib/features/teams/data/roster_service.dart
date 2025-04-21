import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/teams/data/player_info.dart'; // Keep PlayerInfo, remove RosterResponse

class RosterService {
  final SupabaseClient _supabaseClient;
  static const _rosterFunctionName = 'roster';

  RosterService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // --- Changed method signature ---
  Future<List<PlayerInfo>> fetchAllRoster({
    required String teamAbbreviation,
  }) async {
    debugPrint(
      "Attempting to fetch ALL roster data for team: $teamAbbreviation...",
    );
    try {
      final parameters = <String, String>{
        'teamId': teamAbbreviation,
        // No page/pageSize needed
      };

      final response = await _supabaseClient.functions.invoke(
        _rosterFunctionName,
        method: HttpMethod.get,
        queryParameters: parameters,
      );

      if (response.status != 200) {
        debugPrint(
          "Error fetching roster: Status Code ${response.status}, Data: ${response.data}",
        );
        String errorMsg =
            'Failed to load roster: Status code ${response.status}';
        if (response.data is Map && response.data?['error'] != null) {
          errorMsg = response.data['error'].toString();
        } else if (response.data != null) {
          errorMsg += ' - ${response.data.toString()}';
        }
        throw Exception(errorMsg);
      }

      if (response.data == null) {
        debugPrint("Error fetching roster: Response data is null.");
        throw Exception('Failed to load roster: Received null data.');
      }

      debugPrint("Raw roster response data type: ${response.data.runtimeType}");
      debugPrint(
        "Raw roster response data content (first 500 chars): ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}",
      );

      // --- Handle potential JSON structures ---
      List<dynamic> playersJson;
      if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        // Expected structure: { "data": [...] }
        debugPrint("Parsing response assuming format: {'data': [...] }");
        playersJson = response.data['data'] as List<dynamic>;
      } else if (response.data is List) {
        // Fallback: Function returned just the array [...]
        debugPrint(
          "WARN: Parsing response assuming format: [...] (Expected {'data': [...] })",
        );
        playersJson = response.data as List<dynamic>;
      } else {
        // Unexpected structure
        debugPrint(
          "Error fetching roster: Unexpected response data structure.",
        );
        throw Exception('Failed to load roster: Invalid data format.');
      }
      // --- End structure handling ---

      // --- Parsing logic remains the same ---
      final List<PlayerInfo> players =
          playersJson
              .map((json) {
                try {
                  // Ensure json is actually a Map before parsing
                  if (json is Map<String, dynamic>) {
                    return PlayerInfo.fromJson(json);
                  } else {
                    debugPrint(
                      "Error parsing player JSON: Item is not a Map - $json",
                    );
                    return null;
                  }
                } catch (e, s) {
                  // Catch specific parsing errors
                  debugPrint(
                    "Error parsing player JSON: $json - Error: $e\nStackTrace: $s",
                  );
                  return null;
                }
              })
              .whereType<PlayerInfo>()
              .toList(); // Filter out nulls

      debugPrint(
        "Successfully fetched and parsed ${players.length} players for team $teamAbbreviation.",
      );
      // --- Return the list directly ---
      return players;
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching roster: Status: ${e.status}, Details: ${e.details}',
      );
      final String errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking roster function: $errorMessage');
    } catch (e, stacktrace) {
      // Catch parsing errors or other issues here
      debugPrint('Generic error fetching roster: $e\n$stacktrace');
      throw Exception(
        'An unexpected error occurred fetching the roster.',
      ); // Generic message
    }
  }
}
