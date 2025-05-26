// lib/features/news_feed/logic/story_lines_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/news_feed/data/story_lines_service.dart';
import 'package:tackle_4_loss/features/news_feed/data/story_line_item.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';

// Provider for the StoryLinesService
final storyLinesServiceProvider = Provider<StoryLinesService>((ref) {
  return StoryLinesService();
});

// Provider for current page tracking
final storyLinesCurrentPageProvider = StateProvider<int>((ref) => 1);

// Constants for pagination
const int storyLinesPerPage = 6; // UI display items per page
const int storyLinesBackendFetchLimit = 25; // Backend fetch limit per call

// Main provider for paginated story lines
final paginatedStoryLinesProvider =
    AsyncNotifierProvider<PaginatedStoryLinesNotifier, List<StoryLineItem>>(
      () => PaginatedStoryLinesNotifier(),
    );

class PaginatedStoryLinesNotifier extends AsyncNotifier<List<StoryLineItem>> {
  String? _nextPage;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<StoryLineItem> _allFetchedStoryLines = [];
  final Set<String> _seenClusterIds = <String>{};

  @override
  Future<List<StoryLineItem>> build() async {
    final locale = ref.watch(localeNotifierProvider);
    final languageCode = locale.languageCode;

    // Add platform debugging
    debugPrint("=== STORY LINES PROVIDER BUILD START ===");
    debugPrint(
      "[PaginatedStoryLinesNotifier] Platform: ${kIsWeb ? 'Web' : 'Mobile'}",
    );
    debugPrint(
      "[PaginatedStoryLinesNotifier] Default Target Platform: $defaultTargetPlatform",
    );
    debugPrint("[PaginatedStoryLinesNotifier] Language Code: $languageCode");

    // ALWAYS reset state on every build to prevent cross-language contamination
    debugPrint(
      "[PaginatedStoryLinesNotifier] Force resetting state for build (languageCode: $languageCode)",
    );
    debugPrint(
      "[PaginatedStoryLinesNotifier] Before reset - _seenClusterIds: ${_seenClusterIds.toList()}",
    );

    _nextPage = null;
    _isLoadingMore = false;
    _allFetchedStoryLines = [];
    _seenClusterIds.clear();
    _hasMore = true;

    debugPrint(
      "[PaginatedStoryLinesNotifier] After reset - _seenClusterIds: ${_seenClusterIds.toList()}",
    );

    final service = ref.watch(storyLinesServiceProvider);

    debugPrint(
      "[PaginatedStoryLinesNotifier] Build started for languageCode: $languageCode. Fetching initial batch (limit: $storyLinesBackendFetchLimit)...",
    );

    try {
      final response = await service.getStoryLines(
        languageCode: languageCode,
        page: 1,
        limit: storyLinesBackendFetchLimit,
      );

      final uniqueInitialStoryLines =
          response.data.where((storyLine) {
            // Use composite key: clusterId + languageCode
            final compositeKey =
                "[33m[1m[4m[7m${storyLine.clusterId}|$languageCode[0m";
            final isUnique = _seenClusterIds.add(compositeKey);
            debugPrint(
              "[PaginatedStoryLinesNotifier] Processing cluster ${storyLine.clusterId} (lang: $languageCode): key='$compositeKey' => ${isUnique ? 'UNIQUE' : 'DUPLICATE'}",
            );
            return isUnique;
          }).toList();

      debugPrint(
        "[PaginatedStoryLinesNotifier] Final _seenClusterIds after filtering: [36m${_seenClusterIds.toList()}[0m",
      );

      _allFetchedStoryLines = uniqueInitialStoryLines;
      _hasMore = response.pagination.hasNext;
      _nextPage = _hasMore ? (response.pagination.page + 1).toString() : null;

      debugPrint(
        "[PaginatedStoryLinesNotifier] Initial fetch complete for languageCode: $languageCode. Fetched ${response.data.length} (unique: ${_allFetchedStoryLines.length}). Next page: '$_nextPage'. HasMore: $_hasMore",
      );
      debugPrint("=== STORY LINES PROVIDER BUILD SUCCESS ===");

      return _allFetchedStoryLines;
    } catch (e, stack) {
      debugPrint(
        "[PaginatedStoryLinesNotifier] Error in build for languageCode $languageCode: $e\n$stack",
      );
      debugPrint("=== STORY LINES PROVIDER BUILD ERROR ===");
      _hasMore = false;
      throw Exception("Failed to load initial story lines: $e");
    }
  }

