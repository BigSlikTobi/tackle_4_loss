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
  bool _hasMore =
      true; // Initialize optimistically, will be corrected by first fetch
  List<ArticlePreview> _allFetchedArticles = [];
  final Set<int> _seenArticleIds = <int>{};
  String? get _teamIdFilter => arg;

  @override
  Future<List<ArticlePreview>> build(String? teamId) async {
    final service = ref.watch(newsFeedServiceProvider);
    _nextCursor = null;
    // _hasMore will be determined by the first fetch response
    _isLoadingMore = false; // Initial build is not "loading more"
    _allFetchedArticles = [];
    _seenArticleIds.clear();
    debugLog("Build started.");
    try {
      final initialLimit = (_teamIdFilter == null) ? 8 : newsItemsPerPage * 2;
      debugLog("Fetching initial page (limit: $initialLimit)...");

      PaginatedArticlesResponse response;
      if (_teamIdFilter == null) {
        debugLog(
          "Calling service.getOtherNews for initial fetch (limit: $initialLimit).",
        );
        response = await service.getOtherNews(limit: initialLimit);
        _hasMore =
            false; // "Other News" on main feed is always just the top 8, no further pagination.
        _nextCursor = null;
      } else {
        debugLog(
          "Calling service.getArticlePreviews for team '$_teamIdFilter' initial fetch (limit: $initialLimit).",
        );
        response = await service.getArticlePreviews(
          limit: initialLimit,
          teamId: _teamIdFilter,
        );
        _nextCursor = response.nextCursor;
        // _hasMore is true if a next cursor is provided AND the response was not empty.
        _hasMore = _nextCursor != null && response.articles.isNotEmpty;
      }

      final uniqueInitialArticles =
          response.articles.where((article) {
            return _seenArticleIds.add(article.id);
          }).toList();
      _allFetchedArticles = uniqueInitialArticles;

      if (_teamIdFilter == null && _allFetchedArticles.length > 8) {
        _allFetchedArticles = _allFetchedArticles.sublist(0, 8);
        debugLog("Trimmed 'Other News' to 8 articles.");
      }

      debugLog(
        "Fetched ${response.articles.length} (unique & potentially trimmed: ${_allFetchedArticles.length}) articles. Next cursor (for teams): $_nextCursor. HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugLog("Error in build: $e\n$stack");
      _hasMore = false; // Ensure _hasMore is false on error
      throw Exception(
        "Failed to load initial articles for filter '$_teamIdFilter': $e",
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (_teamIdFilter == null) {
      debugLog(
        "fetchNextPage skipped: 'Other News' section is not paginated here.",
      );
      return;
    }

    // Corrected condition: if _nextCursor is null, we definitely can't fetch.
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      debugLog(
        "fetchNextPage skipped (team '$_teamIdFilter'): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }
    debugLog(
      "Fetching next page for team '$_teamIdFilter' with cursor: $_nextCursor",
    );
    _isLoadingMore = true;
    state = AsyncData(
      _allFetchedArticles,
    ); // Reflect loading while showing current data

    final service = ref.read(newsFeedServiceProvider);
    final currentCursor =
        _nextCursor; // Already confirmed non-null by the check above
    try {
      debugLog(
        "Calling service.getArticlePreviews for team '$_teamIdFilter' next page fetch.",
      );
      PaginatedArticlesResponse response = await service.getArticlePreviews(
        cursor: currentCursor,
        limit: newsItemsPerPage,
        teamId: _teamIdFilter,
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
        "Next page fetched for team '$_teamIdFilter'. Fetched ${response.articles.length} (new unique: $newUniqueCount). Total unique: ${_allFetchedArticles.length}. Has more: $_hasMore. New cursor: $_nextCursor",
      );
      state = AsyncData<List<ArticlePreview>>(_allFetchedArticles);
    } catch (e, stack) {
      debugLog(
        "Error fetching next page for team '$_teamIdFilter' after cursor $currentCursor: $e\n$stack",
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
