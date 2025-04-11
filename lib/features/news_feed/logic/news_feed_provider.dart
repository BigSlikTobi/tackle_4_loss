// lib/features/news_feed/logic/news_feed_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Adjust import if your preference provider is elsewhere
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';

// --- State Providers ---

final newsFeedDisplayModeProvider = StateProvider<NewsFeedDisplayMode>(
  (ref) => NewsFeedDisplayMode.newOnly,
);

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

// --- AsyncNotifierProvider for managing the article list and pagination ---

final paginatedArticlesProvider =
    AsyncNotifierProvider<PaginatedArticlesNotifier, List<ArticlePreview>>(
      () => PaginatedArticlesNotifier(),
    );

class PaginatedArticlesNotifier extends AsyncNotifier<List<ArticlePreview>> {
  int? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<ArticlePreview> _allFetchedArticles = [];

  @override
  Future<List<ArticlePreview>> build() async {
    final service = ref.watch(newsFeedServiceProvider);
    try {
      debugPrint("AsyncNotifier build: Fetching initial page...");
      final response = await service.getArticlePreviews(limit: 20);
      _allFetchedArticles = response.articles;
      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;
      debugPrint(
        "AsyncNotifier build: Fetched ${_allFetchedArticles.length} articles. Next cursor: $_nextCursor HasMore: $_hasMore",
      );
      return _allFetchedArticles;
    } catch (e, stack) {
      debugPrint("Error in AsyncNotifier build: $e\n$stack");
      _hasMore = false;
      throw Exception("Failed to load initial articles: $e");
    }
  }

  Future<void> loadOlder() async {
    debugPrint("loadOlder called.");
    ref.read(newsFeedDisplayModeProvider.notifier).state =
        NewsFeedDisplayMode.all;
    debugPrint("Display mode set to 'all'.");
  }

  Future<void> fetchNextPage() async {
    final displayMode = ref.read(newsFeedDisplayModeProvider);
    if (displayMode != NewsFeedDisplayMode.all ||
        _isLoadingMore ||
        !_hasMore ||
        _nextCursor == null) {
      debugPrint(
        "fetchNextPage skipped: mode=$displayMode, loading=$_isLoadingMore, hasMore=$_hasMore, cursor=$_nextCursor",
      );
      return;
    }

    debugPrint("Fetching next page with cursor: $_nextCursor");
    _isLoadingMore = true;

    final service = ref.read(newsFeedServiceProvider);

    try {
      final response = await service.getArticlePreviews(
        cursor: _nextCursor!,
        limit: 20,
      );

      _nextCursor = response.nextCursor;
      _hasMore = _nextCursor != null;

      _allFetchedArticles = [..._allFetchedArticles, ...response.articles];

      state = AsyncData<List<ArticlePreview>>(
        _allFetchedArticles,
      ); // Explicit type
      debugPrint(
        "Next page fetched. Total articles: ${_allFetchedArticles.length}. Has more: $_hasMore",
      );
    } catch (e, stack) {
      debugPrint("Error fetching next page: $e\n$stack");
      // --- FIX for Error 1 ---
      // Ensure AsyncError has the correct type and provide previous state
      state = AsyncError<List<ArticlePreview>>(
        e,
        stack,
      ).copyWithPrevious(state);
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    debugPrint("Refresh requested.");
    _nextCursor = null;
    _hasMore = true;
    _isLoadingMore = false;
    _allFetchedArticles = [];
    ref.invalidateSelf();
    await future; // Await the rebuild completion
    debugPrint("Refresh complete.");
  }
}

// --- Derived Provider for Headline Article ---
final headlineArticleProvider = Provider<AsyncValue<ArticlePreview?>>((ref) {
  final articlesAsyncValue = ref.watch(paginatedArticlesProvider);
  final selectedTeamAsyncValue = ref.watch(selectedTeamNotifierProvider);

  if (articlesAsyncValue is AsyncLoading ||
      selectedTeamAsyncValue is AsyncLoading) {
    return const AsyncValue.loading();
  }

  // --- FIX for Error 2 & 3 ---
  if (articlesAsyncValue is AsyncError) {
    // Provide default values for error and stackTrace if they are null
    final error = articlesAsyncValue.error ?? Exception("Unknown error");
    final stackTrace = articlesAsyncValue.stackTrace ?? StackTrace.current;
    return AsyncValue.error(error, stackTrace);
  }
  if (selectedTeamAsyncValue is AsyncError) {
    debugPrint(
      "Error loading team preference for headline, falling back to latest overall.",
    );
    // Don't return error, proceed to use articlesAsyncValue.value
  }

  final allArticles = articlesAsyncValue.value ?? [];
  final selectedTeamId = selectedTeamAsyncValue.valueOrNull;

  if (allArticles.isEmpty) {
    return const AsyncValue.data(null);
  }

  List<ArticlePreview> potentialHeadlines = [];

  if (selectedTeamId != null) {
    potentialHeadlines =
        allArticles.where((a) => a.teamId == selectedTeamId).toList();
    if (potentialHeadlines.isEmpty) {
      potentialHeadlines = allArticles;
      debugPrint(
        "No articles for team $selectedTeamId found, using latest overall for headline.",
      );
    } else {
      debugPrint(
        "Found ${potentialHeadlines.length} articles for team $selectedTeamId for headline consideration.",
      );
    }
  } else {
    potentialHeadlines = allArticles;
    debugPrint("No team selected, using latest overall for headline.");
  }

  if (potentialHeadlines.isEmpty) {
    return const AsyncValue.data(null);
  }

  potentialHeadlines.sort((a, b) {
    final dateA = a.createdAt ?? DateTime(1970);
    final dateB = b.createdAt ?? DateTime(1970);
    return dateB.compareTo(dateA);
  });

  debugPrint("Headline article selected: ID ${potentialHeadlines.first.id}");
  return AsyncValue.data(potentialHeadlines.first);
});
