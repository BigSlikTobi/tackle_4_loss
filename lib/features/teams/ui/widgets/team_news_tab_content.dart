// lib/features/teams/ui/widgets/team_news_tab_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart';

class TeamNewsTabContent extends ConsumerStatefulWidget {
  final String teamAbbreviation;
  final int? excludeArticleId;

  const TeamNewsTabContent({
    super.key,
    required this.teamAbbreviation,
    this.excludeArticleId,
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
    ref.invalidate(paginatedArticlesProvider(widget.teamAbbreviation));
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsyncValue = ref.watch(
      paginatedArticlesProvider(widget.teamAbbreviation),
    );

    debugPrint(
      "[TeamNewsTabContent build] Team: ${widget.teamAbbreviation}, Exclude ID: ${widget.excludeArticleId}, AsyncState: $articlesAsyncValue",
    );

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
              return const Center(child: LoadingIndicator());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight > 0
                              ? constraints.maxHeight
                              : 200,
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
                final article = filteredArticleList[index];
                return ArticleListItem(
                  article: article,
                  onTap: () {
                    // onTap is now primarily for GoRouter navigation
                    debugPrint(
                      '[TeamNewsTabContent onTap] Navigating to /article/${article.id}',
                    );
                    context.push('/article/${article.id}');
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
