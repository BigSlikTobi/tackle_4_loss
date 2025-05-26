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
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart'; // For OtherNewsListItem
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart'; // Added
import 'package:tackle_4_loss/features/news_feed/logic/featured_cluster_provider.dart'; // Added
// NEW STORY LINES IMPORTS
import 'package:tackle_4_loss/features/news_feed/data/story_line_item.dart';
import 'package:tackle_4_loss/features/news_feed/logic/story_lines_provider.dart'
    as story_lines;
import 'package:tackle_4_loss/features/news_feed/ui/widgets/story_line_grid_item.dart';
// END NEW STORY LINES IMPORTS
import 'package:tackle_4_loss/features/news_feed/ui/widgets/nfl_headline_item_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/other_news_list_item.dart';
import 'package:tackle_4_loss/features/all_news/ui/all_news_screen.dart'; // Import AllNewsScreen

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
            .read(story_lines.paginatedStoryLinesProvider.notifier)
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
    ref.invalidate(story_lines.paginatedStoryLinesProvider);
    // Assuming paginatedArticlesProvider takes a nullable String, adjust if different
    ref.invalidate(paginatedArticlesProvider(null));

    if (_featuredClusterPageController.hasClients) {
      _featuredClusterPageController.jumpToPage(0);
    }
    ref.read(featuredClusterPageIndexProvider.notifier).state = 0;

    ref.read(story_lines.storyLinesCurrentPageProvider.notifier).state = 1;
    await ref
        .read(story_lines.paginatedStoryLinesProvider.notifier)
        .ensureDataForStoryLinesPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final featuredClusterAsync = ref.watch(featuredClusterProvider);
    final paginatedStoryLinesAsync = ref.watch(
      story_lines.paginatedStoryLinesProvider,
    );
    // Assuming paginatedArticlesProvider takes a nullable String
    final otherNewsTop8Async = ref.watch(paginatedArticlesProvider(null));

    ref.watch(realtimeServiceProvider);

    final currentStoryLinesUiPage = ref.watch(
      story_lines.storyLinesCurrentPageProvider,
    );
    ref
        .read(story_lines.paginatedStoryLinesProvider.notifier)
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
          _buildStoryLinesSliverGrid(context, paginatedStoryLinesAsync),
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
    AsyncValue<List<StoryLineItem>> storyLinesAsync,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = kIsWeb;
    // Define a breakpoint for mobile-like layout on web, consistent with StoryLineGridItem
    const mobileLayoutBreakpoint = 960.0;
    final bool useMobileLayout =
        !isWeb || (isWeb && screenWidth <= mobileLayoutBreakpoint);

    return storyLinesAsync.when(
      data: (allFetchedStoryLines) {
        if (allFetchedStoryLines.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No story lines available at the moment.'),
              ),
            ),
          );
        }

        if (useMobileLayout) {
          // --- Mobile Layout: Pagination with 4 items per page ---
          final currentUiPage = ref.watch(
            story_lines.storyLinesCurrentPageProvider,
          );
          const itemsPerPage = 4;

          final startIndex = (currentUiPage - 1) * itemsPerPage;
          final endIndex = math.min(
            startIndex + itemsPerPage,
            allFetchedStoryLines.length,
          );

          List<StoryLineItem> currentPageDisplayItems = [];
          if (startIndex < allFetchedStoryLines.length &&
              startIndex < endIndex) {
            currentPageDisplayItems = allFetchedStoryLines.sublist(
              startIndex,
              endIndex,
            );
          }

          if (currentPageDisplayItems.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final storyLineItem = currentPageDisplayItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: StoryLineGridItem(storyLine: storyLineItem),
                );
              }, childCount: currentPageDisplayItems.length),
            ),
          );
        } else {
          // --- Web Layout: Horizontal scroll with all items in one row ---
          return SliverToBoxAdapter(
            child: Container(
              height: 320, // Fixed height for the horizontal scroll area
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allFetchedStoryLines.length,
                itemBuilder: (context, index) {
                  final storyLineItem = allFetchedStoryLines[index];
                  return Container(
                    width: 280, // Fixed width for each story line card
                    margin: const EdgeInsets.only(right: 16.0),
                    child: StoryLineGridItem(storyLine: storyLineItem),
                  );
                },
              ),
            ),
          );
        }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = kIsWeb;
    const mobileLayoutBreakpoint = 960.0;
    final bool useMobileLayout =
        !isWeb || (isWeb && screenWidth <= mobileLayoutBreakpoint);

    // Only show pagination controls on mobile layouts
    if (!useMobileLayout) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final storyLinesNotifier = ref.read(
      story_lines.paginatedStoryLinesProvider.notifier,
    );
    final currentUiPage = ref.watch(story_lines.storyLinesCurrentPageProvider);
    final paginatedStoryLinesState = ref.watch(
      story_lines.paginatedStoryLinesProvider,
    );

    final int totalFetchedItemsInBuffer = paginatedStoryLinesState.maybeWhen(
      data: (data) => storyLinesNotifier.totalFetchedStoryLineItems,
      orElse: () => 0,
    );

    // Use 4 items per page for mobile pagination
    const itemsPerPage = 4;
    final totalDisplayableUiPagesInBuffer =
        (totalFetchedItemsInBuffer / itemsPerPage).ceil();

    final bool canGoNext =
        currentUiPage < totalDisplayableUiPagesInBuffer ||
        storyLinesNotifier.hasMoreData;
    final bool canGoPrev = currentUiPage > 1;

    if (totalFetchedItemsInBuffer == 0 && !storyLinesNotifier.isLoadingMore) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (totalFetchedItemsInBuffer <= itemsPerPage &&
        !storyLinesNotifier.hasMoreData &&
        !storyLinesNotifier.isLoadingMore &&
        !canGoPrev) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          children: [
            if (storyLinesNotifier.isLoadingMore)
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: LoadingIndicator(),
              ),
            if (canGoPrev || canGoNext)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (canGoPrev)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              story_lines
                                  .storyLinesCurrentPageProvider
                                  .notifier,
                            )
                            .state--;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Previous',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 80),

                  Text(
                    'Page $currentUiPage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  if (canGoNext)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              story_lines
                                  .storyLinesCurrentPageProvider
                                  .notifier,
                            )
                            .state++;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
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
