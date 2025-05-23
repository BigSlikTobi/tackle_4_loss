// lib/features/news_feed/logic/news_feed_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';

final newsFeedDisplayModeProvider = StateProvider<NewsFeedDisplayMode>(
  (ref) => NewsFeedDisplayMode.all,
);

final storyLinesCurrentPageProvider = StateProvider<int>((ref) => 1);
const int storyLinesPerPage = 4;
const int storyLinesBackendFetchLimit = storyLinesPerPage * 3;

final nflHeadlinesPageIndexProvider = StateProvider<int>((ref) => 0);

const int newsItemsPerPage = 8;

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

final nflHeadlinesProvider = FutureProvider<List<ArticlePreview>>((ref) async {
  final service = ref.watch(newsFeedServiceProvider);
  debugPrint("[nflHeadlinesProvider] Fetching NFL headlines.");
  try {
    final headlines = await service.getNflHeadlines();
    debugPrint(
      "[nflHeadlinesProvider] Successfully fetched ${headlines.length} NFL headlines.",
    );
    return headlines;
  } catch (e, stack) {
    debugPrint(
      "[nflHeadlinesProvider] Error fetching NFL headlines: $e\n$stack",
    );
    rethrow;
  }
});

final paginatedArticlesProvider = AsyncNotifierProvider.family<
  PaginatedArticlesNotifier,
  List<ArticlePreview>,
  String?
>(() => PaginatedArticlesNotifier());

