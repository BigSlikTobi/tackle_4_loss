// lib/features/news_feed/ui/news_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Import SmoothPageIndicator
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart'; // Re-enabled import
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart'; // New import
import 'package:tackle_4_loss/features/news_feed/logic/featured_cluster_provider.dart'; // New import
// import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart'; // Already imported by provider
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';
import 'dart:math' as math;

import 'package:tackle_4_loss/features/news_feed/ui/widgets/nfl_headline_item_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/cluster_info_list_item.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/other_news_list_item.dart';
import 'package:tackle_4_loss/features/all_news/ui/all_news_screen.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  late PageController _featuredClusterPageController; // Renamed and re-purposed

  @override
  void initState() {
    super.initState();
    // Initialize with a large initial page for infinite looping illusion if desired,
    // or 0 if not. For simplicity, let's start with 0.
    _featuredClusterPageController = PageController(initialPage: 0);
    // For Story Lines, pre-fetch data for the first page if needed.
    // This ensures that when the widget builds, data for page 1 is likely already loading or loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(paginatedClusterInfosProvider.notifier)
            .ensureDataForStoryLinesPage(1);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _featuredClusterPageController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    debugPrint("NewsFeedScreen refresh triggered.");
    ref.invalidate(featuredClusterProvider);
    ref.invalidate(paginatedClusterInfosProvider);
    ref.invalidate(paginatedArticlesProvider(null));

    // Reset PageView to the first page on refresh
    if (_featuredClusterPageController.hasClients) {
      _featuredClusterPageController.jumpToPage(0);
    }
    ref.read(featuredClusterPageIndexProvider.notifier).state = 0;

    ref.read(storyLinesCurrentPageProvider.notifier).state = 1;
    // After invalidating, ensure data for the new page 1 is fetched.
    await ref
        .read(paginatedClusterInfosProvider.notifier)
        .ensureDataForStoryLinesPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final featuredClusterAsync = ref.watch(featuredClusterProvider);
    final paginatedClusterInfosAsync = ref.watch(paginatedClusterInfosProvider);
    final otherNewsTop8Async = ref.watch(paginatedArticlesProvider(null));

    ref.watch(realtimeServiceProvider);

    // Ensure data for the current Story Lines page is loaded before building the list.
    // This is important when the page number changes.
    final currentStoryLinesUiPage = ref.watch(storyLinesCurrentPageProvider);
    // Call ensureDataForStoryLinesPage here directly in build.
    // Riverpod handles memoization, so it's safe to call.
    // This will trigger fetches if needed when currentStoryLinesUiPage changes.
    // Note: ensureDataForStoryLinesPage is async, but we don't await it here in build.
    // The provider will update its state, and the UI will rebuild.
    ref
        .read(paginatedClusterInfosProvider.notifier)
        .ensureDataForStoryLinesPage(currentStoryLinesUiPage);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildFeaturedClusterStorySection(
              context,
              featuredClusterAsync,
            ), // Updated method call
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Text(
                  "Story Lines",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildStoryLinesPaginatedListSection(
              context,
              paginatedClusterInfosAsync,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
                child: Text(
                  "Other News",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildOtherNewsTop8List(context, otherNewsTop8Async),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  // Renamed and refactored from _buildNflHeadlinesSection
  Widget _buildFeaturedClusterStorySection(
    BuildContext context,
    AsyncValue<List<ClusterArticle>>
    featuredClusterAsync, // Takes list of ClusterArticle
  ) {
    final theme = Theme.of(context);
    const double pageViewHeight = 250.0;
    const double indicatorHeight = 8.0;
    const double spacingBelowIndicator = 12.0;
    final totalHeight =
        pageViewHeight + indicatorHeight + spacingBelowIndicator;

    return featuredClusterAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: totalHeight,
              child: Center(
                child: Text(
                  "No featured stories available.",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }

        // If PageController was disposed and recreated, ensure it's up to date.
        // This might be needed if the widget rebuilds significantly.
        if (!_featuredClusterPageController.hasClients && articles.isNotEmpty) {
          _featuredClusterPageController = PageController(
            initialPage: ref.read(featuredClusterPageIndexProvider),
          );
        }

        return SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: pageViewHeight,
                child: PageView.builder(
                  controller: _featuredClusterPageController,
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: NflHeadlineItemCard(clusterArticle: article),
                    );
                  },
                  onPageChanged: (index) {
                    ref.read(featuredClusterPageIndexProvider.notifier).state =
                        index;
                  },
                ),
              ),
              if (articles.length > 1)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: spacingBelowIndicator,
                  ),
                  child: SmoothPageIndicator(
                    controller: _featuredClusterPageController,
                    count: articles.length,
                    effect: ScrollingDotsEffect(
                      dotHeight: indicatorHeight,
                      dotWidth: indicatorHeight,
                      activeDotScale: 1.5,
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: Colors.grey.shade300,
                    ),
                    onDotClicked: (index) {
                      _featuredClusterPageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              if (articles.length <= 1) // Reserve space even if no indicator
                const SizedBox(height: indicatorHeight + spacingBelowIndicator),
            ],
          ),
        );
      },
      loading:
          () => SliverToBoxAdapter(
            child: SizedBox(
              height: totalHeight,
              child: const Center(child: LoadingIndicator()),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: SizedBox(
              height: totalHeight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageWidget(
                  message: "Could not load featured stories: $error",
                  onRetry: () => ref.invalidate(featuredClusterProvider),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildStoryLinesPaginatedListSection(
    BuildContext context,
    AsyncValue<List<dynamic>> paginatedClusterInfosAsync,
  ) {
    final clusterNotifier = ref.read(paginatedClusterInfosProvider.notifier);
    final currentUiPage = ref.watch(storyLinesCurrentPageProvider);

    return paginatedClusterInfosAsync.when(
      data: (allFetchedClusters) {
        // We call ensureDataForStoryLinesPage in the main build method now.
        // This ensures that by the time we get here with new `currentUiPage`,
        // the fetching process (if needed) has already been initiated.
        // The UI will reactively update once the new data is loaded into `allFetchedClusters`.

        if (allFetchedClusters.isEmpty && !clusterNotifier.isLoadingMore) {
          debugPrint(
            "[Story Lines UI] All fetched clusters empty and not loading more.",
          );
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text("No story lines available.")),
            ),
          );
        }

        // Calculate items for the current UI page
        final startIndex = (currentUiPage - 1) * storyLinesPerPage;
        final endIndex = math.min(
          startIndex + storyLinesPerPage,
          allFetchedClusters.length,
        );

        List<dynamic> currentPageDisplayItems = [];
        if (startIndex < allFetchedClusters.length && startIndex < endIndex) {
          // Ensure startIndex is valid
          currentPageDisplayItems = allFetchedClusters.sublist(
            startIndex,
            endIndex,
          );
        } else if (allFetchedClusters.isNotEmpty &&
            startIndex >= allFetchedClusters.length &&
            !clusterNotifier.hasMoreData) {
          // If trying to access a page beyond available data and no more data is expected.
          // This might happen if page was decremented from a higher number after data reduced.
          // Or if ensureDataForStoryLinesPage hasn't completed a fetch that would satisfy this page yet.
          debugPrint(
            "[Story Lines UI] Current UI page $currentUiPage is beyond available data (${allFetchedClusters.length} items) and no more expected. Displaying empty or loading.",
          );
          // currentPageDisplayItems remains empty. Loading indicator or empty message will be shown by childCount logic.
        }

        debugPrint(
          "[Story Lines UI] Building for UI page $currentUiPage. Displaying items $startIndex-$endIndex from ${allFetchedClusters.length} buffered items. HasMoreBackend: ${clusterNotifier.hasMoreData}. IsLoadingMoreBackend: ${clusterNotifier.isLoadingMore}",
        );

        final totalFetchedItemsInBuffer =
            clusterNotifier.totalFetchedClusterItems;
        // Total displayable UI pages based on what's ALREADY in the buffer.
        final totalDisplayableUiPagesInBuffer =
            (totalFetchedItemsInBuffer / storyLinesPerPage).ceil();

        // Next button is enabled if current UI page < total displayable ui pages OR if backend has more data.
        final bool canGoNext =
            currentUiPage < totalDisplayableUiPagesInBuffer ||
            clusterNotifier.hasMoreData;
        final bool canGoPrev = currentUiPage > 1;

        // Determine child count for SliverList
        int childCount = currentPageDisplayItems.length;
        bool showPaginationControls =
            (canGoPrev ||
                canGoNext ||
                (clusterNotifier.isLoadingMore &&
                    currentPageDisplayItems.isEmpty));
        bool showLoadingIndicatorAtEnd =
            clusterNotifier.isLoadingMore && currentPageDisplayItems.isNotEmpty;

        if (showPaginationControls) childCount++;
        if (showLoadingIndicatorAtEnd) childCount++;

        if (currentPageDisplayItems.isEmpty &&
            !clusterNotifier.isLoadingMore &&
            !clusterNotifier.hasMoreData &&
            allFetchedClusters.isNotEmpty) {
          // This case implies we are on a page that has no items, and no more are coming
          // but there *were* items, so we should show pagination to go back.
          // If allFetchedClusters is also empty, the top check handles "No story lines".
        } else if (currentPageDisplayItems.isEmpty &&
            clusterNotifier.isLoadingMore) {
          // If current page is empty AND we are loading, just show loading indicator in place of items/pagination
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: LoadingIndicator(key: Key("story_lines_page_loading")),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            // Displaying items for the current UI page
            if (index < currentPageDisplayItems.length) {
              final cluster = currentPageDisplayItems[index];
              return ClusterInfoListItem(cluster: cluster);
            }
            // Determine if this index is for pagination controls or loading indicator
            int effectiveIndexAfterItems =
                index - currentPageDisplayItems.length;

            if (effectiveIndexAfterItems == 0 && showPaginationControls) {
              // Pagination controls row
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          canGoPrev
                              ? () {
                                ref
                                    .read(
                                      storyLinesCurrentPageProvider.notifier,
                                    )
                                    .state--;
                              }
                              : null,
                      tooltip: "Previous Story Page",
                    ),
                    Text(
                      "Page $currentUiPage${totalDisplayableUiPagesInBuffer > 0 && !clusterNotifier.hasMoreData ? ' of $totalDisplayableUiPagesInBuffer' : ''}",
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          canGoNext
                              ? () async {
                                // Request data for the *next UI page* to be available
                                // ensureDataForStoryLinesPage will trigger backend fetches if items for (currentUiPage + 1) are not buffered.
                                await clusterNotifier
                                    .ensureDataForStoryLinesPage(
                                      currentUiPage + 1,
                                    );
                                // After ensuring data, if we can indeed advance (i.e., items for next page are now in buffer or were already there)
                                if (mounted &&
                                    (currentUiPage + 1) * storyLinesPerPage <=
                                        clusterNotifier
                                            .totalFetchedClusterItems) {
                                  ref
                                      .read(
                                        storyLinesCurrentPageProvider.notifier,
                                      )
                                      .state++;
                                } else if (mounted &&
                                    !clusterNotifier.hasMoreData &&
                                    currentUiPage * storyLinesPerPage >=
                                        clusterNotifier
                                            .totalFetchedClusterItems) {
                                  // We are at the very end, no more data from backend, and no more buffered items for a new page.
                                  debugPrint(
                                    "[Story Lines UI] Next tapped, but at the absolute end.",
                                  );
                                } else if (mounted) {
                                  // Data for next page might still be loading, or fetch failed. UI should reflect current state.
                                  debugPrint(
                                    "[Story Lines UI] Next tapped, ensureData called. Current items: ${clusterNotifier.totalFetchedClusterItems}. Waiting for UI to update if new items were fetched.",
                                  );
                                }
                              }
                              : null,
                      tooltip: "Next Story Page",
                    ),
                  ],
                ),
              );
            } else if (effectiveIndexAfterItems ==
                    (showPaginationControls ? 1 : 0) &&
                showLoadingIndicatorAtEnd) {
              // Loading indicator at the very end of the list if applicable
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: LoadingIndicator(key: Key("story_lines_end_loading")),
              );
            }
            return null; // Should not be reached if childCount is correct
          }, childCount: childCount),
        );
      },
      loading:
          () => const SliverToBoxAdapter(
            // Initial loading for the whole section
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: LoadingIndicator(
                  key: Key("story_lines_initial_loading"),
                ),
              ),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorMessageWidget(
                message: "Could not load story lines: $error",
                onRetry: () {
                  ref.invalidate(paginatedClusterInfosProvider);
                  ref.read(storyLinesCurrentPageProvider.notifier).state = 1;
                  // Ensure data for page 1 is re-fetched on retry
                  ref
                      .read(paginatedClusterInfosProvider.notifier)
                      .ensureDataForStoryLinesPage(1);
                },
              ),
            ),
          ),
    );
  }

  Widget _buildOtherNewsTop8List(
    BuildContext context,
    AsyncValue<List<ArticlePreview>> otherNewsTop8Async,
  ) {
    final theme = Theme.of(context);

    return otherNewsTop8Async.when(
      data: (top8Articles) {
        if (top8Articles.isEmpty && !otherNewsTop8Async.isLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text("No other news available.")),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < top8Articles.length) {
                return Column(
                  children: [
                    OtherNewsListItem(article: top8Articles[index]),
                    if (index < top8Articles.length - 1)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Colors.grey[200],
                      ),
                  ],
                );
              } else if (index == top8Articles.length &&
                  top8Articles.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        debugPrint(
                          "See all News tapped - Navigating to AllNewsScreen",
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllNewsScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          "See all News →",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
            childCount: top8Articles.length + (top8Articles.isNotEmpty ? 1 : 0),
          ),
        );
      },
      loading:
          () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: LoadingIndicator()),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorMessageWidget(
                message: "Could not load other news: $error",
                onRetry: () {
                  ref.invalidate(paginatedArticlesProvider(null));
                },
              ),
            ),
          ),
    );
  }
}
