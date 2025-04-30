// lib/features/news_feed/logic/news_feed_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Keep old imports if still needed for other screens (e.g. AllNewsScreen)
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
// Keep old state if still needed
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';
// --- Import the new cluster story model ---
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
// --- REMOVE Source Constants Import ---
// import 'package:tackle_4_loss/core/constants/source_constants.dart';
// --- End Imports ---

// Keep the old state provider if still used (maybe for AllNewsScreen?)
final newsFeedDisplayModeProvider = StateProvider<NewsFeedDisplayMode>(
  (ref) => NewsFeedDisplayMode.all,
);

// --- NEW: Provider to track whether we're in gallery view or detail view ---
enum GalleryViewMode {
  gallery, // Grid of thumbnails
  detail, // Full-screen detail view
}

final galleryViewModeProvider = StateProvider<GalleryViewMode>(
  (ref) => GalleryViewMode.gallery, // Default to gallery view
);

// --- NEW: Provider to track the currently selected story in gallery mode ---
final selectedGalleryItemIndexProvider = StateProvider<int?>(
  (ref) => null, // null means no item selected
);

// --- End NEW ---

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

// Keep the old paginated articles provider if still used by AllNewsScreen
final paginatedArticlesProvider = AsyncNotifierProvider.family<
  PaginatedArticlesNotifier,
  List<ArticlePreview>,
  String?
>(() => PaginatedArticlesNotifier());