class PaginatedArticlesNotifier
    extends FamilyAsyncNotifier<List<ArticlePreview>, String?> {
  int? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ArticlePreview> _allFetchedArticles = [];
  final Set<int> _seenArticleIds = <int>{};
  String? get _teamIdFilter => arg;

  @override
  Future<List<ArticlePreview>> build(String? teamId) async {
    final service = ref.watch(newsFeedServiceProvider);
    _nextCursor = null;
    _isLoadingMore = false;
    _allFetchedArticles = [];
    _seenArticleIds.clear();
    debugLog("Build started.");
    try {
      // Always use newsItemsPerPage * 2 for initial load for consistency
      final initialLimit = newsItemsPerPage * 2;
      debugLog(
        "Fetching initial page (limit: $initialLimit) for filter: '$_teamIdFilter'.",
      );

      PaginatedArticlesResponse response;
      // Unified logic: always call getArticlePreviews.
      // The service will handle passing teamId (or null for all) to the Supabase function.
      response = await service.getArticlePreviews(
        limit: initialLimit,
        teamId: _teamIdFilter, // This can be null
      );

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null && response.articles.isNotEmpty;

      final uniqueInitialArticles =
          response.articles.where((article) {
            return _seenArticleIds.add(article.id);
          }).toList();
      _allFetchedArticles = uniqueInitialArticles;

      // Removed the specific trimming logic for _teamIdFilter == null

      debugLog(
        "Fetched ${response.articles.length} (unique: ${_allFetchedArticles.length}) articles. Next cursor: $_nextCursor. HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugLog("Error in build: $e\n$stack");
      _hasMore = false;
      throw Exception(
        "Failed to load initial articles for filter '$_teamIdFilter': $e",
      );
    }
  }

  Future<void> fetchNextPage() async {
    // Removed the _teamIdFilter == null check that prevented pagination for "all news"
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      debugLog(
        "fetchNextPage skipped (filter '$_teamIdFilter'): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }
    debugLog(
      "Fetching next page for filter '$_teamIdFilter' with cursor: $_nextCursor",
    );
    _isLoadingMore = true;
    state = AsyncData(_allFetchedArticles);

    final service = ref.read(newsFeedServiceProvider);
    final currentCursor = _nextCursor;
    try {
      debugLog(
        "Calling service.getArticlePreviews for filter '$_teamIdFilter' next page fetch.",
      );
      PaginatedArticlesResponse response = await service.getArticlePreviews(
        cursor: currentCursor,
        limit: newsItemsPerPage,
        teamId: _teamIdFilter, // Pass null if no filter
      );

      int newUniqueCount = 0;
      final List<ArticlePreview> newArticlesToAppend = [];
      for (final article in response.articles) {
        if (_seenArticleIds.add(article.id)) {
          newArticlesToAppend.add(article);
          newUniqueCount++;
        }
      }

      if (newUniqueCount > 0) {
        _allFetchedArticles = [..._allFetchedArticles, ...newArticlesToAppend];
      }

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null && response.articles.isNotEmpty;

      debugLog(
        "Next page fetched for filter '$_teamIdFilter'. Fetched ${response.articles.length} (new unique: $newUniqueCount). Total unique: ${_allFetchedArticles.length}. Has more: $_hasMore. New cursor: $_nextCursor",
      );
      state = AsyncData<List<ArticlePreview>>(_allFetchedArticles);
    } catch (e, stack) {
      debugLog(
        "Error fetching next page for filter '$_teamIdFilter' after cursor $currentCursor: $e\n$stack",
      );
      _hasMore = false; // Stop trying on error
      state = AsyncError<List<ArticlePreview>>(
        e,
        stack,
      ).copyWithPrevious(AsyncData(_allFetchedArticles));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> ensureDataForPage(int pageNumber) async {
    if (_teamIdFilter == null) {
      debugLog(
        "'ensureDataForPage' called for 'Other News', but it's not paginated here. Skipping.",
      );
      return;
    }

    final itemsNeeded = pageNumber * newsItemsPerPage;
    debugLog(
      "Ensuring data for page $pageNumber. Items needed: $itemsNeeded. Currently have: ${_allFetchedArticles.length}. HasMore: $_hasMore. IsLoadingMore: $_isLoadingMore",
    );
    // Check _nextCursor as well; if it's null and we don't have enough, we can't fetch more.
    while (_allFetchedArticles.length < itemsNeeded &&
        _hasMore &&
        !_isLoadingMore &&
        _nextCursor != null) {
      debugLog(
        "Not enough data for page $pageNumber (need $itemsNeeded, have ${_allFetchedArticles.length}). Fetching next page for team '$_teamIdFilter'...",
      );
      await fetchNextPage();
    }
    debugLog(
      "Finished ensuring data for page $pageNumber (team '$_teamIdFilter'). Total items: ${_allFetchedArticles.length}. HasMore: $_hasMore",
    );
  }

  void debugLog(String message) {
    String filterContext =
        _teamIdFilter == null
            ? "General (Other News - Top 8)"
            : "Team '$_teamIdFilter'";
    debugPrint("[PaginatedArticlesNotifier ($filterContext)] $message");
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMore;
  int get totalFetchedItems => _allFetchedArticles.length;
}

// --- ClusterInfo Section - Paginated ---
final paginatedClusterInfosProvider =
    AsyncNotifierProvider<PaginatedClusterInfosNotifier, List<ClusterInfo>>(
      () => PaginatedClusterInfosNotifier(),
    );

class PaginatedClusterInfosNotifier extends AsyncNotifier<List<ClusterInfo>> {
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true; // Start optimistic, will be corrected by first fetch
  List<ClusterInfo> _allFetchedClusters = [];
  final Set<String> _seenClusterIds = <String>{};

  @override
  Future<List<ClusterInfo>> build() async {
    final service = ref.watch(newsFeedServiceProvider);
    _nextCursor = null;
    _isLoadingMore = false;
    _allFetchedClusters = [];
    _seenClusterIds.clear();
    debugPrint(
      "[PaginatedClusterInfosNotifier] Build started. Fetching initial batch (limit: $storyLinesBackendFetchLimit)...",
    );

    try {
      final response = await service.getClusterInfos(
        limit: storyLinesBackendFetchLimit,
      );

      final uniqueInitialClusters =
          response.clusters.where((cluster) {
            return _seenClusterIds.add(cluster.clusterId);
          }).toList();
      _allFetchedClusters = uniqueInitialClusters;

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null && response.clusters.isNotEmpty;
      debugPrint(
        "[PaginatedClusterInfosNotifier] Initial fetch complete. Fetched ${response.clusters.length} (unique: ${_allFetchedClusters.length}). Next cursor: '$_nextCursor'. HasMore: $_hasMore",
      );
      return _allFetchedClusters;
    } catch (e, stack) {
      debugPrint("[PaginatedClusterInfosNotifier] Error in build: $e\n$stack");
      _hasMore = false;
      throw Exception("Failed to load initial story lines: $e");
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      debugPrint(
        "[PaginatedClusterInfosNotifier] fetchNextPage skipped: loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }
    debugPrint(
      "[PaginatedClusterInfosNotifier] Fetching next page with cursor: '$_nextCursor' (fetch limit: $storyLinesBackendFetchLimit)",
    );
    _isLoadingMore = true;
    state = AsyncData(_allFetchedClusters);

    final service = ref.read(newsFeedServiceProvider);
    final currentCursor = _nextCursor; // Already confirmed non-null
    try {
      final response = await service.getClusterInfos(
        cursor: currentCursor,
        limit: storyLinesBackendFetchLimit,
      );

      int newUniqueCount = 0;
      final List<ClusterInfo> newClustersToAppend = [];
      for (final cluster in response.clusters) {
        if (_seenClusterIds.add(cluster.clusterId)) {
          newClustersToAppend.add(cluster);
          newUniqueCount++;
        }
      }

      if (newUniqueCount > 0) {
        _allFetchedClusters = [..._allFetchedClusters, ...newClustersToAppend];
      }

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null && response.clusters.isNotEmpty;

      debugPrint(
        "[PaginatedClusterInfosNotifier] Next page fetched. Fetched ${response.clusters.length} (new unique: $newUniqueCount). Total unique: ${_allFetchedClusters.length}. Has more: $_hasMore. New cursor: '$_nextCursor'",
      );
      state = AsyncData<List<ClusterInfo>>(_allFetchedClusters);
    } catch (e, stack) {
      debugPrint(
        "[PaginatedClusterInfosNotifier] Error fetching next page after cursor $currentCursor: $e\n$stack",
      );
      _hasMore = false;
      state = AsyncError<List<ClusterInfo>>(
        e,
        stack,
      ).copyWithPrevious(AsyncData(_allFetchedClusters));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> ensureDataForStoryLinesPage(int uiPageNumber) async {
    final itemsNeededForUi = uiPageNumber * storyLinesPerPage;
    debugPrint(
      "[PaginatedClusterInfosNotifier] Ensuring data for Story Lines UI page $uiPageNumber. Items needed for UI: $itemsNeededForUi. Currently have in buffer: ${_allFetchedClusters.length}. HasMore from backend: $_hasMore. IsLoadingMore: $_isLoadingMore. NextCursor: '$_nextCursor'",
    );

    // Loop to fetch pages until enough items are loaded for the target UI page OR no more data from backend
    while (_allFetchedClusters.length < itemsNeededForUi &&
        _hasMore &&
        !_isLoadingMore &&
        _nextCursor != null) {
      debugPrint(
        "[PaginatedClusterInfosNotifier] Not enough data in buffer for UI page $uiPageNumber (need $itemsNeededForUi, have ${_allFetchedClusters.length}). Fetching next backend page using cursor '$_nextCursor'...",
      );
      await fetchNextPage();
    }
    debugPrint(
      "[PaginatedClusterInfosNotifier] Finished ensuring data for Story Lines UI page $uiPageNumber. Total items in buffer: ${_allFetchedClusters.length}. HasMore: $_hasMore",
    );
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMore;
  int get totalFetchedClusterItems => _allFetchedClusters.length;
}
