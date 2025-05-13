import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart'; // Provider for articles
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart'; // Widget for list item
import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart';

class TeamNewsTabContent extends ConsumerStatefulWidget {
  final String teamAbbreviation; // Team ID (e.g., "MIA")
  final int? excludeArticleId;

  const TeamNewsTabContent({
    super.key,
    required this.teamAbbreviation,
    this.excludeArticleId, // Make it optional
  });

  @override
  ConsumerState<TeamNewsTabContent> createState() => _TeamNewsTabContentState();
}

class _TeamNewsTabContentState extends ConsumerState<TeamNewsTabContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    debugPrint(
      "[TeamNewsTabContent initState] Team: ${widget.teamAbbreviation}, Exclude ID: ${widget.excludeArticleId}",
    );
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
      ref
          .read(paginatedArticlesProvider(widget.teamAbbreviation).notifier)
          .fetchNextPage();
    }
  }

  Future<void> _handleRefresh() async {
    debugPrint(
      "[TeamNewsTabContent _handleRefresh] Invalidating paginatedArticlesProvider for ${widget.teamAbbreviation}. Exclude ID: ${widget.excludeArticleId}",
    );
    // Invalidate the provider for this specific team to refresh
    ref.invalidate(paginatedArticlesProvider(widget.teamAbbreviation));
    // For pull-to-refresh, you might want to ensure the refresh indicator stays
    // until the data is actually re-fetched. You can await the future of the provider.
    // However, since invalidation itself triggers a rebuild when data is ready,
    // simply invalidating is often enough. If you need the indicator to persist,
    // you can do:
    // await ref.read(paginatedArticlesProvider(widget.teamAbbreviation).future);
    // But be cautious as this will make the onRefresh function async and hold the indicator.
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsyncValue = ref.watch(
      paginatedArticlesProvider(widget.teamAbbreviation),
    );

    debugPrint(
      "[TeamNewsTabContent build] Team: ${widget.teamAbbreviation}, Exclude ID: ${widget.excludeArticleId}, AsyncState: $articlesAsyncValue",
    );

    // --- MODIFICATION: Wrap with RefreshIndicator ---
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: articlesAsyncValue.when(
        data: (articleList) {
          final List filteredArticleList;
          if (widget.excludeArticleId != null) {
            filteredArticleList =
                articleList
                    .where((article) => article.id != widget.excludeArticleId)
                    .toList();
            debugPrint(
              "[TeamNewsTabContent build data] Original list count: ${articleList.length}. Filtered list count (excluding ${widget.excludeArticleId}): ${filteredArticleList.length}",
            );
          } else {
            filteredArticleList = articleList;
            debugPrint(
              "[TeamNewsTabContent build data] Original list count: ${articleList.length}. No excludeArticleId provided.",
            );
          }

          if (filteredArticleList.isEmpty && !articlesAsyncValue.isLoading) {
            final isLoading =
                ref
                    .watch(paginatedArticlesProvider(widget.teamAbbreviation))
                    .isLoading;
            if (isLoading) {
              return const Center(
                child: LoadingIndicator(),
              ); // Keep centered for initial load case
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                // Make the empty content scrollable to enable pull-to-refresh
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight > 0
                              ? constraints.maxHeight
                              : 200, // Ensure some min height
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "No news found for ${widget.teamAbbreviation}.",
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          final isLoadingNextPage =
              articlesAsyncValue.isLoading && filteredArticleList.isNotEmpty;

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filteredArticleList.length + (isLoadingNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredArticleList.length && isLoadingNextPage) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: LoadingIndicator(),
                );
              }
              if (index < filteredArticleList.length) {
                return ArticleListItem(
                  article: filteredArticleList[index],
                  onTap: () {
                    debugPrint(
                      'TeamNewsTabContent: Navigating to detail for articleId: ${filteredArticleList[index].id}',
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ArticleDetailScreen(
                              articleId: filteredArticleList[index].id,
                            ),
                      ),
                    );
                  },
                );
              }
              return Container();
            },
          );
        },
        loading: () {
          debugPrint(
            "[TeamNewsTabContent build loading] Team: ${widget.teamAbbreviation}",
          );
          // For initial loading, ensure RefreshIndicator can still work if it's a direct child
          return Stack(
            children: [ListView(), const Center(child: LoadingIndicator())],
          );
        },
        error: (error, stackTrace) {
          debugPrint(
            "[TeamNewsTabContent build error] Team: ${widget.teamAbbreviation}. Error: $error",
          );
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight > 0 ? constraints.maxHeight : 200,
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
          );
        },
      ),
    );
  }
}
