import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'schedule_model.dart';

/// Service class responsible for fetching schedule data from the Supabase edge function
class ScheduleService {
  final SupabaseClient _supabaseClient;

  ScheduleService(this._supabaseClient);
  
  /// Fetches games for a specific week
  /// [week] can be:
  /// - "0" for Hall of Fame game
  /// - "0.1", "0.2", "0.3" for pre-season weeks
  /// - "1" through "18" for regular season weeks
  Future<List<ScheduleGame>> getScheduleByWeek(String week) async {
    try {
      debugPrint("[ScheduleService] Fetching schedule for week: $week");
      
      // Use HttpMethod.get and queryParameters like other services in the app
      final response = await _supabaseClient.functions.invoke(
        'schedule',
        method: HttpMethod.get,
        queryParameters: {'week': week},
      );
      
      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage = 'Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage += ': ${errorData.toString()}';
        }
        debugPrint("[ScheduleService] Error response data: $errorData");
        throw Exception('Failed to fetch schedule: $errorMessage');
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      debugPrint("[ScheduleService] Successfully fetched ${data.length} games for week $week");
      return data.map((item) => ScheduleGame.fromJson(item)).toList();
    } catch (e) {
      debugPrint("[ScheduleService] Error fetching schedule: $e");
      throw Exception('Error fetching schedule: $e');
    }
  }
}
