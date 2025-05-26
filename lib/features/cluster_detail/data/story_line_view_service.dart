// File: lib/features/cluster_detail/data/story_line_view_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_view_data.dart';

class StoryLineViewService {
  final SupabaseClient _supabaseClient;
  static const _functionName = 'story_line_view_by_id';

  StoryLineViewService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Fetches story line view data by view ID and language code
  /// [storyLineViewId] is the ID of the story line view
  /// [languageCode] should be a 2-letter ISO language code like 'en' or 'de'
  /// [clusterId] is the cluster ID to ensure the view belongs to the correct cluster (optional but recommended)
  Future<StoryLineViewData> getStoryLineView({
    required int storyLineViewId,
    required String languageCode,
    String? clusterId,
  }) async {
    debugPrint(
      "[StoryLineViewService] Fetching story line view ID: $storyLineViewId, language: $languageCode, clusterId: $clusterId",
    );

    final queryParams = {
      'story_line_view_id': storyLineViewId.toString(),
      'language_code': languageCode,
    };

    // Add cluster ID if provided for validation
    if (clusterId != null && clusterId.isNotEmpty) {
      queryParams['cluster_id'] = clusterId;
      debugPrint(
        "[StoryLineViewService] Including cluster_id for validation: $clusterId",
      );
    }

    try {
      final response = await _supabaseClient.functions.invoke(
        _functionName,
        method: HttpMethod.get,
        queryParameters: queryParams,
      );

      debugPrint("[StoryLineViewService] Response status: ${response.status}");

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage =
            'Failed to load story line view: Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
          if (errorData.containsKey('details')) {
            errorMessage += '. Details: ${errorData['details']}';
          }
        } else if (errorData != null) {
          errorMessage += ': ${errorData.toString()}';
        }
        debugPrint(
          'Error response data from $_functionName (ID: $storyLineViewId, Language: $languageCode): $errorData',
        );
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        debugPrint(
          "Error fetching story line view (ID: $storyLineViewId, Language: $languageCode): Response data is null.",
        );
        throw Exception(
          'Failed to load story line view: Received null data format.',
        );
      }

      debugPrint(
        "[StoryLineViewService] Successfully received story line view data for ID: $storyLineViewId",
      );

      final viewResponse = StoryLineViewResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return viewResponse.data;
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching story line view (ID: $storyLineViewId, Language: $languageCode): ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception(
        'Error invoking $_functionName function for story line view: $errorMessage',
      );
    } catch (e, stacktrace) {
      debugPrint(
        'Generic error fetching story line view (ID: $storyLineViewId, Language: $languageCode): $e',
      );
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching story line view.',
      );
    }
  }
}
