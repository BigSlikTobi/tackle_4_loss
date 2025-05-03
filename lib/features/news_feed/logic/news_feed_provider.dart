import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';

// Keep the old state provider if still used (maybe for AllNewsScreen?)
final newsFeedDisplayModeProvider = StateProvider<NewsFeedDisplayMode>(
  (ref) => NewsFeedDisplayMode.all,
);

// --- NEW: Provider for PageView indicator ---
final featuredPageIndexProvider = StateProvider<int>((ref) => 0);
// --- End NEW ---

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

// Keep the old paginated articles provider (used for the grid now)
// Make sure family parameter 'null' fetches all articles as intended
final paginatedArticlesProvider = AsyncNotifierProvider.family<
  PaginatedArticlesNotifier,
  List<ArticlePreview>,
  String? // Filter parameter (null for all news feed grid)
>(() => PaginatedArticlesNotifier());

// Keep the old notifier (used for the grid now)
class PaginatedArticlesNotifier
    extends FamilyAsyncNotifier<List<ArticlePreview>, String?> {
  // Internal state for pagination
  int? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ArticlePreview> _allFetchedArticles = [];

  String? get _filter => arg; // Use arg to access the filter parameter

  @override
  Future<List<ArticlePreview>> build(String? filter) async {
    final service = ref.watch(newsFeedServiceProvider);
    // Reset state on initial build/rebuild
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedArticles = [];

    try {
      debugPrint(
        "PaginatedArticlesNotifier build (Family: $_filter): Fetching initial page...",
      );
      final response = await service.getArticlePreviews(
        limit: 20, // Or adjust limit for grid
        teamId: _filter, // Use the family parameter
      );

      _allFetchedArticles = response.articles;
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      debugPrint(
        "PaginatedArticlesNotifier build (Family: $_filter): Fetched ${_allFetchedArticles.length} articles. Next cursor: $_nextCursor HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugPrint(
        "Error in PaginatedArticlesNotifier build (Family: $_filter): $e\n$stack",
      );
      _hasMore = false;
      throw Exception(
        "Failed to load initial articles for filter $_filter: $e",
      );
    }
  }

  Future<void> fetchNextPage() async {
    // Use the family parameter 'arg' stored in _filter
    final filterTeamId = _filter;
    final currentState = state.valueOrNull;

    if (currentState == null ||
        _isLoadingMore ||
        !_hasMore ||
        _nextCursor == null) {
      debugPrint(
        "fetchNextPage skipped (PaginatedArticlesNotifier Family: $filterTeamId): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }

    debugPrint(
      "Fetching next page (PaginatedArticlesNotifier Family: $filterTeamId) with cursor: $_nextCursor",
    );
    _isLoadingMore = true;

    // Add loading state feedback if desired, e.g., by modifying the AsyncValue state temporarily
    // state = AsyncLoading<List<ArticlePreview>>().copyWithPrevious(state); // Example

    final service = ref.read(newsFeedServiceProvider);
    final currentCursor = _nextCursor;

    try {
      final response = await service.getArticlePreviews(
        cursor: currentCursor,
        limit: 20, // Or adjust limit for grid
        teamId: filterTeamId, // Pass the filter
      );

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      _allFetchedArticles = [..._allFetchedArticles, ...response.articles];

      state = AsyncData<List<ArticlePreview>>(_allFetchedArticles);
      debugPrint(
        "Next page fetched (PaginatedArticlesNotifier Family: $filterTeamId). Total articles: ${_allFetchedArticles.length}. Has more: $_hasMore",
      );
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (PaginatedArticlesNotifier Family: $filterTeamId) after cursor $currentCursor: $e\n$stack",
      );
      // Keep existing data but show error state
      state = AsyncError<List<ArticlePreview>>(
        e,
        stack,
      ).copyWithPrevious(state);
      _hasMore = false; // Stop trying to paginate on error
    } finally {
      _isLoadingMore = false;
    }
  }

  // --- NEW: Helper for UI to check loading state ---
  bool get isLoadingMore => _isLoadingMore;
  // --- NEW: Helper for UI to check if more pages exist ---
  bool get hasMore => _hasMore;
}

// Keep ClusterStoriesNotifier as is (used for the featured PageView)
final clusterStoriesProvider =
    AsyncNotifierProvider<ClusterStoriesNotifier, List<MappedClusterStory>>(
      () => ClusterStoriesNotifier(),
    );

class ClusterStoriesNotifier extends AsyncNotifier<List<MappedClusterStory>> {
  // Internal state for pagination
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // Store the list of stories fetched (no longer filtered internally)
  List<MappedClusterStory> _allFetchedStories = [];

  @override
  Future<List<MappedClusterStory>> build() async {
    final service = ref.watch(newsFeedServiceProvider);
    // Reset internal state on initial build/rebuild
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedStories = [];
    debugPrint("ClusterStoriesNotifier build: Fetching initial page...");

    try {
      final response = await service.fetchClusterStories(
        limit: 5, // Fetch only a few for the featured section initially
      );

      _allFetchedStories = response.stories;
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;

      debugPrint(
        "ClusterStoriesNotifier build: "
        "Fetched ${_allFetchedStories.length} stories. "
        "Backend next cursor: $_nextCursor, "
        "Has more (based on backend cursor): $_hasMore",
      );

      return _allFetchedStories;
    } catch (e, stack) {
      debugPrint("Error in ClusterStoriesNotifier build: $e\n$stack");
      _hasMore = false; // Stop pagination on error
      throw Exception("Failed to load initial cluster stories: $e");
    }
  }

  // --- Keep fetchNextPage if horizontal pagination is ever needed ---
  // --- Currently NOT used by the new NewsFeedScreen structure ---
  Future<void> fetchNextPage() async {
    final currentState = state.valueOrNull;

    if (currentState == null ||
        _isLoadingMore ||
        !_hasMore ||
        _nextCursor == null) {
      debugPrint(
        "fetchNextPage skipped (ClusterStoriesNotifier): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }

    debugPrint(
      "Fetching next page (ClusterStoriesNotifier) with cursor: $_nextCursor",
    );
    _isLoadingMore = true;

    final service = ref.read(newsFeedServiceProvider);
    final currentBackendCursor = _nextCursor;

    try {
      final response = await service.fetchClusterStories(
        cursor: currentBackendCursor,
        limit: 5, // Fetch small batches
      );

      _allFetchedStories = [..._allFetchedStories, ...response.stories];
      _nextCursor = response.nextCursor;
      _hasMore = response.nextCursor != null;

      debugPrint(
        "Next page fetched (ClusterStoriesNotifier). "
        "Fetched ${response.stories.length} stories. "
        "Total stories: ${_allFetchedStories.length}. "
        "New backend cursor: $_nextCursor, "
        "Has more (based on backend cursor): $_hasMore",
      );

      state = AsyncData<List<MappedClusterStory>>(_allFetchedStories);
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (ClusterStoriesNotifier) after cursor $currentBackendCursor: $e\n$stack",
      );
      state = AsyncError<List<MappedClusterStory>>(
        e,
        stack,
      ).copyWithPrevious(state);
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }

  // Helpers remain the same
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}

// --- REMOVED: currentClusterStoryIndexProvider - handled by featuredPageIndexProvider ---
