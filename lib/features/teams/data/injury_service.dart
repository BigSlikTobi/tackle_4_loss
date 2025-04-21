import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/teams/data/player_injury.dart'; // Import models

class InjuryService {
  final SupabaseClient _supabaseClient;
  static const _functionName = 'injuries'; // Function name

  InjuryService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<InjuryResponse> fetchInjuries({
    required String teamAbbreviation,
    int? cursor, // Last seen injury ID
    int limit = 20,
  }) async {
    debugPrint(
      "Fetching injuries for team: $teamAbbreviation ${cursor != null ? 'after ID $cursor' : ''} (limit $limit)...",
    );

    try {
      final parameters = <String, String>{
        'team': teamAbbreviation,
        'limit': limit.toString(),
      };
      if (cursor != null) {
        parameters['cursor'] = cursor.toString();
      }

      final response = await _supabaseClient.functions.invoke(
        _functionName,
        method: HttpMethod.get,
        queryParameters: parameters,
      );

      if (response.status != 200) {
        debugPrint(
          "Error fetching injuries: Status ${response.status}, Data: ${response.data}",
        );
        String errorMsg =
            'Failed to load injuries: Status code ${response.status}';
        if (response.data is Map && response.data?['error'] != null) {
          errorMsg = response.data['error'].toString();
        } else if (response.data != null) {
          errorMsg += ' - ${response.data.toString()}';
        }
        throw Exception(errorMsg);
      }

      if (response.data == null || response.data['injuries'] == null) {
        debugPrint(
          "Error fetching injuries: Response data or 'injuries' key is null.",
        );
        throw Exception('Failed to load injuries: Invalid data format.');
      }

      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> injuriesJson =
          responseData['injuries'] as List<dynamic>;
      final int? nextCursor = responseData['nextCursor'] as int?; // Can be null

      final List<PlayerInjury> injuries =
          injuriesJson
              .map((json) {
                try {
                  if (json is Map<String, dynamic>) {
                    return PlayerInjury.fromJson(json);
                  } else {
                    debugPrint("Skipping invalid injury item: $json");
                    return null;
                  }
                } catch (e, s) {
                  debugPrint(
                    "Error parsing injury JSON: $json - Error: $e\n$s",
                  );
                  return null;
                }
              })
              .whereType<PlayerInjury>()
              .toList();

      debugPrint(
        "Successfully fetched ${injuries.length} injuries for team $teamAbbreviation. Next cursor: $nextCursor",
      );

      return InjuryResponse(injuries: injuries, nextCursor: nextCursor);
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching injuries: Status: ${e.status}, Details: ${e.details}',
      );
      final String errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking injuries function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching injuries: $e\n$stacktrace');
      throw Exception('An unexpected error occurred fetching injuries.');
    }
  }
}
