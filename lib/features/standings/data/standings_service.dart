// lib/features/standings/data/standings_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/standings/data/standing_model.dart';

/// Service class to fetch standings data from Supabase edge function
class StandingsService {
  final SupabaseClient _supabaseClient;
  static const _functionName = 'standings';

  StandingsService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Fetches standings data for a specific season
  /// [season] The NFL season year (e.g., 2024)
  Future<StandingsResponse> fetchStandingsBySeason(int season) async {
    debugPrint("Fetching standings for season: $season from Edge Function: $_functionName");

    try {
      final response = await _supabaseClient.functions.invoke(
        _functionName,
        method: HttpMethod.get,
        queryParameters: {'season': season.toString()},
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage = 'Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }
        debugPrint('[StandingsService] Error response data: $errorData');
        throw Exception('Failed to load standings: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          'Failed to load standings: Received null data from function.',
        );
      }

      // The response is a list of standings
      if (response.data is! List) {
        throw Exception(
          'Failed to load standings: Invalid data format. Expected a List.',
        );
      }

      final List<dynamic> standingsData = response.data as List<dynamic>;
      
      // Parse the standings data
      final List<TeamStanding> standings = standingsData
          .map((json) {
            try {
              return TeamStanding.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint(
                "[StandingsService] Error parsing standing JSON: $json - Error: $e",
              );
              return null;
            }
          })
          .whereType<TeamStanding>()
          .toList();

      debugPrint(
        "[StandingsService] Successfully fetched ${standings.length} standings for season $season.",
      );
      
      return StandingsResponse(standings: standings, season: season);
    } on FunctionException catch (e) {
      debugPrint(
        '[StandingsService] Supabase FunctionException: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $_functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('[StandingsService] Generic error: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching standings for season $season.',
      );
    }
  }
}
