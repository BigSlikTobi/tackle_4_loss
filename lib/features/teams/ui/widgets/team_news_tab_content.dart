import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart'; // Provider for articles
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart'; // Widget for list item
import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart';

class TeamNewsTabContent extends ConsumerStatefulWidget {
  final String teamAbbreviation; // Team ID (e.g., "MIA")

  const TeamNewsTabContent({super.key, required this.teamAbbreviation});

  @override
  ConsumerState<TeamNewsTabContent> createState() => _TeamNewsTabContentState();
}

class _TeamNewsTabContentState extends ConsumerState<TeamNewsTabContent> {
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
    super.dispose();
  }

  void _onScroll() {
    // Check if near the bottom of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Adjust threshold if needed
      // Trigger fetchNextPage on the correct provider instance for this team
      ref
          .read(paginatedArticlesProvider(widget.teamAbbreviation).notifier)
          .fetchNextPage();
    }
  }

  Future<void> _handleRefresh() async {
    // Invalidate the provider for this specific team to refresh
    ref.invalidate(paginatedArticlesProvider(widget.teamAbbreviation));
    // Optional: await the future to keep the indicator showing until data is loaded
    // await ref.read(paginatedArticlesProvider(widget.teamAbbreviation).future);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the specific family instance of the articles provider for this team
    final articlesAsyncValue = ref.watch(
      paginatedArticlesProvider(widget.teamAbbreviation),
    );

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: articlesAsyncValue.when(
        data: (articleList) {
          // Receives List<ArticlePreview>

          // Check if the list is empty after successful load
          if (articleList.isEmpty && !articlesAsyncValue.isLoading) {
            // Added isLoading check
            // Check if underlying provider IS loading (maybe after invalidate but before new data)
            final isLoading =
                ref
                    .watch(paginatedArticlesProvider(widget.teamAbbreviation))
                    .isLoading;
            if (isLoading) {
              return const LoadingIndicator(); // Show loading if actively fetching
            }

            return LayoutBuilder(
              // Use LayoutBuilder to enable refresh even when empty
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Text(
                        "No news found for ${widget.teamAbbreviation}.",
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // Need to check if the *notifier* itself indicates loading next page
          // Accessing the state directly might be complex, alternatively use isLoading of the main provider
          final isLoadingNextPage =
              articlesAsyncValue.isLoading && articleList.isNotEmpty;

          // Build the list using ListView.builder
          return ListView.builder(
            controller: _scrollController,
            physics:
                const AlwaysScrollableScrollPhysics(), // Ensure scrollable for RefreshIndicator
            itemCount:
                articleList.length +
                (isLoadingNextPage ? 1 : 0), // Add 1 for loading indicator
            itemBuilder: (context, index) {
              // If it's the last item and we are loading more, show indicator
              if (index == articleList.length && isLoadingNextPage) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: LoadingIndicator(),
                );
              }
              // Build the article list item
              if (index < articleList.length) {
                return ArticleListItem(
                  article: articleList[index],
                  onTap: () {
                    debugPrint(
                      'TeamNewsTabContent: Navigating to detail for articleId: \\${articleList[index].id}',
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ArticleDetailScreen(
                              articleId: articleList[index].id,
                            ),
                      ),
                    );
                  },
                );
              }
              return Container(); // Should not happen
            },
          );
        },
        // Show full screen loading indicator on initial load
        loading: () => const LoadingIndicator(),
        // Show full screen error message on initial load error
        error:
            (error, stackTrace) => LayoutBuilder(
              // Allow refresh on error
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ErrorMessageWidget(
                          message: 'Failed to load news: ${error.toString()}',
                          onRetry:
                              () => ref.invalidate(
                                paginatedArticlesProvider(
                                  widget.teamAbbreviation,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
