// lib/features/news_feed/data/news_feed_service.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
// Assuming ArticlePreview is in the same directory or adjust import path
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';

// Define the response structure expected from the 'articlePreviews' Edge Function
class PaginatedArticlesResponse {
  final List<ArticlePreview> articles;
  final int? nextCursor; // The ID of the last item to use for the next fetch

  PaginatedArticlesResponse({required this.articles, this.nextCursor});
}

class NewsFeedService {
  // Use SupabaseClient type for clarity
  final SupabaseClient _supabaseClient;

  // Constructor allows injecting SupabaseClient for easier testing/mocking.
  // Defaults to the globally initialized Supabase instance if none is provided.
  NewsFeedService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Method to fetch article previews, supporting pagination and team filtering
  Future<PaginatedArticlesResponse> getArticlePreviews({
    int limit = 20, // Default number of articles per page
    int? cursor, // Optional: The ID of the last article from the previous page
    String? teamId, // Optional: Filter articles by team ID (e.g., 'DAL', 'PHI')
  }) async {
    try {
      // Name of your Supabase Edge Function
      final functionName = 'articlePreviews';

      // Build the query parameters map
      final parameters = <String, dynamic>{
        'limit': limit.toString(), // Ensure parameters are strings for query
      };

      // Add cursor if provided (for fetching the next page)
      if (cursor != null) {
        parameters['cursor'] = cursor.toString();
        debugPrint("Fetching articles with cursor: $cursor");
      }

      // Add teamId filter if provided
      if (teamId != null && teamId.isNotEmpty) {
        parameters['teamId'] = teamId;
        debugPrint("Fetching articles with teamId filter: $teamId");
      } else {
        debugPrint("Fetching articles without teamId filter.");
      }

      // Invoke the Edge Function using GET method and query parameters
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method:
            HttpMethod.get, // Ensure method matches your Edge Function setup
        queryParameters: parameters, // Pass parameters in the URL query string
      );

      // --- Error Handling ---
      // Check for non-200 status codes
      if (response.status != 200) {
        // Log detailed error information if available
        var errorData = response.data;
        String errorMessage = 'Status code ${response.status}';
        if (errorData is Map && errorData.containsKey('error')) {
          errorMessage += ': ${errorData['error']}';
        } else if (errorData != null) {
          errorMessage +=
              ': ${errorData.toString().substring(0, 100)}...'; // Log snippet
        }
        debugPrint('Error response data: $errorData');
        throw Exception('Failed to load article previews: $errorMessage');
      }

      // Check for null data, which indicates an issue
      if (response.data == null) {
        throw Exception(
          'Failed to load article previews: Received null data from function.',
        );
      }

      // --- Data Parsing ---
      // Parse the JSON response body
      final responseData = response.data as Map<String, dynamic>;

      // Extract the list of articles, defaulting to empty list if null or not found
      final articlesData = responseData['data'] as List<dynamic>? ?? [];

      // Extract the next cursor value (can be null if it's the last page)
      final nextCursor =
          responseData['nextCursor']
              as int?; // Supabase returns numbers directly usually

      // Map the raw JSON article data to ArticlePreview objects
      final articles =
          articlesData
              .map((json) {
                try {
                  return ArticlePreview.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint("Error parsing article JSON: $json - Error: $e");
                  return null; // Return null for items that fail parsing
                }
              })
              .whereType<
                ArticlePreview
              >() // Filter out any nulls from parsing errors
              .toList();

      debugPrint(
        "Fetched ${articles.length} articles. Next cursor: $nextCursor",
      );

      // Return the structured response object
      return PaginatedArticlesResponse(
        articles: articles,
        nextCursor: nextCursor,
      );
    } on FunctionException catch (e) {
      // Handle specific Supabase function invocation errors
      debugPrint('Supabase FunctionException Details: ${e.details}');
      debugPrint(
        'Supabase FunctionException toString(): ${e.toString()}',
      ); // Default string representation

      // Use e.details or e.toString() for the re-thrown exception message
      final errorMessage = e.details?.toString() ?? e.toString();
      throw Exception('Error fetching articles: $errorMessage');
    } catch (e, stacktrace) {
      // Handle other potential errors (network issues, parsing errors, etc.)
      debugPrint('Generic error fetching articles: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('An unexpected error occurred while fetching news.');
    }
  }
}
