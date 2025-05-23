// lib/features/news_feed/data/news_feed_service.dart
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
    const String functionName = 'NFL_news'; // Explicitly typed
    debugPrint(
      "[NewsFeedService.getNflHeadlines] Fetching NFL headlines from Edge Function: $functionName using GET",
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
        debugPrint(
          '[NewsFeedService.getNflHeadlines] Error response data from $functionName: $errorData',
        );
        throw Exception('Failed to load NFL headlines: $errorMessage');
      }
      if (response.data == null || response.data['data'] == null) {
        debugPrint(
          "[NewsFeedService.getNflHeadlines] Error fetching NFL headlines: Response data or 'data' key is null.",
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
                    "[NewsFeedService.getNflHeadlines] Error parsing NFL headline JSON: $json - Error: $e",
                  );
                  return null;
                }
              })
              .whereType<ArticlePreview>()
              .toList();
      debugPrint(
        "[NewsFeedService.getNflHeadlines] Successfully fetched ${headlines.length} NFL headlines.",
      );
      return headlines;
    } on FunctionException catch (e) {
      debugPrint(
        '[NewsFeedService.getNflHeadlines] Supabase FunctionException: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('[NewsFeedService.getNflHeadlines] Generic error: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching NFL headlines.',
      );
    }
  }

  Future<PaginatedArticlesResponse> getArticlePreviews({
    int limit = 20,
    int? cursor,
    String? teamId, // Allow teamId to be null
    int? excludeSourceId,
  }) async {
    // Removed the early return for teamId == null.
    // The Supabase function 'articlePreviews' should handle null teamId to mean all teams.

    try {
      const String functionName = 'articlePreviews';
      debugPrint(
        "[NewsFeedService.getArticlePreviews] Fetching for teamId: ${teamId ?? 'ALL'}, excludeSourceId: $excludeSourceId, limit: $limit, cursor: $cursor from EF: $functionName",
      );
      final parameters = <String, dynamic>{'limit': limit.toString()};
      if (teamId != null) {
        parameters['teamId'] = teamId; // Only add teamId if it's not null
      }
      if (cursor != null) {
        parameters['cursor'] = cursor.toString();
      }
      if (excludeSourceId != null) {
        parameters['excludeSourceId'] = excludeSourceId.toString();
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
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }
        debugPrint(
          '[NewsFeedService.getArticlePreviews] Error response data: $errorData',
        );
        throw Exception(
          'Failed to load article previews for team $teamId: $errorMessage',
        );
      }

      if (response.data == null) {
        throw Exception(
          '[NewsFeedService.getArticlePreviews] Failed to load article previews for team $teamId: Received null data from function.',
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
                    "[NewsFeedService.getArticlePreviews] Error parsing article JSON for team $teamId: $json - Error: $e",
                  );
                  return null;
                }
              })
              .whereType<ArticlePreview>()
              .toList();

      debugPrint(
        "[NewsFeedService.getArticlePreviews] Fetched ${articles.length} articles for team $teamId. ExcludeSrc: $excludeSourceId. Next cursor: $nextCursorInt",
      );
      return PaginatedArticlesResponse(
        articles: articles,
        nextCursor: nextCursorInt,
      );
    } on FunctionException catch (e) {
      final String functionNameForError =
          'articlePreviews'; // Define for catch block
      debugPrint(
        '[NewsFeedService.getArticlePreviews] Supabase FunctionException for team $teamId: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception(
        'Error invoking $functionNameForError function for team $teamId: $errorMessage',
      );
    } catch (e, stacktrace) {
      debugPrint(
        '[NewsFeedService.getArticlePreviews] Generic error for team $teamId: $e',
      );
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching article previews for team $teamId.',
      );
    }
  }

  Future<PaginatedArticlesResponse> getOtherNews({
    int limit = 20,
    int? cursor,
  }) async {
    // Using final String instead of const String for this specific case,
    // as a speculative fix for a potential obscure linter issue.
    final String functionName = 'other_news';
    debugPrint(
      "[NewsFeedService.getOtherNews] Fetching limit: $limit, cursor: $cursor from EF: $functionName",
    );
    try {
      final parameters = <String, dynamic>{'limit': limit.toString()};
      if (cursor != null) {
        parameters['cursor'] = cursor.toString();
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
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
        }
        debugPrint(
          '[NewsFeedService.getOtherNews] Error response data: $errorData',
        );
        throw Exception('Failed to load other news: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          '[NewsFeedService.getOtherNews] Failed to load other news: Received null data from function.',
        );
      }

      List<dynamic> articlesData;
      int? nextCursorInt;

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        articlesData = responseData['data'] as List<dynamic>? ?? [];
        nextCursorInt = responseData['nextCursor'] as int?;
      } else if (response.data is List<dynamic>) {
        articlesData = response.data as List<dynamic>;
        nextCursorInt = null;
        debugPrint(
          "[NewsFeedService.getOtherNews] Response was a direct list. Pagination might not be supported by EF: $functionName as is.",
        );
      } else {
        throw Exception(
          "[NewsFeedService.getOtherNews] Unexpected data format from $functionName.",
        );
      }

      final articles =
          articlesData
              .map((json) {
                try {
                  return ArticlePreview.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint(
                    "[NewsFeedService.getOtherNews] Error parsing article JSON: $json - Error: $e",
                  );
                  return null;
                }
              })
              .whereType<ArticlePreview>()
              .toList();

      debugPrint(
        "[NewsFeedService.getOtherNews] Fetched ${articles.length} articles. Next cursor: $nextCursorInt",
      );
      return PaginatedArticlesResponse(
        articles: articles,
        nextCursor: nextCursorInt,
      );
    } on FunctionException catch (e) {
      debugPrint(
        '[NewsFeedService.getOtherNews] Supabase FunctionException: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking $functionName function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('[NewsFeedService.getOtherNews] Generic error: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching other news.',
      );
    }
  }

  Future<PaginatedClusterInfosResponse> getClusterInfos({
    int limit = 50,
    String? cursor,
  }) async {
    const String functionName = 'cluster_infos'; // Explicitly typed
    debugPrint(
      "[NewsFeedService.getClusterInfos] Fetching cluster infos from $functionName ${cursor != null ? 'after cursor "$cursor"' : ''} (limit $limit)...",
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
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...';
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
          try {
            clusterInfos.add(ClusterInfo.fromJson(jsonItem));
          } catch (e, s) {
            debugPrint(
              "Error parsing cluster info JSON: $jsonItem - Error: $e\nStackTrace: $s",
            );
          }
        } else {
          debugPrint(
            "Skipping invalid cluster info JSON (not a Map): $jsonItem",
          );
        }
      }

      debugPrint(
        "[NewsFeedService.getClusterInfos] Fetched ${clustersData.length} clusters. Next cursor: $nextCursor",
      );

      return PaginatedClusterInfosResponse(
        clusters: clusterInfos,
        nextCursor: nextCursor,
      );
    } on FunctionException catch (e) {
      final String functionNameForError =
          'cluster_infos'; // Define for catch block
      debugPrint(
        'Supabase FunctionException for $functionNameForError: ${e.details}',
      );
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception(
        'Error invoking $functionNameForError function: $errorMessage',
      );
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching cluster infos: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching cluster infos.',
      );
    }
  }

  Future<List<ClusterInfo>> getAllClusterInfos({int limit = 60}) async {
    debugPrint(
      "[NewsFeedService.getAllClusterInfos] Starting to fetch all cluster infos, page limit per call: $limit",
    );
    List<ClusterInfo> allClusters = [];
    String? cursor;
    int pageCount = 0;
    try {
      do {
        pageCount++;
        debugPrint(
          "[NewsFeedService.getAllClusterInfos] Fetching page $pageCount with cursor: $cursor",
        );
        final response = await getClusterInfos(limit: limit, cursor: cursor);
        allClusters.addAll(response.clusters);
        cursor = response.nextCursor;
        debugPrint(
          '[NewsFeedService.getAllClusterInfos] Page $pageCount fetched ${response.clusters.length} clusters. Total fetched: ${allClusters.length}. Next cursor: $cursor',
        );
      } while (cursor != null && cursor.isNotEmpty);
      debugPrint(
        "[NewsFeedService.getAllClusterInfos] Finished fetching all clusters. Total: ${allClusters.length} across $pageCount pages.",
      );
      return allClusters;
    } catch (e, stacktrace) {
      debugPrint(
        "[NewsFeedService.getAllClusterInfos] Error during multi-page fetch: $e\nStacktrace: $stacktrace",
      );
      throw Exception('Failed to fetch all cluster infos: $e');
    }
  }
}