  Future<void> fetchNextPage() async {
    final currentLanguageCode = ref.read(localeNotifierProvider).languageCode;

    if (_isLoadingMore || !_hasMore || _nextPage == null) {
      debugPrint(
        "[PaginatedStoryLinesNotifier] fetchNextPage skipped for languageCode $currentLanguageCode: loading=$_isLoadingMore, hasMore=$_hasMore, nextPage=$_nextPage",
      );
      return;
    }

    debugPrint(
      "[PaginatedStoryLinesNotifier] Fetching next page $_nextPage for languageCode: $currentLanguageCode (fetch limit: $storyLinesBackendFetchLimit)",
    );

    _isLoadingMore = true;
    state = AsyncData(_allFetchedStoryLines);

    final service = ref.read(storyLinesServiceProvider);
    final currentPage = _nextPage;

    try {
      final response = await service.getStoryLines(
        languageCode: currentLanguageCode,
        page: int.parse(currentPage!),
        limit: storyLinesBackendFetchLimit,
      );

      int newUniqueCount = 0;
      final List<StoryLineItem> newStoryLinesToAppend = [];
      for (final storyLine in response.data) {
        // Use composite key: clusterId + languageCode
        final compositeKey = "${storyLine.clusterId}|$currentLanguageCode";
        if (_seenClusterIds.add(compositeKey)) {
          newStoryLinesToAppend.add(storyLine);
          newUniqueCount++;
          debugPrint(
            "[PaginatedStoryLinesNotifier] Processing cluster ${storyLine.clusterId} (lang: $currentLanguageCode): key='$compositeKey' => UNIQUE",
          );
        } else {
          debugPrint(
            "[PaginatedStoryLinesNotifier] Processing cluster ${storyLine.clusterId} (lang: $currentLanguageCode): key='$compositeKey' => DUPLICATE",
          );
        }
      }

      if (newUniqueCount > 0) {
        _allFetchedStoryLines = [
          ..._allFetchedStoryLines,
          ...newStoryLinesToAppend,
        ];
      }

      _hasMore = response.pagination.hasNext;
      _nextPage = _hasMore ? (response.pagination.page + 1).toString() : null;

      debugPrint(
        "[PaginatedStoryLinesNotifier] Next page fetched for languageCode $currentLanguageCode. Fetched ${response.data.length} (new unique: $newUniqueCount). Total unique: ${_allFetchedStoryLines.length}. Has more: $_hasMore. New nextPage: '$_nextPage'",
      );

      state = AsyncData<List<StoryLineItem>>(_allFetchedStoryLines);
    } catch (e, stack) {
      debugPrint(
        "[PaginatedStoryLinesNotifier] Error fetching next page $currentPage for languageCode $currentLanguageCode: $e\n$stack",
      );
      _hasMore = false;
      state = AsyncError<List<StoryLineItem>>(
        e,
        stack,
      ).copyWithPrevious(AsyncData(_allFetchedStoryLines));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> ensureDataForStoryLinesPage(int uiPageNumber) async {
    final currentLanguageCode = ref.read(localeNotifierProvider).languageCode;
    final itemsNeededForUi = uiPageNumber * storyLinesPerPage;

    debugPrint(
      "[PaginatedStoryLinesNotifier] Ensuring data for Story Lines UI page $uiPageNumber (languageCode: $currentLanguageCode). Items needed for UI: $itemsNeededForUi. Currently have in buffer: ${_allFetchedStoryLines.length}. HasMore from backend: $_hasMore. IsLoadingMore: $_isLoadingMore. NextPage: '$_nextPage'",
    );

    // Loop to fetch pages until enough items are loaded for the target UI page OR no more data from backend
    while (_allFetchedStoryLines.length < itemsNeededForUi &&
        _hasMore &&
        !_isLoadingMore &&
        _nextPage != null) {
      debugPrint(
        "[PaginatedStoryLinesNotifier] Not enough data in buffer for UI page $uiPageNumber (need $itemsNeededForUi, have ${_allFetchedStoryLines.length}). Fetching next backend page $_nextPage...",
      );
      await fetchNextPage();
    }

    debugPrint(
      "[PaginatedStoryLinesNotifier] Finished ensuring data for Story Lines UI page $uiPageNumber (languageCode: $currentLanguageCode). Total items in buffer: ${_allFetchedStoryLines.length}. HasMore: $_hasMore",
    );
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMore;
  int get totalFetchedStoryLineItems => _allFetchedStoryLines.length;
}
