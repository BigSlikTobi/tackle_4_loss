// lib/features/news_feed/data/news_feed_service.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
// Keep ArticlePreview if still used elsewhere (e.g., AllNewsScreen)
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
// --- Import the new cluster story model ---
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
// --- End Import ---

// Keep the old response structure if getArticlePreviews is still used
class PaginatedArticlesResponse {
  final List<ArticlePreview> articles;
  final int? nextCursor; // The ID of the last item to use for the next fetch

  PaginatedArticlesResponse({required this.articles, this.nextCursor});
}

// --- NEW: Define the response structure for cluster stories ---
class PaginatedClusterStoriesResponse {
  final List<MappedClusterStory> stories;
  final String? nextCursor; // The composite cursor string from backend

  PaginatedClusterStoriesResponse({required this.stories, this.nextCursor});
}
// --- End NEW ---

class NewsFeedService {
  final SupabaseClient _supabaseClient;

  NewsFeedService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // --- Keep getArticlePreviews if AllNewsScreen still uses it ---
  // (Assuming this method is still used by AllNewsScreen or other parts)
  Future<PaginatedArticlesResponse> getArticlePreviews({
    int limit = 20,
    int? cursor,
    String? teamId,
  }) async {
    // ... (existing implementation remains unchanged) ...
    try {
      final functionName = 'articlePreviews';
      final parameters = <String, dynamic>{'limit': limit.toString()};
      if (cursor != null) {
        parameters['cursor'] = cursor.toString();
      }
      if (teamId != null && teamId.isNotEmpty) {
        parameters['teamId'] = teamId;
      } else {}

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
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : errorData.toString().length)}...'; // Log snippet
        }
        debugPrint('Error response data: $errorData');
        throw Exception('Failed to load article previews: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          'Failed to load article previews: Received null data from function.',
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
                  debugPrint("Error parsing article JSON: $json - Error: $e");
                  return null;
                }
              })
              .whereType<ArticlePreview>()
              .toList();

      debugPrint(
        "Fetched ${articles.length} articles using articlePreviews. Next cursor: $nextCursorInt",
      );

      return PaginatedArticlesResponse(
        articles: articles,
        nextCursor: nextCursorInt,
      );
    } on FunctionException catch (e) {
      debugPrint('Supabase FunctionException Details: ${e.details}');
      debugPrint('Supabase FunctionException toString(): ${e.toString()}');
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error fetching articles: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching articles: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('An unexpected error occurred while fetching news.');
    }
  }
  // --- End getArticlePreviews ---

  // --- NEW: Method to fetch Cluster Stories ---
  Future<PaginatedClusterStoriesResponse> fetchClusterStories({
    int limit = 10, // Use a reasonable default for vertical pages
    String? cursor, // The string cursor from the backend
  }) async {
    debugPrint(
      "Fetching cluster stories ${cursor != null ? 'after cursor "$cursor"' : ''} (limit $limit)...",
    );
    try {
      final functionName = 'clusterStories'; // Your new function name

      final parameters = <String, String>{'limit': limit.toString()};

      if (cursor != null && cursor.isNotEmpty) {
        parameters['cursor'] = cursor;
        debugPrint("Using cursor: $cursor");
      }

      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: parameters,
      );

      // --- Error Handling ---
      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage = 'Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, errorData.toString().length > 100 ? 100 : response.data.toString().length)}...';
        }
        debugPrint('Error response data: $errorData');
        throw Exception('Failed to load cluster stories: $errorMessage');
      }

      if (response.data == null) {
        throw Exception(
          'Failed to load cluster stories: Received null data from function.',
        );
      }

      // Assuming the backend always returns { "data": [...], "nextCursor": "..." }
      final responseData = response.data as Map<String, dynamic>;

      final List<dynamic>? storiesData = responseData['data'] as List<dynamic>?;
      final String? nextCursor = responseData['nextCursor'] as String?;

      if (storiesData == null) {
        debugPrint("Warning: 'data' key is missing or null in response.");
        return PaginatedClusterStoriesResponse(stories: [], nextCursor: null);
      }

      final List<MappedClusterStory> clusterStories =
          storiesData
              .map((json) {
                try {
                  if (json is Map<String, dynamic>) {
                    return MappedClusterStory.fromJson(json);
                  } else {
                    debugPrint("Skipping invalid cluster story JSON: $json");
                    return null;
                  }
                } catch (e, s) {
                  debugPrint(
                    "Error parsing cluster story JSON: $json - Error: $e\nStackTrace: $s",
                  );
                  return null;
                }
              })
              .whereType<MappedClusterStory>()
              .toList();

      debugPrint(
        "Fetched ${clusterStories.length} cluster stories. Next cursor: $nextCursor",
      );

      return PaginatedClusterStoriesResponse(
        stories: clusterStories,
        nextCursor: nextCursor,
      );
    } on FunctionException catch (e) {
      debugPrint('Supabase FunctionException Details: ${e.details}');
      debugPrint('Supabase FunctionException toString(): ${e.toString()}');
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error invoking clusterStories function: $errorMessage');
    } catch (e, stacktrace) {
      debugPrint('Generic error fetching cluster stories: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
        'An unexpected error occurred while fetching cluster stories.',
      );
    }
  }
}
