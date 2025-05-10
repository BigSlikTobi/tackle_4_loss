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

final storyLinesPageIndexProvider = StateProvider<int>((ref) => 0);
final nflHeadlinesPageIndexProvider = StateProvider<int>((ref) => 0);

const int otherNewsItemsPerPage = 8;
final otherNewsCurrentPageProvider = StateProvider<int>((ref) => 1);

// --- Define Source ID for NFL News to be excluded from "Other News" ---
const int nflSourceIdForExclusion = 1;

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

final nflHeadlinesProvider = FutureProvider<List<ArticlePreview>>((ref) async {
  final service = ref.watch(newsFeedServiceProvider);
  return service.getNflHeadlines();
});

// paginatedArticlesProvider(null) will be used for "Other News"
// paginatedArticlesProvider(teamId) will be used for team-specific news
final paginatedArticlesProvider = AsyncNotifierProvider.family<
  PaginatedArticlesNotifier,
  List<ArticlePreview>,
  String? // Nullable String for teamId filter (null means general/other news)
>(() => PaginatedArticlesNotifier());

class PaginatedArticlesNotifier
    extends FamilyAsyncNotifier<List<ArticlePreview>, String?> {
  int? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ArticlePreview> _allFetchedArticles = [];
  final Set<int> _seenArticleIds = <int>{};
  String? get _teamIdFilter => arg; // Access family parameter (teamId)

  @override
  Future<List<ArticlePreview>> build(String? teamId) async {
    // Parameter is teamId
    final service = ref.watch(newsFeedServiceProvider);
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedArticles = [];
    _seenArticleIds.clear();
    try {
      // Initial fetch for this notifier. For "Other News", fetch a couple of pages worth.
      // For team-specific news, initial fetch might be smaller or same.
      final initialLimit =
          (_teamIdFilter == null)
              ? otherNewsItemsPerPage * 2
              : otherNewsItemsPerPage;
      debugPrint(
        "PaginatedArticlesNotifier build (TeamId: $_teamIdFilter): Fetching initial page (limit: $initialLimit)...",
      );

      final response = await service.getArticlePreviews(
        limit: initialLimit,
        teamId: _teamIdFilter,
        // If no team filter, assume it's for "Other News" and exclude NFL Source
        excludeSourceId: _teamIdFilter == null ? nflSourceIdForExclusion : null,
      );

      final uniqueInitialArticles =
          response.articles.where((article) {
            return _seenArticleIds.add(article.id);
          }).toList();
      _allFetchedArticles = uniqueInitialArticles;

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      debugPrint(
        "PaginatedArticlesNotifier build (TeamId: $_teamIdFilter): Fetched ${response.articles.length} (unique: ${_allFetchedArticles.length}) articles. Next cursor: $_nextCursor HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugPrint(
        "Error in PaginatedArticlesNotifier build (TeamId: $_teamIdFilter): $e\n$stack",
      );
      _hasMore = false;
      throw Exception(
        "Failed to load initial articles for filter $_teamIdFilter: $e",
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      debugPrint(
        "fetchNextPage skipped (PaginatedArticlesNotifier TeamId: $_teamIdFilter): loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }
    debugPrint(
      "Fetching next page (PaginatedArticlesNotifier TeamId: $_teamIdFilter) with cursor: $_nextCursor",
    );
    _isLoadingMore = true;

    final service = ref.read(newsFeedServiceProvider);
    final currentCursor = _nextCursor;
    try {
      final response = await service.getArticlePreviews(
        cursor: currentCursor,
        limit:
            otherNewsItemsPerPage, // Standard fetch size for subsequent pages
        teamId: _teamIdFilter,
        excludeSourceId: _teamIdFilter == null ? nflSourceIdForExclusion : null,
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
      if (newUniqueCount == 0 && (_nextCursor == null)) {
        _hasMore = false;
      } else {
        _hasMore = _nextCursor != null;
      }

      debugPrint(
        "Next page fetched (PaginatedArticlesNotifier TeamId: $_teamIdFilter). Fetched ${response.articles.length} (new unique: $newUniqueCount). Total unique: ${_allFetchedArticles.length}. Has more: $_hasMore",
      );
      state = AsyncData<List<ArticlePreview>>(_allFetchedArticles);
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (PaginatedArticlesNotifier TeamId: $_teamIdFilter) after cursor $currentCursor: $e\n$stack",
      );
      state = AsyncError<List<ArticlePreview>>(
        e,
        stack,
      ).copyWithPrevious(AsyncData(_allFetchedArticles));
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> ensureDataForPage(int pageNumber) async {
    final itemsNeeded = pageNumber * otherNewsItemsPerPage;
    debugPrint(
      "[PaginatedArticlesNotifier TeamId: $_teamIdFilter] Ensuring data for page $pageNumber. Items needed: $itemsNeeded. Currently have: ${_allFetchedArticles.length}. HasMore: $_hasMore",
    );
    while (_allFetchedArticles.length < itemsNeeded &&
        _hasMore &&
        !_isLoadingMore) {
      debugPrint(
        "[PaginatedArticlesNotifier TeamId: $_teamIdFilter] Not enough data for page $pageNumber. Fetching next page...",
      );
      await fetchNextPage();
    }
    debugPrint(
      "[PaginatedArticlesNotifier TeamId: $_teamIdFilter] Finished ensuring data for page $pageNumber. Total items: ${_allFetchedArticles.length}",
    );
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMore;
  int get totalFetchedItems => _allFetchedArticles.length;
}

final clusterInfosProvider =
    AsyncNotifierProvider<ClusterInfosNotifier, List<ClusterInfo>>(
      () => ClusterInfosNotifier(),
    );

class ClusterInfosNotifier extends AsyncNotifier<List<ClusterInfo>> {
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ClusterInfo> _allFetchedClusters = [];
  final Set<String> _seenClusterIds = <String>{};

  @override
  Future<List<ClusterInfo>> build() async {
    final service = ref.watch(newsFeedServiceProvider);
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedClusters = [];
    _seenClusterIds.clear();
    debugPrint("ClusterInfosNotifier build: Fetching initial page...");

    try {
      final response = await service.getClusterInfos(limit: 10);

      final uniqueInitialClusters =
          response.clusters.where((cluster) {
            return _seenClusterIds.add(cluster.clusterId);
          }).toList();
      _allFetchedClusters = uniqueInitialClusters;

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;

      debugPrint(
        "ClusterInfosNotifier build: Fetched ${response.clusters.length} (unique: ${_allFetchedClusters.length}) clusters. Next cursor: $_nextCursor, Has more: $_hasMore",
      );
      return _allFetchedClusters;
    } catch (e, stack) {
      debugPrint("Error in ClusterInfosNotifier build: $e\n$stack");
      _hasMore = false;
      throw Exception("Failed to load initial cluster infos: $e");
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore ||
        !_hasMore ||
        _nextCursor == null ||
        _nextCursor!.isEmpty) {
      debugPrint(
        "fetchNextPage skipped (ClusterInfosNotifier): loading=$_isLoadingMore, hasMore=$_hasMore, cursor='$_nextCursor'",
      );
      return;
    }
    debugPrint(
      "Fetching next page (ClusterInfosNotifier) with cursor: $_nextCursor",
    );
    _isLoadingMore = true;
    final service = ref.read(newsFeedServiceProvider);
    final currentBackendCursor = _nextCursor;

    try {
      final response = await service.getClusterInfos(
        cursor: currentBackendCursor,
        limit: 10,
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
      if (newUniqueCount == 0 &&
          (_nextCursor == null || _nextCursor!.isEmpty)) {
        _hasMore = false;
      } else {
        _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;
      }

      debugPrint(
        "Next page fetched (ClusterInfosNotifier). Fetched ${response.clusters.length} (new unique: $newUniqueCount). Total unique: ${_allFetchedClusters.length}. New cursor: $_nextCursor, Has more: $_hasMore",
      );
      state = AsyncData<List<ClusterInfo>>(_allFetchedClusters);
    } catch (e, stack) {
      debugPrint(
        "Error fetching next page (ClusterInfosNotifier) after cursor $currentBackendCursor: $e\n$stack",
      );
      state = AsyncError<List<ClusterInfo>>(
        e,
        stack,
      ).copyWithPrevious(AsyncData(_allFetchedClusters));
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}
