// lib/features/news_feed/data/story_lines_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/features/news_feed/data/story_line_item.dart';

class StoryLinesService {
  final SupabaseClient _supabaseClient;

  StoryLinesService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Fetches story lines from the backend edge function
  /// [languageCode] should be a 2-letter ISO language code like 'en' or 'de'
  /// [page] is the page number to fetch (starts from 1)
  /// [limit] is the number of items per page
  Future<StoryLinesResponse> getStoryLines({
    required String languageCode,
    int page = 1,
    int limit = 25,
  }) async {
    const functionName = 'story_lines';

    // Add platform-specific debugging
    debugPrint("=== STORY LINES DEBUG START ===");
    debugPrint("[StoryLinesService] Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
    debugPrint(
      "[StoryLinesService] Default Target Platform: ${defaultTargetPlatform}",
    );

    // Check Supabase client configuration
    final clientStr = _supabaseClient.toString();
    debugPrint(
      "[StoryLinesService] Supabase Client configured: ${clientStr.length > 50 ? clientStr.substring(0, 50) + '...' : clientStr}",
    );

    debugPrint(
      "[StoryLinesService.getStoryLines] Fetching story lines from Edge Function: $functionName with languageCode: $languageCode, page: $page, limit: $limit",
    );

    try {
      final response = await _supabaseClient.functions.invoke(
        functionName,
        method: HttpMethod.get,
        queryParameters: {
          'language_code': languageCode,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      debugPrint("[StoryLinesService] Response status: ${response.status}");
      debugPrint(
        "[StoryLinesService] Response data type: ${response.data.runtimeType}",
      );

      if (response.status != 200) {
        var errorData = response.data;
        String errorMessage =
            'Failed to load story lines: Status code ${response.status}';
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
          'Error response data from $functionName (Language: $languageCode, Page: $page): $errorData',
        );
        debugPrint("=== STORY LINES DEBUG END (ERROR) ===");
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        debugPrint(
          "Error fetching story lines (Language: $languageCode, Page: $page): Response data is null.",
        );
        debugPrint("=== STORY LINES DEBUG END (NULL DATA) ===");
        throw Exception(
          'Failed to load story lines: Received null data format.',
        );
      }

      debugPrint(
        "[StoryLinesService.getStoryLines] Raw response data for languageCode $languageCode, page $page: ${response.data.toString().substring(0, response.data.toString().length > 300 ? 300 : response.data.toString().length)}...",
      );

      final result = StoryLinesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint(
        "[StoryLinesService] Successfully parsed ${result.data.length} story lines",
      );
      debugPrint("=== STORY LINES DEBUG END (SUCCESS) ===");

      return result;
    } on FunctionException catch (e) {
      debugPrint(
        'Supabase FunctionException fetching story lines (Language: $languageCode, Page: $page): ${e.details}',
      );
      debugPrint('FunctionException toString: ${e.toString()}');
      final errorMessage = e.details?.toString() ?? e.toString();
      debugPrint("=== STORY LINES DEBUG END (FUNCTION EXCEPTION) ===");
      throw Exception(
        'Error invoking $functionName function for story lines: $errorMessage',
      );
    } catch (e, stacktrace) {
      debugPrint(
        'Generic error fetching story lines (Language: $languageCode, Page: $page): $e',
      );
      debugPrint('Stacktrace: $stacktrace');
      debugPrint("=== STORY LINES DEBUG END (GENERIC ERROR) ===");
      throw Exception(
        'An unexpected error occurred while fetching story lines.',
      );
    }
  }

  /// Fetches all story lines across multiple pages for the given language
  /// This is useful for scenarios where you need to fetch all available story lines
  Future<List<StoryLineItem>> getAllStoryLines({
    required String languageCode,
    int limit = 25,
  }) async {
    debugPrint(
      "[StoryLinesService.getAllStoryLines] Starting to fetch all story lines for languageCode: $languageCode, page limit per call: $limit",
    );

    List<StoryLineItem> allStoryLines = [];
    int currentPage = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages) {
        debugPrint(
          "[StoryLinesService.getAllStoryLines] Fetching page $currentPage for languageCode: $languageCode",
        );

        final response = await getStoryLines(
          languageCode: languageCode,
          page: currentPage,
          limit: limit,
        );

        allStoryLines.addAll(response.data);
        hasMorePages = response.pagination.hasNext;
        currentPage++;

        debugPrint(
          '[StoryLinesService.getAllStoryLines] Page $currentPage fetched ${response.data.length} story lines. Total fetched: ${allStoryLines.length}. HasNext: ${response.pagination.hasNext}',
        );
      }

      debugPrint(
        "[StoryLinesService.getAllStoryLines] Finished fetching all story lines for languageCode: $languageCode. Total: ${allStoryLines.length} across ${currentPage - 1} pages.",
      );

      return allStoryLines;
    } catch (e, stacktrace) {
      debugPrint(
        "[StoryLinesService.getAllStoryLines] Error during multi-page fetch for languageCode $languageCode: $e\nStacktrace: $stacktrace",
      );
      throw Exception('Failed to fetch all story lines: $e');
    }
  }
}
