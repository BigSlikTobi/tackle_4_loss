import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; // For min function

import 'package:tackle_4_loss/features/news_feed/ui/widgets/nfl_headline_item_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/cluster_info_grid_item.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/other_news_list_item.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final ScrollController _scrollController =
      ScrollController(); // Still needed for overall CustomScrollView
  late PageController _nflHeadlinesPageController;
  late PageController _storyLinesPageController;

  @override
  void initState() {
    super.initState();
    _nflHeadlinesPageController = PageController(initialPage: 1000);
    _storyLinesPageController = PageController(initialPage: 1000);
    // _scrollController.addListener(_onScroll); // No longer needed for "Other News" pagination
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll); // Remove if not used
    _scrollController.dispose();
    _nflHeadlinesPageController.dispose();
    _storyLinesPageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    debugPrint("NewsFeedScreen refresh triggered.");
    ref.invalidate(nflHeadlinesProvider);
    ref.invalidate(clusterInfosProvider);
    ref.invalidate(paginatedArticlesProvider(null));
    ref.read(otherNewsCurrentPageProvider.notifier).state =
        1; // Reset page to 1

    final nflHeadlines = ref.read(nflHeadlinesProvider).valueOrNull;
    if (_nflHeadlinesPageController.hasClients &&
        nflHeadlines != null &&
        nflHeadlines.isNotEmpty) {
      _nflHeadlinesPageController.jumpToPage(1000);
    }
    ref.read(nflHeadlinesPageIndexProvider.notifier).state = 0;

    final clusterInfos = ref.read(clusterInfosProvider).valueOrNull;
    if (_storyLinesPageController.hasClients &&
        clusterInfos != null &&
        clusterInfos.isNotEmpty) {
      _storyLinesPageController.jumpToPage(1000);
    }
    ref.read(storyLinesPageIndexProvider.notifier).state = 0;
  }

  // _onScroll is no longer paginating "Other News"
  // void _onScroll() {
  //   if (_scrollController.position.pixels >=
  //       _scrollController.position.maxScrollExtent - 300) {
  //     // Logic for other paginated sections if CustomScrollView itself needs it
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final nflHeadlinesAsync = ref.watch(nflHeadlinesProvider);
    final clusterInfosAsync = ref.watch(clusterInfosProvider);
    final otherNewsDataAsync = ref.watch(paginatedArticlesProvider(null));

    ref.watch(realtimeServiceProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildNflHeadlinesSection(context, nflHeadlinesAsync),
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
            _buildStoryLinesPageViewSection(context, clusterInfosAsync),
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
            _buildOtherNewsPaginatedList(
              context,
              otherNewsDataAsync,
            ), // Changed to new method
            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildNflHeadlinesSection(
    BuildContext context,
    AsyncValue<List<ArticlePreview>> nflHeadlinesAsync,
  ) {
    // ... (This section remains the same)
    final theme = Theme.of(context);
    const double pageViewHeight = 250.0;
    const double indicatorHeight = 8.0;
    const double spacingBelowIndicator = 12.0;

    return nflHeadlinesAsync.when(
      data: (headlines) {
        if (headlines.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: pageViewHeight + indicatorHeight + spacingBelowIndicator,
              child: Center(
                child: Text(
                  "No NFL headlines available.",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }
        final actualItemCount = headlines.length;
        final pageViewItemCount =
            actualItemCount > 1 ? actualItemCount * 2000 : actualItemCount;

        if (actualItemCount > 0 &&
            _nflHeadlinesPageController.positions.isEmpty) {
          _nflHeadlinesPageController = PageController(
            initialPage: actualItemCount > 1 ? 1000 : 0,
          );
          debugPrint(
            "[NFLHeadlines PView] Re-initialized _nflHeadlinesPageController with initialPage: ${actualItemCount > 1 ? 1000 : 0}",
          );
        } else if (actualItemCount == 0 &&
            _nflHeadlinesPageController.positions.isEmpty) {
          _nflHeadlinesPageController = PageController(initialPage: 0);
          debugPrint(
            "[NFLHeadlines PView] Initialized _nflHeadlinesPageController with initialPage: 0 (no pages)",
          );
        }

        return SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: pageViewHeight,
                child: PageView.builder(
                  controller: _nflHeadlinesPageController,
                  itemCount: pageViewItemCount,
                  itemBuilder: (context, index) {
                    final actualIndex =
                        actualItemCount > 0 ? index % actualItemCount : 0;
                    if (actualItemCount == 0) return const SizedBox.shrink();
                    final article = headlines[actualIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: NflHeadlineItemCard(article: article),
                    );
                  },
                  onPageChanged: (index) {
                    ref.read(nflHeadlinesPageIndexProvider.notifier).state =
                        actualItemCount > 0 ? index % actualItemCount : 0;
                  },
                ),
              ),
              if (actualItemCount > 1)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: spacingBelowIndicator,
                  ),
                  child: SmoothPageIndicator(
                    controller: _nflHeadlinesPageController,
                    count: actualItemCount,
                    effect: ScrollingDotsEffect(
                      dotHeight: indicatorHeight,
                      dotWidth: indicatorHeight,
                      activeDotScale: 1.5,
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: Colors.grey.shade300,
                    ),
                  ),
                ),
              if (actualItemCount <= 1)
                const SizedBox(height: indicatorHeight + spacingBelowIndicator),
            ],
          ),
        );
      },
      loading:
          () => SliverToBoxAdapter(
            child: SizedBox(
              height: pageViewHeight + indicatorHeight + spacingBelowIndicator,
              child: const Center(child: LoadingIndicator()),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: SizedBox(
              height: pageViewHeight + indicatorHeight + spacingBelowIndicator,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageWidget(
                  message: "Could not load NFL headlines: $error",
                  onRetry: () => ref.invalidate(nflHeadlinesProvider),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildStoryLinesPageViewSection(
    BuildContext context,
    AsyncValue<List<ClusterInfo>> clusterInfosAsync,
  ) {
    // ... (This section remains the same)
    final theme = Theme.of(context);
    const double cardHeightEstimate = 200;
    const double gridSpacing = 10.0;
    const double pageViewHeight = (cardHeightEstimate * 2) + gridSpacing + 40;
    const double indicatorHeight = 8.0;
    const double spacingBelowIndicator = 12.0;
    const int itemsPerPage = 4;

    return clusterInfosAsync.when(
      data: (clustersDataFromProvider) {
        final List<ClusterInfo> allClusters = List.unmodifiable(
          clustersDataFromProvider,
        );

        final allClusterIdsSnapshot =
            allClusters.map((c) => c.clusterId.substring(0, 8)).toList();
        debugPrint(
          "[StoryLines PView Build] Snapshot of allCluster IDs: $allClusterIdsSnapshot (Total: ${allClusters.length})",
        );

        if (allClusters.isEmpty &&
            !ref.read(clusterInfosProvider.notifier).isLoadingMore) {
          debugPrint(
            "[StoryLines PView Build] All clusters empty, not loading more.",
          );
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  "No story lines available.",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }

        final int totalPages = (allClusters.length / itemsPerPage).ceil();
        debugPrint(
          "[StoryLines PView Build] Calculated Total Actual Pages: $totalPages from ${allClusters.length} items.",
        );

        final pageViewTotalPagesForCircularScroll =
            (totalPages > 0)
                ? (totalPages > 1 ? totalPages * 2000 : totalPages)
                : 1;

        if (totalPages > 0 && _storyLinesPageController.positions.isEmpty) {
          _storyLinesPageController = PageController(
            initialPage: totalPages > 1 ? 1000 : 0,
          );
          debugPrint(
            "[StoryLines PView Build] Re-initialized _storyLinesPageController with initialPage: ${totalPages > 1 ? 1000 : 0}",
          );
        } else if (totalPages == 0 &&
            _storyLinesPageController.positions.isEmpty) {
          _storyLinesPageController = PageController(initialPage: 0);
          debugPrint(
            "[StoryLines PView Build] Initialized _storyLinesPageController with initialPage: 0 (no pages)",
          );
        }

        final currentStoryLinesPageIndicatorIndex = ref.watch(
          storyLinesPageIndexProvider,
        );
        final clusterNotifier = ref.read(clusterInfosProvider.notifier);

        if (totalPages > 0 &&
            currentStoryLinesPageIndicatorIndex >= (totalPages - 2) &&
            clusterNotifier.hasMore &&
            !clusterNotifier.isLoadingMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint(
                "[StoryLines PView Build] Near end of loaded data (indicator at page $currentStoryLinesPageIndicatorIndex / ${totalPages - 1}), fetching more clusters...",
              );
              clusterNotifier.fetchNextPage();
            }
          });
        }

        return SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: pageViewHeight,
                child: PageView.builder(
                  controller: _storyLinesPageController,
                  itemCount: pageViewTotalPagesForCircularScroll,
                  itemBuilder: (context, pageViewIndex) {
                    if (totalPages == 0) {
                      return Center(
                        child: Text(
                          "No items for this page.",
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }
                    final actualPageIndex = pageViewIndex % totalPages;

                    final startIndex = actualPageIndex * itemsPerPage;
                    final endIndex =
                        (startIndex + itemsPerPage < allClusters.length)
                            ? startIndex + itemsPerPage
                            : allClusters.length;

                    if (startIndex >= endIndex ||
                        (startIndex >= allClusters.length &&
                            allClusters.isNotEmpty)) {
                      debugPrint(
                        "[StoryLines PView ItemBuilder] Invalid range or no items for actualPage $actualPageIndex. Start: $startIndex, End: $endIndex, Total Items: ${allClusters.length}. pageViewIndex: $pageViewIndex",
                      );
                      return Container(
                        alignment: Alignment.center,
                        child: const SizedBox.shrink(),
                      );
                    } else if (allClusters.isEmpty && startIndex == 0) {
                      return const SizedBox.shrink();
                    }

                    final pageItems = allClusters.sublist(startIndex, endIndex);

                    final itemIdsOnPage = pageItems
                        .map((c) => c.clusterId.substring(0, 8))
                        .join(', ');
                    debugPrint(
                      "[StoryLines PView ItemBuilder] pViewIdx: $pageViewIndex, actualPIdx: $actualPageIndex, range:[$startIndex-$endIndex), items: [$itemIdsOnPage] from total ${allClusters.length}",
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pageItems.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: gridSpacing,
                              mainAxisSpacing: gridSpacing,
                              childAspectRatio: 1.0,
                            ),
                        itemBuilder: (context, gridIndex) {
                          return ClusterInfoGridItem(
                            cluster: pageItems[gridIndex],
                          );
                        },
                      ),
                    );
                  },
                  onPageChanged: (pageViewIndex) {
                    final actualPageIndex =
                        totalPages > 0 ? pageViewIndex % totalPages : 0;
                    ref.read(storyLinesPageIndexProvider.notifier).state =
                        actualPageIndex;
                    debugPrint(
                      "[StoryLines PView onPageChanged] pViewIdx: $pageViewIndex, actualPIdx set to: $actualPageIndex",
                    );
                  },
                ),
              ),
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: spacingBelowIndicator,
                  ),
                  child: SmoothPageIndicator(
                    controller: _storyLinesPageController,
                    count: totalPages,
                    effect: ScrollingDotsEffect(
                      dotHeight: indicatorHeight,
                      dotWidth: indicatorHeight,
                      activeDotScale: 1.5,
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: Colors.grey.shade300,
                    ),
                    onDotClicked: (dotIndex) {
                      final targetVirtualPage =
                          (1000 ~/ totalPages) * totalPages + dotIndex;
                      _storyLinesPageController.animateToPage(
                        targetVirtualPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              if (totalPages <= 1)
                const SizedBox(height: indicatorHeight + spacingBelowIndicator),

              if (clusterNotifier.isLoadingMore && allClusters.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: LoadingIndicator(),
                ),
            ],
          ),
        );
      },
      loading:
          () => SliverToBoxAdapter(
            child: SizedBox(
              height:
                  pageViewHeight +
                  indicatorHeight +
                  spacingBelowIndicator +
                  ((ref.read(clusterInfosProvider.notifier).isLoadingMore)
                      ? 50
                      : 0),
              child: const Center(child: LoadingIndicator()),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: SizedBox(
              height: pageViewHeight + indicatorHeight + spacingBelowIndicator,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageWidget(
                  message: "Could not load story lines: $error",
                  onRetry: () => ref.invalidate(clusterInfosProvider),
                ),
              ),
            ),
          ),
    );
  }

  // --- NEW: Method for "Other News" with Explicit Pagination ---
  Widget _buildOtherNewsPaginatedList(
    BuildContext context,
    AsyncValue<List<ArticlePreview>> otherNewsDataAsync,
  ) {
    final theme = Theme.of(context);
    final currentPage = ref.watch(otherNewsCurrentPageProvider);
    final articlesNotifier = ref.read(paginatedArticlesProvider(null).notifier);

    return otherNewsDataAsync.when(
      data: (allFetchedArticles) {
        if (allFetchedArticles.isEmpty && !articlesNotifier.isLoadingMore) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text("No other news available.")),
            ),
          );
        }

        // Calculate items for the current page
        final startIndex = (currentPage - 1) * otherNewsItemsPerPage;
        final endIndex = math.min(
          startIndex + otherNewsItemsPerPage,
          allFetchedArticles.length,
        );

        List<ArticlePreview> currentPageItems = [];
        if (startIndex < allFetchedArticles.length) {
          currentPageItems = allFetchedArticles.sublist(startIndex, endIndex);
        }

        // Determine total pages based on ALL fetched items so far.
        // This might need to be adjusted if we want to show total pages based on a backend count.
        final totalFetched = articlesNotifier.totalFetchedItems;
        final totalPossiblePages =
            (totalFetched / otherNewsItemsPerPage).ceil();
        // If hasMoreData is true, we might have more pages than currently calculated from fetched items.
        // For now, we paginate based on what's fetched.

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < currentPageItems.length) {
              return Column(
                children: [
                  OtherNewsListItem(article: currentPageItems[index]),
                  if (index <
                      currentPageItems.length - 1) // Add divider between items
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.grey[200],
                    ),
                ],
              );
            }
            return null; // Should not happen if childCount is correct
          }, childCount: currentPageItems.length),
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
                  ref.read(otherNewsCurrentPageProvider.notifier).state = 1;
                },
              ),
            ),
          ),
    );
  }

  // --- NEW: Pagination Controls for "Other News" ---
  // This needs to be added to the `slivers` array in the main build method,
  // likely after `_buildOtherNewsPaginatedList`.
  // For now, I'll put it inside the `_buildOtherNewsPaginatedList`'s whenData,
  // but it should ideally be a separate sliver for better structure.
  // We'll refine this placement. For now, let's get it rendering.

  // This method is removed, pagination controls will be part of the SliverList or a separate SliverToBoxAdapter
  // Widget _buildOtherNewsPaginationIndicator(AsyncValue<List<ArticlePreview>> otherNewsAsync) { ... }

  // This is where pagination controls would go.
  // The build method structure needs adjustment to place this correctly.
  // For now, I will put the controls inside the `data` block of `_buildOtherNewsPaginatedList`
  // and then we can refactor it into its own Sliver.

  // Modify build method to call a wrapper for list + controls
  // ... inside build method ...
  // slivers: [
  //   ... other slivers ...
  //   _buildOtherNewsSectionWithControls(context, otherNewsDataAsync), // New wrapper
  //   SliverToBoxAdapter(child: SizedBox(height: 20)),
  // ],

  // The actual pagination controls. To be integrated into a Sliver.
  // For now, let's add it conceptually. The NewsFeedScreen's build method needs an update
  // to correctly place this. I'll add it below the list within _buildOtherNewsPaginatedList's AsyncValue.data:
  // THIS IS A CONCEPTUAL PLACEMENT. The final placement will be in the main build method's sliver list.
  // I'll integrate it properly in the next step if this conceptual part is okay.
  // For now, let's focus on getting the list items displayed correctly.
  // The method _buildOtherNewsPaginationControls will be defined and called.
  // The previous _buildOtherNewsPaginationIndicator is removed as it was for infinite scroll.
}
