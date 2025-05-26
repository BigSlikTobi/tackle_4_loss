import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_timeline_response.dart';

class StoryLineTimelineService {
  final SupabaseClient _supabaseClient;

  StoryLineTimelineService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Fetches timeline data for a specific cluster ID from the timeline_by_cluster_id endpoint
  Future<StoryLineTimelineResponse> getTimelineByClusterId(
    String clusterId,
  ) async {
    const functionName = 'timeline_by_cluster_id';

    debugPrint(
      "[StoryLineTimelineService.getTimelineByClusterId] Fetching timeline for clusterId: $clusterId from Edge Function: $functionName",
    );

    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: {'cluster_id': clusterId},
      );

      debugPrint(
        "[StoryLineTimelineService] Response status: ${response.status}",
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage =
            'Failed to load timeline: Status code ${response.status}';

        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
          if (errorData.containsKey('details')) {
            errorMessage += '. Details: ${errorData['details']}';
          }
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }

        debugPrint(
          '[StoryLineTimelineService] Error response data: $errorData',
        );
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        debugPrint("[StoryLineTimelineService] Response data is null");
        throw Exception('Failed to load timeline: Received null data');
      }

      debugPrint(
        "[StoryLineTimelineService] Raw response data: ${response.data.toString().substring(0, response.data.toString().length > 300 ? 300 : response.data.toString().length)}...",
      );

      return StoryLineTimelineResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on FunctionException catch (e) {
      debugPrint(
        '[StoryLineTimelineService] Supabase FunctionException: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('[StoryLineTimelineService] Generic error: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching timeline data: $e',
      );
    }
  }
}
