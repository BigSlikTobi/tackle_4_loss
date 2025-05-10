import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';

class PaginatedArticlesResponse {
  final List<ArticlePreview> articles;
  final int? nextCursor;

  PaginatedArticlesResponse({required this.articles, this.nextCursor});
}

class PaginatedClusterInfosResponse {
  final List<ClusterInfo> clusters;
  final String? nextCursor;

  PaginatedClusterInfosResponse({required this.clusters, this.nextCursor});
}

class NewsFeedService {
  final SupabaseClient _supabaseClient;

  NewsFeedService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<List<ArticlePreview>> getNflHeadlines() async {
    const functionName = 'NFL_news';
    debugPrint(
      "Fetching NFL headlines from Edge Function: $functionName using GET",
    );
    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
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
        debugPrint('Error response data from $functionName: $errorData');
        throw Exception('Failed to load NFL headlines: $errorMessage');
      }
      if (response.data == null || response.data['data'] == null) {
        debugPrint(
          "Error fetching NFL headlines: Response data or 'data' key is null.",
        );
        throw Exception(
          'Failed to load NFL headlines: Received invalid data format.',
        );
      }
      final List<dynamic> articlesJson = response.data['data'] as List<dynamic>;
      final List<ArticlePreview> headlines =
          articlesJson
              .map((json) {
                try {
                  return ArticlePreview.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint(
                    "Error parsing NFL headline JSON: $json - Error: $e",
                  );
                  return null;
                }
              })
              .whereType<ArticlePreview>()
              .toList();
      debugPrint("Successfully fetched ${headlines.length} NFL headlines.");
      return headlines;
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching NFL headlines: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching NFL headlines: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching NFL headlines.',
      );
    }
  }

  Future<PaginatedArticlesResponse> getArticlePreviews({
    int limit = 20,
    int? cursor,
    String? teamId,
    int? excludeSourceId, // <<< NEW PARAMETER
  }) async {
    try {
      final functionName =
          'articlePreviews'; // Assuming this is the versatile function
      final parameters = <String, dynamic>{'limit': limit.toString()};
      if (cursor != null) {
        parameters['cursor'] = cursor.toString();
      }
      if (teamId != null && teamId.isNotEmpty) {
        parameters['teamId'] = teamId;
      }
      // --- PASS excludeSourceId to EF ---
      if (excludeSourceId != null) {
        parameters['excludeSourceId'] = excludeSourceId.toString();
        debugPrint(
          "[getArticlePreviews] Requesting with excludeSourceId: $excludeSourceId",
        );
      } else {
        debugPrint("[getArticlePreviews] Requesting without excludeSourceId.");
      }
      // --- END PASS ---

      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: parameters,
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
        debugPrint('[getArticlePreviews] Error response data: $errorData');
        throw Exception('Failed to load article previews: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          '[getArticlePreviews] Failed to load article previews: Received null data from function.',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final articlesData = responseData['data'] as List<dynamic>? ?? [];
      final nextCursorInt = responseData['nextCursor'] as int?;

      final articles =
          articlesData
              .map((json) {
                try {
                  return ArticlePreview.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint(
                    "[getArticlePreviews] Error parsing article JSON: $json - Error: $e",
                  );
                  return null;
                }
              })
              .whereType<ArticlePreview>()
              .toList();

      debugPrint(
        "[getArticlePreviews] Fetched ${articles.length} articles. ExcludeSrc: $excludeSourceId. Next cursor: $nextCursorInt",
      );
      return PaginatedArticlesResponse(
        articles: articles,
        nextCursor: nextCursorInt,
      );
    } on FunctionException catch (e) {
      debugPrint(
        '[getArticlePreviews] Supabase FunctionException: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking articlePreviews function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('[getArticlePreviews] Generic error: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching article previews.',
      );
    }
  }

  Future<PaginatedClusterInfosResponse> getClusterInfos({
    int limit = 10,
    String? cursor,
  }) async {
    const functionName = 'cluster_infos';
    debugPrint(
      "Fetching cluster infos from $functionName ${cursor != null ? 'after cursor "$cursor"' : ''} (limit $limit)...",
    );
    try {
      final parameters = <String, String>{'limit': limit.toString()};
      if (cursor != null && cursor.isNotEmpty) {
        parameters['cursor'] = cursor;
      }

      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: parameters,
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage = 'Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : response.data.toString().length)}...';
        }
        debugPrint('Error response data from $functionName: $errorData');
        throw Exception('Failed to load cluster infos: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          'Failed to load cluster infos: Received null data from function.',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic>? clustersData =
          responseData['data'] as List<dynamic>?;
      final String? nextCursor = responseData['nextCursor'] as String?;

      if (clustersData == null) {
        debugPrint(
          "Warning: 'data' key is missing or null in $functionName response.",
        );
        return PaginatedClusterInfosResponse(clusters: [], nextCursor: null);
      }

      List<ClusterInfo> clusterInfos = [];
      for (var jsonItem in clustersData) {
        if (jsonItem is Map<String, dynamic>) {
          final String? rawHeadline = jsonItem['headline'] as String?;
          final String? rawHeadlineDe = jsonItem['headline_de'] as String?;
          bool hasEnglishHeadline =
              rawHeadline != null &&
              rawHeadline.trim().replaceAll(RegExp(r'<[^>]*>'), '').isNotEmpty;
          bool hasGermanHeadline =
              rawHeadlineDe != null &&
              rawHeadlineDe
                  .trim()
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .isNotEmpty;
          if (hasEnglishHeadline || hasGermanHeadline) {
            try {
              clusterInfos.add(ClusterInfo.fromJson(jsonItem));
            } catch (e, s) {
              debugPrint(
                "Error parsing cluster info JSON: $jsonItem - Error: $e\nStackTrace: $s",
              );
            }
          } else {
            debugPrint(
              "Filtered out cluster with no valid headline: ${jsonItem['clusterId']}",
            );
          }
        } else {
          debugPrint(
            "Skipping invalid cluster info JSON (not a Map): $jsonItem",
          );
        }
      }

      debugPrint(
        "Fetched ${clustersData.length} raw clusters, Filtered to ${clusterInfos.length} cluster infos. Next cursor: $nextCursor",
      );

      return PaginatedClusterInfosResponse(
        clusters: clusterInfos,
        nextCursor: nextCursor,
      );
    } on FunctionException catch (e) {
      debugPrint('Supabase FunctionException for $functionName: ${e.details}');
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching cluster infos: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching cluster infos.',
      );
    }
  }
}
