import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed preference provider import as it's not used directly here anymore for headline
// import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';

// State Providers remain the same
final newsFeedDisplayModeProvider = StateProvider<NewsFeedDisplayMode>(
  // Default might be irrelevant now if AllNewsScreen forces 'all'
  (ref) => NewsFeedDisplayMode.all,
);

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

// --- Step 1.1: Convert to AsyncNotifierProvider.family ---
// The family parameter is the filterTeamId (String?)
final paginatedArticlesProvider = AsyncNotifierProvider.family<
  PaginatedArticlesNotifier,
  List<ArticlePreview>,
  String?
>(() => PaginatedArticlesNotifier());

// --- Step 1.2: Update Notifier to use FamilyAsyncNotifier ---
class PaginatedArticlesNotifier
    extends FamilyAsyncNotifier<List<ArticlePreview>, String?> {
  // --- Step 1.3: Internal state is now PER family instance ---
  int? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  // Store articles specific to this filter instance
  List<ArticlePreview> _allFetchedArticles = [];

  // --- Step 1.4: Update 'build' to accept family argument 'arg' ---
  @override
  Future<List<ArticlePreview>> build(
    String? filterTeamId /* 'arg' is filterTeamId */,
  ) async {
    final service = ref.watch(newsFeedServiceProvider);

    // --- Reset state for this specific family instance on initial build/rebuild ---
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedArticles = [];
    // --- End Reset ---

    try {
      debugPrint(
        "AsyncNotifier build (Family: $filterTeamId): Fetching initial page...",
      );
      // --- Step 1.5: Pass filterTeamId from arg to the service ---
      final response = await service.getArticlePreviews(
        limit: 20,
        teamId: filterTeamId, // Pass the argument here
      );

      _allFetchedArticles = response.articles;
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      debugPrint(
        "AsyncNotifier build (Family: $filterTeamId): Fetched ${_allFetchedArticles.length} articles. Next cursor: $_nextCursor HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugPrint(
        "Error in AsyncNotifier build (Family: $filterTeamId): $e\n$stack",
      );
      _hasMore = false; // Ensure no further fetches on error
      throw Exception(
        "Failed to load initial articles for filter $filterTeamId: $e",
      );
    }
  }

  // loadOlder might need rethink later, keeping it simple for now
  Future<void> loadOlder() async {
    debugPrint("loadOlder called.");
    ref.read(newsFeedDisplayModeProvider.notifier).state =
        NewsFeedDisplayMode.all;
    debugPrint("Display mode set to 'all'.");
  }

  // --- Step 1.6: Update 'fetchNextPage' to use family argument 'arg' ---
  Future<void> fetchNextPage() async {
    // Get the filter for this specific instance from 'arg'
    final String? filterTeamId = arg;

    // Check state for THIS instance
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      debugPrint(
        "fetchNextPage skipped (Family: $filterTeamId): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }

    debugPrint(
      "Fetching next page (Family: $filterTeamId) with cursor: $_nextCursor",
    );
    _isLoadingMore = true;

    final service = ref.read(newsFeedServiceProvider);

    try {
      // Pass the filterId for this instance to the service
      final response = await service.getArticlePreviews(
        cursor: _nextCursor!,
        limit: 20,
        teamId: filterTeamId, // Pass the family argument here
      );

      // Update state for THIS instance
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      _allFetchedArticles = [..._allFetchedArticles, ...response.articles];

      // Update the state for THIS family instance
      state = AsyncData<List<ArticlePreview>>(_allFetchedArticles);
      debugPrint(
        "Next page fetched (Family: $filterTeamId). Total articles: ${_allFetchedArticles.length}. Has more: $_hasMore",
      );
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (Family: $filterTeamId): $e\n$stack",
      );
      // Update state with error for THIS instance
      state = AsyncError<List<ArticlePreview>>(
        e,
        stack,
      ).copyWithPrevious(state);
      _hasMore = false; // Stop fetching for this filter on error
    } finally {
      _isLoadingMore = false;
    }
  }

  // --- Step 1.7: (Optional Cleanup) Remove internal refresh method ---
  // UI should use ref.invalidate(provider(filterId)) instead.
  // Future<void> refresh() async { ... }
}

// --- Step 1.8: REMOVE the old derived headline provider ---
/*
final headlineArticleProvider = Provider<AsyncValue<ArticlePreview?>>((ref) {
  // ... This logic is no longer suitable ...
});
*/