// Keep the old notifier if still used by AllNewsScreen
class PaginatedArticlesNotifier
    extends FamilyAsyncNotifier<List<ArticlePreview>, String?> {
  // ... (existing implementation remains unchanged) ...
  int? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ArticlePreview> _allFetchedArticles = [];

  @override
  Future<List<ArticlePreview>> build(String? filterTeamId) async {
    final service = ref.watch(newsFeedServiceProvider);
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedArticles = [];

    try {
      debugPrint(
        "AsyncNotifier build (PaginatedArticles Family: $filterTeamId): Fetching initial page...",
      );
      final response = await service.getArticlePreviews(
        limit: 20,
        teamId: filterTeamId,
      );

      _allFetchedArticles = response.articles;
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      debugPrint(
        "AsyncNotifier build (PaginatedArticles Family: $filterTeamId): Fetched ${_allFetchedArticles.length} articles. Next cursor: $_nextCursor HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugPrint(
        "Error in AsyncNotifier build (PaginatedArticles Family: $filterTeamId): $e\n$stack",
      );
      _hasMore = false;
      throw Exception(
        "Failed to load initial articles for filter $filterTeamId: $e",
      );
    }
  }

  // loadOlder might need rethink later, keeping it simple for now
  Future<void> loadOlder() async {
    debugPrint("loadOlder called (PaginatedArticles).");
    ref.read(newsFeedDisplayModeProvider.notifier).state =
        NewsFeedDisplayMode.all;
    debugPrint("Display mode set to 'all'.");
  }

  Future<void> fetchNextPage() async {
    final String? filterTeamId = arg;
    final currentState = state.valueOrNull;

    if (currentState == null ||
        _isLoadingMore ||
        !_hasMore ||
        _nextCursor == null) {
      debugPrint(
        "fetchNextPage skipped (PaginatedArticles Family: $filterTeamId): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }

    debugPrint(
      "Fetching next page (PaginatedArticles Family: $filterTeamId) with cursor: $_nextCursor",
    );
    _isLoadingMore = true;

    final service = ref.read(newsFeedServiceProvider);
    final currentCursor = _nextCursor;

    try {
      final response = await service.getArticlePreviews(
        cursor: currentCursor,
        limit: 20,
        teamId: filterTeamId,
      );

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      _allFetchedArticles = [..._allFetchedArticles, ...response.articles];

      state = AsyncData<List<ArticlePreview>>(_allFetchedArticles);
      debugPrint(
        "Next page fetched (PaginatedArticles Family: $filterTeamId). Total articles: ${_allFetchedArticles.length}. Has more: $_hasMore",
      );
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (PaginatedArticles Family: $filterTeamId) after cursor $currentCursor: $e\n$stack",
      );
      state = AsyncError<List<ArticlePreview>>(
        e,
        stack,
      ).copyWithPrevious(state);
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }
}

// --- REMOVE: Provider for the selected source filter ---
// final selectedSourceFilterProvider = StateProvider<int?>((ref) => null);

// --- MODIFY: Change to a non-family AsyncNotifierProvider ---
final clusterStoriesProvider =
    AsyncNotifierProvider<ClusterStoriesNotifier, List<MappedClusterStory>>(
      () => ClusterStoriesNotifier(),
    );

// --- MODIFY: Update ClusterStoriesNotifier ---
// Remove the family argument (int? arg)
class ClusterStoriesNotifier extends AsyncNotifier<List<MappedClusterStory>> {
  // Internal state for pagination (remains the same)
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // Store the list of stories fetched (no longer filtered internally)
  List<MappedClusterStory> _allFetchedStories = [];

  // --- BUILD Method: Initial fetch (no family argument) ---
  @override
  Future<List<MappedClusterStory>> build() async {
    final service = ref.watch(newsFeedServiceProvider);
    // --- Reset internal state on initial build/rebuild ---
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedStories = [];
    debugPrint("ClusterStoriesNotifier build: Fetching initial page...");
    // --- End Reset ---

    try {
      // Fetch the first page from the backend (no source filter applied here)
      final response = await service.fetchClusterStories(
        limit: 40, // Increased initial fetch limit for better UX
      );

      // --- REMOVE Frontend Filtering Logic ---
      _allFetchedStories =
          response.stories; // Store the full fetched list directly
      // --- End REMOVE ---

      // The nextCursor provided by the backend is for the full list.
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;

      debugPrint(
        "ClusterStoriesNotifier build: "
        "Fetched ${_allFetchedStories.length} stories. "
        "Backend next cursor: $_nextCursor, "
        "Has more (based on backend cursor): $_hasMore",
      );

      return _allFetchedStories; // Return the full list
    } catch (e, stack) {
      debugPrint("Error in ClusterStoriesNotifier build: $e\n$stack");
      _hasMore = false; // Stop pagination on error
      throw Exception("Failed to load initial cluster stories: $e");
    }
  }

  // --- Method to fetch the next page (no family argument needed) ---
  Future<void> fetchNextPage() async {
    final currentState = state.valueOrNull; // Get current data state

    // Check state for the *unfiltered* list
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

    // Temporarily update state to indicate loading more (optional, UI can check _isLoadingMore flag)
    // state = AsyncData(currentState.copyWith(isLoadingNextPage: true)); // Example if state had isLoadingNextPage

    final service = ref.read(newsFeedServiceProvider);
    final currentBackendCursor = _nextCursor;

    try {
      // Fetch the next page from the backend using the current backend cursor
      final response = await service.fetchClusterStories(
        cursor: currentBackendCursor,
        limit: 10,
      );

      // --- REMOVE Frontend Filtering Logic ---
      // Append the new stories to the existing list directly
      _allFetchedStories = [..._allFetchedStories, ...response.stories];
      // --- End REMOVE ---

      // Update the backend cursor for the *next* fetch request
      _nextCursor = response.nextCursor;

      // Determine if there's potentially more data from the backend
      _hasMore = response.nextCursor != null;

      debugPrint(
        "Next page fetched (ClusterStoriesNotifier). "
        "Fetched ${response.stories.length} stories. "
        "Total stories: ${_allFetchedStories.length}. "
        "New backend cursor: $_nextCursor, "
        "Has more (based on backend cursor): $_hasMore",
      );

      // Update the state with the combined list
      state = AsyncData<List<MappedClusterStory>>(_allFetchedStories);
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (ClusterStoriesNotifier) after cursor $currentBackendCursor: $e\n$stack",
      );
      // On error, keep existing data but indicate error state and stop pagination
      state = AsyncError<List<MappedClusterStory>>(
        e,
        stack,
      ).copyWithPrevious(state);
      _hasMore = false; // Stop fetching on error
    } finally {
      _isLoadingMore = false;
    }
  }

  // --- Helper to indicate if more data is being loaded (for UI) ---
  bool get isLoadingMore => _isLoadingMore;
  // --- Helper to indicate if there is potentially more data ---
  bool get hasMore => _hasMore;
}
// --- End MODIFY ---

// Keep: Provider to track the current page index in the PageView
final currentClusterStoryIndexProvider = StateProvider<int>((ref) => 0);
