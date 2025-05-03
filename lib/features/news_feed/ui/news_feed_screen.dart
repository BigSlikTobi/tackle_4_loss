import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/featured_story_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_grid_item.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/core/constants/source_constants.dart';

// Remove comment to use staggered grid
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController =
      PageController(); // Controller for PageView

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose(); // Dispose PageController
    super.dispose();
  }

  // Updated refresh logic
  Future<void> _handleRefresh() async {
    debugPrint("NewsFeedScreen refresh triggered for clusters and articles.");
    // Invalidate both providers
    ref.invalidate(clusterStoriesProvider);
    ref.invalidate(
      paginatedArticlesProvider(null),
    ); // Use the same filter as watched
    // Optionally reset page indicator
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    // Update the state provider directly as well
    ref.read(featuredPageIndexProvider.notifier).state = 0;
  }

  // Updated scroll logic
  void _onScroll() {
    // Check if near the bottom of the *entire* CustomScrollView
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Adjust threshold if needed
      // Trigger pagination for the articles grid
      final notifier = ref.read(paginatedArticlesProvider(null).notifier);
      // Check provider's internal state before fetching
      if (notifier.hasMore && !notifier.isLoadingMore) {
        debugPrint(
          "NewsFeedScreen: Near end of scroll, fetching next article page...",
        );
        notifier.fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clusterAsync = ref.watch(clusterStoriesProvider);
    final articlesAsync = ref.watch(paginatedArticlesProvider(null));
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar is handled by MainNavigationWrapper
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ), // Ensure refresh works even if content is short
          slivers: [
            // --- Sliver 1: Featured Section (Clusters) ---
            _buildFeaturedSection(clusterAsync),

            // --- Sliver 2: "Latest News" Header ---
            SliverToBoxAdapter(
              child: Padding(
                // Adjusted padding to space it correctly after overhang
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Text(
                  "Latest News", // Or localized version
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- Sliver 3: Articles Grid ---
            _buildArticleGridSection(articlesAsync),

            // --- Sliver 4: Article Pagination Loading Indicator ---
            _buildArticlePaginationIndicator(articlesAsync),
          ],
        ),
      ),
    );
  }

  // Helper to build the Featured Section Sliver
  Widget _buildFeaturedSection(
    AsyncValue<List<MappedClusterStory>> clusterAsync,
  ) {
    // Removed unused currentFeaturedPage variable
    // Define constants for styling
    const double textOverhang =
        20.0; // How much the text box hangs below the *image* part
    const double indicatorHeight = 8.0; // Height of the dots
    const double spacingBelowIndicator = 8.0;
    // Calculate total extra space needed below the image's aspect ratio container
    const double totalBottomSpace =
        textOverhang +
        indicatorHeight +
        spacingBelowIndicator +
        12.0; // Added some padding for indicator

    return clusterAsync.when(
      data: (featuredStories) {
        if (featuredStories.isEmpty) {
          // Don't show anything if there are no featured stories
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        // Build the PageView and Indicator within a Column
        return SliverToBoxAdapter(
          child: Column(
            children: [
              // Container to hold the PageView Stack and manage height
              SizedBox(
                // Height must accommodate the image's aspect ratio plus the text box overhang
                height:
                    (MediaQuery.of(context).size.width / (16 / 10)) +
                    textOverhang,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: featuredStories.length,
                  itemBuilder: (context, index) {
                    final story = featuredStories[index];
                    // Stack for image and overlaid text box
                    return Stack(
                      clipBehavior: Clip.none, // Allow text box to overflow
                      children: [
                        // 1. Image part (positioned to leave space for overhang)
                        Positioned.fill(
                          // Leave space FROM THE BOTTOM for the text box to occupy visually
                          bottom: textOverhang,
                          child: AspectRatio(
                            aspectRatio: 16 / 10, // Maintain image aspect ratio
                            child: FeaturedStoryCard(
                              story: story,
                            ), // Simplified image widget
                          ),
                        ),
                        // 2. Text Box Overlay (positioned at the bottom of the stack)
                        Positioned(
                          left: 16.0, // Inset from left
                          right: 16.0, // Inset from right
                          bottom:
                              0, // Align to the bottom of the Stack container
                          // Let the text box determine its height based on content + padding
                          // height: 100, // Remove fixed height if possible
                          child: _buildFeaturedTextBox(context, ref, story),
                        ),
                      ],
                    );
                  },
                  onPageChanged: (index) {
                    // Update the indicator state
                    ref.read(featuredPageIndexProvider.notifier).state = index;
                  },
                ),
              ),
              // Indicator placed below the PageView container
              const SizedBox(height: 12), // Spacing before indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: featuredStories.length,
                effect: WormEffect(
                  dotHeight: indicatorHeight,
                  dotWidth: indicatorHeight,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.grey.shade300,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              const SizedBox(
                height: spacingBelowIndicator,
              ), // Spacing after indicator
            ],
          ),
        );
      },
      loading:
          () => SliverToBoxAdapter(
            // Loading state
            child: AspectRatio(
              aspectRatio: 16 / 10, // Maintain aspect ratio
              // Adjust height to include expected bottom space
              child: Container(
                height:
                    (MediaQuery.of(context).size.width / (16 / 10)) +
                    totalBottomSpace,
                alignment: Alignment.center,
                child: const LoadingIndicator(),
              ),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            // Error state
            child: AspectRatio(
              aspectRatio: 16 / 10, // Maintain aspect ratio
              child: Container(
                // Adjust height
                height:
                    (MediaQuery.of(context).size.width / (16 / 10)) +
                    totalBottomSpace,
                padding: const EdgeInsets.all(16.0),
                child: ErrorMessageWidget(
                  message: "Could not load featured stories: $error",
                  onRetry: () => ref.invalidate(clusterStoriesProvider),
                ),
              ),
            ),
          ),
    );
  }

  // Helper to build just the Text Box Container
  Widget _buildFeaturedTextBox(
    BuildContext context,
    WidgetRef ref,
    MappedClusterStory story,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);
    final headlineToShow = story.getLocalizedHeadline(
      currentLocale.languageCode,
    );

    return Container(
      // Remove fixed height - let content determine height
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.15).round()),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        // Make the text box tappable
        onTap: () {
          final representativeId = story.representativeSourceArticleId;
          if (representativeId != null) {
            debugPrint(
              "Tapped Featured Text Box ${story.id}. Navigating to detail for Source Article ID: $representativeId",
            );
            ref.read(currentDetailArticleIdProvider.notifier).state =
                representativeId;
          } else {
            debugPrint(
              "Tapped Featured Text Box ${story.id}, but no representative source article ID found.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open article details.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          mainAxisSize: MainAxisSize.min, // Crucial for height based on content
          children: [
            Text(
              headlineToShow,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // --- Metadata ---
                if (story.sourceArticles.isNotEmpty)
                  Icon(Icons.source, color: Colors.grey[600], size: 16),
                if (story.sourceArticles.isNotEmpty) const SizedBox(width: 4),
                if (story.sourceArticles.isNotEmpty)
                  Text(
                    sourceIdToDisplayName[story
                            .sourceArticles
                            .first
                            .newsSourceId] ??
                        'Source',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                if (story.sourceArticles.isNotEmpty)
                  const Text(" • ", style: TextStyle(color: Colors.grey)),

                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                if (story.updatedAt != null)
                  Text(
                    DateFormat.yMd().add_jm().format(
                      story.updatedAt!.toLocal(),
                    ),
                    style: textTheme.bodySmall,
                  )
                else
                  Text(
                    "?",
                    style: textTheme.bodySmall,
                  ), // Placeholder if no date

                const Spacer(),
                Icon(
                  Icons.bookmark_border,
                  color: Colors.grey[700],
                ), // Placeholder action
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build the Article Grid Section Sliver
  Widget _buildArticleGridSection(
    AsyncValue<List<ArticlePreview>> articlesAsync,
  ) {
    return articlesAsync.when(
      data: (articles) {
        if (articles.isEmpty && !articlesAsync.isLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text("No articles found.")),
          );
        }

        // Replace standard GridView with MasonryGridView
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
          sliver: SliverMasonryGrid.extent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            // Use childCount and itemBuilder pattern with SliverChildBuilderDelegate
            childCount: articles.length,
            itemBuilder: (BuildContext context, int index) {
              debugPrint("Building article grid item at index: $index");
              return ArticleGridItem(article: articles[index]);
            },
          ),
        );
      },
      loading:
          () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: LoadingIndicator()),
            ),
          ),
      error:
          (error, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorMessageWidget(
                message: "Could not load articles: $error",
                onRetry: () => ref.invalidate(paginatedArticlesProvider(null)),
              ),
            ),
          ),
    );
  }

  // Helper to build the pagination indicator for articles
  Widget _buildArticlePaginationIndicator(
    AsyncValue<List<ArticlePreview>> articlesAsync,
  ) {
    // Only show indicator if the *articles provider* is loading AND has data (meaning loading next page)
    final isLoadingMoreArticles =
        ref.read(paginatedArticlesProvider(null).notifier).isLoadingMore;

    return SliverToBoxAdapter(
      child:
          isLoadingMoreArticles
              ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: LoadingIndicator()),
              )
              : const SizedBox(height: 16), // Add some padding at the end
    );
  }
} // End of _NewsFeedScreenState
