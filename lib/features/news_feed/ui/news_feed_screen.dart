// lib/features/news_feed/ui/news_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_state.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/headline_story_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
// Import the new placeholder cards
import 'package:tackle_4_loss/features/my_team/ui/widgets/team_huddle_section.dart';
import 'package:tackle_4_loss/core/providers/preference_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
// Import breakpoint

class NewsFeedScreen extends ConsumerStatefulWidget {
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose(); // Correctly calls super.dispose()
  }

  void _onScroll() {
    // Trigger loading when near the end and in 'all' mode
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Threshold
      final currentMode = ref.read(newsFeedDisplayModeProvider);
      if (currentMode == NewsFeedDisplayMode.all) {
        // Use read inside callbacks/listeners
        ref.read(paginatedArticlesProvider.notifier).fetchNextPage();
      }
    }
  }

  // Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    // Call refresh on the notifier. Await completion.
    await ref.read(paginatedArticlesProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final articlesAsyncValue = ref.watch(paginatedArticlesProvider);
    final headlineAsyncValue = ref.watch(headlineArticleProvider);
    final displayMode = ref.watch(newsFeedDisplayModeProvider);
    final selectedTeamAsyncValue = ref.watch(selectedTeamNotifierProvider);
    final articlesNotifier = ref.read(paginatedArticlesProvider.notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: articlesAsyncValue.when(
          data: (allFetchedArticles) {
            // Get headline and team selection safely
            final headlineArticle = headlineAsyncValue.valueOrNull;
            final selectedTeamId = selectedTeamAsyncValue.valueOrNull;

            // UPDATED: Always show TeamHuddleSection when a team is selected,
            // regardless of whether there's a headline article for that team or not
            final bool showTeamHuddle = selectedTeamId != null;

            // Determine which headline article to pass to TeamHuddleSection
            // If there's a headline matching the selected team, use it
            // Otherwise, pass null to trigger the placeholder UI
            ArticlePreview? teamHeadlineArticle;
            if (selectedTeamId != null && headlineArticle != null) {
              if (headlineArticle.teamId == selectedTeamId) {
                teamHeadlineArticle = headlineArticle;
              } else {
                // Check if any article matches the selected team to use as a headline
                teamHeadlineArticle =
                    allFetchedArticles
                        .where((a) => a.teamId == selectedTeamId)
                        .firstOrNull;
              }
            }

            // Filter the main list articles
            // Always exclude the headline article (whether it's team specific or overall latest)
            final List<ArticlePreview> listArticlesToShow;
            if (displayMode == NewsFeedDisplayMode.newOnly) {
              listArticlesToShow =
                  allFetchedArticles
                      .where(
                        (a) =>
                            a.status.toUpperCase() == 'NEW' &&
                            a.id != headlineArticle?.id,
                      )
                      .toList();
            } else {
              listArticlesToShow =
                  allFetchedArticles
                      .where((a) => a.id != headlineArticle?.id)
                      .toList();
            }

            // --- Handle Empty States ---
            if (headlineArticle == null &&
                listArticlesToShow.isEmpty &&
                !showTeamHuddle) {
              // If everything is empty and we aren't showing the huddle
              if (articlesAsyncValue is AsyncLoading ||
                  headlineAsyncValue is AsyncLoading ||
                  selectedTeamAsyncValue is AsyncLoading) {
                return const LoadingIndicator();
              } else if (displayMode == NewsFeedDisplayMode.newOnly) {
                return _buildEmptyStateUI(
                  context,
                  displayMode,
                  articlesNotifier,
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

            // --- Build Content with CustomScrollView ---
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // --- Conditional Section: Team Huddle OR Default Headline ---
                if (showTeamHuddle)
                  // 1a. Show Team Huddle Section
                  SliverToBoxAdapter(
                    child: TeamHuddleSection(
                      teamId: selectedTeamId, // Remove unnecessary ! operator
                      headlineArticle:
                          teamHeadlineArticle, // Use the potentially null team headline article
                    ),
                  )
                else if (headlineArticle != null)
                  // 1b. Show Default Headline Card (if no team selected but headline exists)
                  SliverToBoxAdapter(
                    child: HeadlineStoryCard(article: headlineArticle),
                  )
                else if (headlineAsyncValue is AsyncLoading)
                  // 1c. Show Loading placeholder if headline is still loading
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingIndicator(),
                    ),
                  ),
                // --- End Conditional Section ---

                // 2. Main Article List (SliverList)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // --- Logic for button/loader at the end ---
                        if (index == listArticlesToShow.length) {
                          if (displayMode == NewsFeedDisplayMode.newOnly) {
                            return _buildLoadOlderButton(articlesNotifier);
                          } else {
                            final bool isLoadingMore =
                                articlesAsyncValue is AsyncLoading &&
                                listArticlesToShow.isNotEmpty;
                            if (isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: LoadingIndicator(),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        }
                        // Render article item
                        return ArticleListItem(
                          article: listArticlesToShow[index],
                        );
                      },
                      childCount:
                          listArticlesToShow.length +
                          (displayMode == NewsFeedDisplayMode.newOnly ||
                                  (articlesAsyncValue is AsyncLoading &&
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
            /* ... Error UI ... */
            return _buildErrorStateUI(articlesNotifier);
          },
          loading:
              () => const LoadingIndicator(), // Initial full screen loading
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildLoadOlderButton(PaginatedArticlesNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () => notifier.loadOlder(),
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
    if (displayMode == NewsFeedDisplayMode.newOnly) {
      // Return within a scrollable view for pull-to-refresh
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
                    onPressed: () => notifier.loadOlder(),
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
    return RefreshIndicator(
      // Ensure error state can be refreshed
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: ErrorMessageWidget(
              message: 'Failed to load news feed.',
              onRetry: () => notifier.refresh(),
            ),
          ),
        ],
      ),
    );
  }
}
