import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/headline_story_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  // Make it const if possible
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Ensure display mode starts correctly for the main feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Default to 'newOnly' for the main feed maybe? Or keep 'all'? Let's keep 'all' for consistency now.
        ref.read(newsFeedDisplayModeProvider.notifier).state =
            NewsFeedDisplayMode.all;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final currentMode = ref.read(newsFeedDisplayModeProvider);
      if (currentMode == NewsFeedDisplayMode.all) {
        // --- FIX: Call fetchNextPage on the correct family instance (null filter) ---
        ref.read(paginatedArticlesProvider(null).notifier).fetchNextPage();
        // --- End Fix ---
      }
    }
  }

  Future<void> _handleRefresh() async {
    // --- FIX: Invalidate the correct family instance (null filter) ---
    ref.invalidate(paginatedArticlesProvider(null));
    // Optionally await
    // await ref.read(paginatedArticlesProvider(null).future);
    // --- End Fix ---
  }

  @override
  Widget build(BuildContext context) {
    // --- FIX: Watch the correct family instance (null filter) ---
    final articlesAsyncValue = ref.watch(paginatedArticlesProvider(null));
    // --- End Fix ---

    // Watch other providers needed for headline logic
    final displayMode = ref.watch(newsFeedDisplayModeProvider);
    final selectedTeamAsyncValue = ref.watch(selectedTeamNotifierProvider);

    // --- FIX: Get the correct notifier instance (null filter) ---
    final articlesNotifier = ref.read(paginatedArticlesProvider(null).notifier);
    // --- End Fix ---

    return Scaffold(
      // Keep Scaffold unless this screen itself changes
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: articlesAsyncValue.when(
          data: (allFetchedArticles) {
            // This is the FULL list now

            // --- Headline Logic for Main Feed ---
            ArticlePreview? generalHeadline;

            if (allFetchedArticles.isNotEmpty) {
              // Use the latest overall article as headline
              generalHeadline = allFetchedArticles.first;
            }
            // --- End Headline Logic ---

            // The main headline to exclude from the list
            final ArticlePreview? primaryHeadlineToExclude = generalHeadline;

            // Filter the main list articles
            final List<ArticlePreview> listArticlesToShow;
            if (displayMode == NewsFeedDisplayMode.newOnly) {
              // This mode might be removed if AllNews is the primary place for non-new
              listArticlesToShow =
                  allFetchedArticles
                      .where(
                        (a) =>
                            a.status.toUpperCase() == 'NEW' &&
                            a.id != primaryHeadlineToExclude?.id,
                      )
                      .toList();
            } else {
              // displayMode == NewsFeedDisplayMode.all
              listArticlesToShow =
                  allFetchedArticles
                      .where((a) => a.id != primaryHeadlineToExclude?.id)
                      .toList();
            }

            // --- Handle Empty States ---
            if (generalHeadline == null && listArticlesToShow.isEmpty) {
              if (articlesAsyncValue.isLoading ||
                  selectedTeamAsyncValue is AsyncLoading) {
                return const LoadingIndicator();
              } else if (displayMode == NewsFeedDisplayMode.newOnly) {
                // Pass the correct notifier instance to the helper
                return _buildEmptyStateUI(
                  context,
                  displayMode,
                  articlesNotifier,
                );
              } else {
                // Keep scrollable for refresh
                return const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      child: Center(child: Text('No news articles found.')),
                    ),
                  ],
                );
              }
            }

            // --- Build Content ---
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // --- Show Default Headline ---
                if (generalHeadline != null)
                  // Show general headline
                  SliverToBoxAdapter(
                    child: HeadlineStoryCard(article: generalHeadline),
                  )
                else if (articlesAsyncValue.isLoading ||
                    selectedTeamAsyncValue is AsyncLoading)
                  // Show loading if still fetching initial data or team preference
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingIndicator(),
                    ),
                  ),

                // --- Main Article List (SliverList) ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == listArticlesToShow.length) {
                          if (displayMode == NewsFeedDisplayMode.newOnly) {
                            // Pass the correct notifier instance
                            return _buildLoadOlderButton(articlesNotifier);
                          } else {
                            // displayMode == NewsFeedDisplayMode.all
                            // Check loading state of the family(null) instance
                            if (articlesAsyncValue.isLoading &&
                                listArticlesToShow.isNotEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: LoadingIndicator(),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        }
                        return ArticleListItem(
                          article: listArticlesToShow[index],
                        );
                      },
                      childCount:
                          listArticlesToShow.length +
                          (displayMode == NewsFeedDisplayMode.newOnly ||
                                  (articlesAsyncValue.isLoading &&
                                      listArticlesToShow.isNotEmpty &&
                                      displayMode == NewsFeedDisplayMode.all)
                              ? 1
                              : 0),
                    ),
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            // Pass the correct notifier instance
            return _buildErrorStateUI(articlesNotifier);
          },
          loading: () => const LoadingIndicator(),
        ),
      ),
    );
  }

  // --- Helper Methods - Ensure they use the correct notifier type ---
  // Note: PaginatedArticlesNotifier is now FamilyAsyncNotifier, but instance methods are same

  Widget _buildLoadOlderButton(PaginatedArticlesNotifier notifier) {
    // This button might become less relevant if 'newOnly' mode is removed
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () => notifier.loadOlder(), // loadOlder doesn't need args
          child: const Text('Load Older Articles'),
        ),
      ),
    );
  }

  Widget _buildEmptyStateUI(
    BuildContext context,
    NewsFeedDisplayMode displayMode,
    PaginatedArticlesNotifier notifier,
  ) {
    // This helper needs the specific notifier instance if calling methods on it
    if (displayMode == NewsFeedDisplayMode.newOnly) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No new articles found.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => notifier.loadOlder(), // Pass instance here
                    child: const Text('Load Older Articles'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(child: Text('No news articles found.')),
          ),
        ],
      );
    }
  }

  Widget _buildErrorStateUI(PaginatedArticlesNotifier notifier) {
    // This helper needs the specific notifier instance if calling methods on it
    return RefreshIndicator(
      onRefresh: _handleRefresh, // _handleRefresh uses ref.invalidate correctly
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: ErrorMessageWidget(
              message: 'Failed to load news feed.',
              // Use invalidate directly in onRetry for simplicity
              onRetry: () => ref.invalidate(paginatedArticlesProvider(null)),
              // Or call notifier.refresh() if it existed and handled args
            ),
          ),
        ],
      ),
    );
  }

  // --- End Helper Methods ---
}
