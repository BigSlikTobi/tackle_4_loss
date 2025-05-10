// File: lib/features/cluster_detail/data/cluster_detail_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_timeline_response.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_summary_data.dart';
// --- Import new models ---
import 'package:tackle_4_loss/features/cluster_detail/data/single_view_data.dart';

class ClusterDetailService {
  final SupabaseClient _supabaseClient;

  ClusterDetailService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // --- Helper method for fetching single view data ---
  Future<SingleViewData> _fetchGenericViewData(
    String functionName,
    String clusterId, {
    String? defaultViewName,
  }) async {
    debugPrint(
      "Fetching $functionName for clusterId: $clusterId from Edge Function",
    );
    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get, // Assuming GET for all these views
        queryParameters: {'cluster_id': clusterId},
      );

      if (response.status != 200) {
        // ... (error handling as before) ...
        var errorData = response.data;
        String errorMessage =
            'Failed to load $functionName: Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }
        debugPrint(
          'Error response data from $functionName (Cluster ID: $clusterId): $errorData',
        );
        throw Exception(errorMessage);
      }
      if (response.data == null) {
        throw Exception('Failed to load $functionName: Received null data.');
      }
      return SingleViewData.fromJson(
        response.data as Map<String, dynamic>,
        defaultViewName: defaultViewName,
      );
    } on FunctionException catch (e) {
      // ... (error handling as before) ...
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName: $errorMessage');
    } catch (e) {
      // ... (error handling as before) ...
      throw Exception('Unexpected error fetching $functionName: $e');
    }
  }

  Future<SingleViewData> getCoachView(String clusterId) async {
    return _fetchGenericViewData(
      'coach_view_by_id',
      clusterId,
      defaultViewName: "Coach",
    );
  }

  Future<SingleViewData> getPlayerView(String clusterId) async {
    return _fetchGenericViewData(
      'player_view_by_id',
      clusterId,
      defaultViewName: "Player",
    );
  }

  Future<SingleViewData> getFranchiseView(String clusterId) async {
    return _fetchGenericViewData(
      'franchise_view_by_id',
      clusterId,
      defaultViewName: "Franchise",
    );
  }

  Future<SingleViewData> getTeamView(String clusterId) async {
    return _fetchGenericViewData(
      'team_view_by_id',
      clusterId,
      defaultViewName: "Team",
    );
  }

  Future<DynamicViewsResponse> getDynamicViews(String clusterId) async {
    const functionName = 'dynamic_view_by_id';
    debugPrint(
      "Fetching $functionName for clusterId: $clusterId from Edge Function",
    );
    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: {'cluster_id': clusterId},
      );
      if (response.status != 200) {
        // ... (error handling) ...
        var errorData = response.data;
        String errorMessage =
            'Failed to load $functionName: Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }
        throw Exception(errorMessage);
      }
      if (response.data == null) {
        throw Exception('Failed to load $functionName: Received null data.');
      }
      return DynamicViewsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on FunctionException catch (e) {
      // ... (error handling) ...
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName: $errorMessage');
    } catch (e) {
      // ... (error handling) ...
      throw Exception('Unexpected error fetching $functionName: $e');
    }
  }

  // --- Existing methods: getClusterTimeline, getClusterSummary ---
  Future<ClusterTimelineResponse> getClusterTimeline(String clusterId) async {
    const functionName = 'cluster_timeline';
    debugPrint(
      "Fetching cluster timeline for clusterId: $clusterId from Edge Function: $functionName",
    );

    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: {'cluster_id': clusterId},
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage =
            'Failed to load cluster timeline: Status code ${response.status}';
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
          'Error response data from $functionName (Cluster ID: $clusterId): $errorData',
        );
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        debugPrint(
          "Error fetching cluster timeline (Cluster ID: $clusterId): Response data is null.",
        );
        throw Exception(
          'Failed to load cluster timeline: Received null data format.',
        );
      }

      debugPrint(
        "[getClusterTimeline] Raw response data for $clusterId: ${response.data.toString().substring(0, response.data.toString().length > 300 ? 300 : response.data.toString().length)}...",
      );

      return ClusterTimelineResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching cluster timeline (Cluster ID: $clusterId): ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception(
        'Error invoking $functionName function for cluster timeline: $errorMessage',
      );
    } catch (e, stacktrace) {
      debugPrint(
        'Generic error fetching cluster timeline (Cluster ID: $clusterId): $e',
      );
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching the cluster timeline.',
      );
    }
  }

  Future<ClusterSummaryData> getClusterSummary(String clusterId) async {
    const functionName = 'cluster_summary_by_id';
    debugPrint(
      "Fetching cluster summary for clusterId: $clusterId from Edge Function: $functionName",
    );

    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: {'cluster_id': clusterId},
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage =
            'Failed to load cluster summary: Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }
        debugPrint(
          'Error response data from $functionName (Cluster ID: $clusterId): $errorData',
        );
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        debugPrint(
          "Error fetching cluster summary (Cluster ID: $clusterId): Response data is null.",
        );
        throw Exception(
          'Failed to load cluster summary: Received null data format.',
        );
      }

      debugPrint(
        "[getClusterSummary] Raw response data for $clusterId: ${response.data.toString().substring(0, response.data.toString().length > 300 ? 300 : response.data.toString().length)}...",
      );

      return ClusterSummaryData.fromJson(response.data as Map<String, dynamic>);
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching cluster summary (Cluster ID: $clusterId): ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception(
        'Error invoking $functionName function for cluster summary: $errorMessage',
      );
    } catch (e, stacktrace) {
      debugPrint(
        'Generic error fetching cluster summary (Cluster ID: $clusterId): $e',
      );
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching the cluster summary.',
      );
    }
  }
}
