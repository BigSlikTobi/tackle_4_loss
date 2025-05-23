// lib/features/news_feed/ui/news_feed_screen.dart
import 'dart:math' as math;

// General Flutter and Riverpod imports
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Core utilities, services, and widgets
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/providers/realtime_provider.dart';

// Imports for news feed specific data, providers, and widgets
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart'; // For OtherNewsListItem
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart'; // Added
import 'package:tackle_4_loss/features/news_feed/logic/featured_cluster_provider.dart'; // Added
import 'package:tackle_4_loss/features/news_feed/ui/widgets/nfl_headline_item_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/other_news_list_item.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/cluster_info_grid_item.dart';
import 'package:tackle_4_loss/features/all_news/ui/all_news_screen.dart'; // Import AllNewsScreen

const int storyLinesPerPage = 6; // Define or import this constant

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  late PageController _featuredClusterPageController;

  @override
  void initState() {
    super.initState();
    _featuredClusterPageController = PageController(initialPage: 0);
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
    _featuredClusterPageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    debugPrint("NewsFeedScreen refresh triggered.");
    ref.invalidate(featuredClusterProvider);
    ref.invalidate(paginatedClusterInfosProvider);
    // Assuming paginatedArticlesProvider takes a nullable String, adjust if different
    ref.invalidate(paginatedArticlesProvider(null));

    if (_featuredClusterPageController.hasClients) {
      _featuredClusterPageController.jumpToPage(0);
    }
    ref.read(featuredClusterPageIndexProvider.notifier).state = 0;

    ref.read(storyLinesCurrentPageProvider.notifier).state = 1;
    await ref
        .read(paginatedClusterInfosProvider.notifier)
        .ensureDataForStoryLinesPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final featuredClusterAsync = ref.watch(featuredClusterProvider);
    final paginatedClusterInfosAsync = ref.watch(paginatedClusterInfosProvider);
    // Assuming paginatedArticlesProvider takes a nullable String
    final otherNewsTop8Async = ref.watch(paginatedArticlesProvider(null));

    ref.watch(realtimeServiceProvider);

    final currentStoryLinesUiPage = ref.watch(storyLinesCurrentPageProvider);
    ref
        .read(paginatedClusterInfosProvider.notifier)
        .ensureDataForStoryLinesPage(currentStoryLinesUiPage);

    const double maxWebWidth = 1200.0;

    Widget scrollView = RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildFeaturedClusterStorySection(context, featuredClusterAsync),
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
          _buildStoryLinesSliverGrid(context, paginatedClusterInfosAsync),
          _buildStoryLinesPaginationControlsSliver(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
              child: Text(
                "News",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildOtherNewsTop8List(context, otherNewsTop8Async),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20), // Existing bottom padding
          ),
        ],
      ),
    );

    return Scaffold(
      body:
          kIsWeb
              ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxWebWidth),
                  child: scrollView,
                ),
              )
              : scrollView,
    );
  }

  Widget _buildFeaturedClusterStorySection(
    BuildContext context,
    AsyncValue<List<ClusterArticle>> featuredClusterAsync,
  ) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeWebScreen = kIsWeb && screenWidth > 600;
    final double pageViewHeight = isLargeWebScreen ? 500.0 : 250.0;

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
              if (articles.length <= 1)
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

  Widget _buildStoryLinesSliverGrid(
    BuildContext context,
    AsyncValue<List<ClusterInfo>> storyLinesAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = kIsWeb;
    // Define a breakpoint for mobile-like layout on web, consistent with ClusterInfoGridItem
    const mobileLayoutBreakpoint = 960.0;

    int crossAxisCount;
    double childAspectRatio;

    if (isWeb) {
      if (screenWidth > 1200) {
        crossAxisCount = 4; // 1 row, 4 items (wide items)
        childAspectRatio =
            2.2; // Adjusted: Aim for good width for overlay layout
      } else if (screenWidth > mobileLayoutBreakpoint) {
        // Web tablet view (>960px)
        crossAxisCount = 2; // 2x2 grid (landscape/square items)
        childAspectRatio =
            1.6; // Adjusted: Aim for good shape for overlay layout
      } else {
        // Web mobile view (<=960px)
        crossAxisCount = 1; // List view, 1 item per row
        // This uses the mobile-style card (image left, text right)
        // Card height is roughly 80 (image) + 16 (padding) = 96.
        // If cell width is screenWidth, aspect ratio = screenWidth / desired_cell_height.
        // For a desired height of ~100-110px for the card to fit well:
        // e.g., if screenWidth is 400, 400/100 = 4.0. If screenWidth is 600, 600/100 = 6.0
        // Let's try a value that gives enough height for the card.
        // If card height is ~100, and it takes full width (e.g. 320px on small phone)
        // Aspect ratio = 320/100 = 3.2
        // If on a 960px screen, width is ~900, height 100, aspect ratio = 9.
        // This wide variation suggests that for single column list with fixed height items,
        // childAspectRatio might not be the best. However, SliverGrid requires it.
        // Let's try a value that gives reasonable height on average small web screens.
        childAspectRatio =
            3.5; // Increased to give more height if card is wider
      }
    } else {
      // Native Mobile: List view, 1 item per row
      crossAxisCount = 1;
      // Mobile card height is approx 80 (image) + 16 (padding) = 96.
      // Let cell height be around 100-110.
      // childAspectRatio = cellWidth / cellHeight.
      // cellWidth = screenWidth - 16*2 (horizontal padding of SliverPadding)
      // e.g. (360-32)/110 = 2.98
      // e.g. (400-32)/110 = 3.34
      childAspectRatio = 3.0; // This seemed to work well for native mobile card
    }

    return storyLinesAsync.when(
      data: (allFetchedClusters) {
        if (allFetchedClusters.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No story lines available at the moment.'),
              ),
            ),
          );
        }

        final currentUiPage = ref.watch(storyLinesCurrentPageProvider);

        final startIndex = (currentUiPage - 1) * storyLinesPerPage;
        final endIndex = math.min(
          startIndex + storyLinesPerPage,
          allFetchedClusters.length,
        );

        List<ClusterInfo> currentPageDisplayItems = [];
        if (startIndex < allFetchedClusters.length && startIndex < endIndex) {
          currentPageDisplayItems = allFetchedClusters.sublist(
            startIndex,
            endIndex,
          );
        }

        // This case handles if the sublist is empty but there are items (e.g. page out of bounds after refresh)
        // Or if there are no items at all for the current page after filtering.
        if (currentPageDisplayItems.isEmpty) {
          // If it's not the first page or there are truly no items, show empty.
          if (currentUiPage > 1 || allFetchedClusters.isEmpty) {
            return const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ); // Or a message
          }
          // If it IS the first page, but somehow sublist is empty (e.g. bad data), also show empty.
          // This check might be redundant if allFetchedClusters.isEmpty is handled above.
          if (allFetchedClusters.isNotEmpty && startIndex == 0) {
            return const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ); // Or a message
          }
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 24.0 : 16.0,
            vertical: 8.0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: kIsWeb ? 16.0 : 8.0,
              mainAxisSpacing: kIsWeb ? 16.0 : 8.0,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final clusterInfo = currentPageDisplayItems[index];
              return ClusterInfoGridItem(cluster: clusterInfo);
            }, childCount: currentPageDisplayItems.length),
          ),
        );
      },
      loading:
          () => const SliverToBoxAdapter(
            child: Center(child: LoadingIndicator()),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: ErrorMessageWidget(message: error.toString()),
          ),
    );
  }

  Widget _buildStoryLinesPaginationControlsSliver(BuildContext context) {
    final clusterNotifier = ref.read(paginatedClusterInfosProvider.notifier);
    final currentUiPage = ref.watch(storyLinesCurrentPageProvider);
    final paginatedClustersState = ref.watch(paginatedClusterInfosProvider);

    final int totalFetchedItemsInBuffer = paginatedClustersState.maybeWhen(
      data: (data) => clusterNotifier.totalFetchedClusterItems,
      orElse: () => 0,
    );

    final totalDisplayableUiPagesInBuffer =
        (totalFetchedItemsInBuffer / storyLinesPerPage).ceil();

    final bool canGoNext =
        currentUiPage < totalDisplayableUiPagesInBuffer ||
        clusterNotifier.hasMoreData;
    final bool canGoPrev = currentUiPage > 1;

    if (totalFetchedItemsInBuffer == 0 && !clusterNotifier.isLoadingMore) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (totalFetchedItemsInBuffer <= storyLinesPerPage &&
        !clusterNotifier.hasMoreData &&
        !clusterNotifier.isLoadingMore &&
        !canGoPrev) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          children: [
            if (clusterNotifier.isLoadingMore)
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: LoadingIndicator(),
              ),
            if (canGoPrev || canGoNext)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (canGoPrev)
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(storyLinesCurrentPageProvider.notifier)
                            .state--;
                      },
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 80),

                  Text(
                    'Page $currentUiPage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  if (canGoNext)
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(storyLinesCurrentPageProvider.notifier)
                            .state++;
                      },
                      child: const Text('Next'),
                    )
                  else
                    const SizedBox(width: 80),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherNewsTop8List(
    BuildContext context,
    AsyncValue<List<ArticlePreview>>
    otherNewsAsync, // Changed ClusterArticle to ArticlePreview
  ) {
    return otherNewsAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < articles.length) {
                return OtherNewsListItem(article: articles[index]);
              }
              // Add the "More News" button after the last item
              if (index == articles.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text("More News"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllNewsScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                );
              }
              return null; // Should not happen
            },
            childCount: articles.length + 1, // Add 1 for the button
          ),
        );
      },
      loading:
          () => const SliverToBoxAdapter(
            child: Center(child: LoadingIndicator()),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: ErrorMessageWidget(message: error.toString()),
          ),
    );
  }
}
