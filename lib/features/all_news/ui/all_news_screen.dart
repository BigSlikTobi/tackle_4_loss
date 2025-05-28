// lib/features/all_news/ui/all_news_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/headline_story_card.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // No longer needed for this

const double kMaxContentWidthAllNews = 1200.0; // Renamed to avoid conflict

final allNewsFilterTeamProvider = StateProvider<String?>((ref) => null);

class AllNewsScreen extends ConsumerStatefulWidget {
  const AllNewsScreen({super.key});

  @override
  ConsumerState<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends ConsumerState<AllNewsScreen> {
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

  void navigateToArticleDetail(int articleId) {
    // ref.read(currentDetailArticleIdProvider.notifier).state = articleId; // Remove this line
    debugPrint('[AllNewsScreen] Navigating to /article/$articleId');
    context.push('/article/$articleId'); // Use context.push
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final filterTeamId = ref.read(allNewsFilterTeamProvider);
      ref
          .read(paginatedArticlesProvider(filterTeamId).notifier)
          .fetchNextPage();
    }
  }

  Future<void> _handleRefresh() async {
    final filterTeamId = ref.read(allNewsFilterTeamProvider);
    ref.invalidate(paginatedArticlesProvider(filterTeamId));
    debugPrint("AllNewsScreen refreshed for filter: $filterTeamId");
  }

  void _showTeamFilterDialog(BuildContext context, WidgetRef ref) {
    final List<MapEntry<String, String>> teamEntries = [
      const MapEntry('NFL', 'nfl'),
      ...teamLogoMap.entries,
    ];
    teamEntries.sort((a, b) {
      if (a.key == 'NFL') return -1;
      if (b.key == 'NFL') return 1;
      return a.key.compareTo(b.key);
    });

    final currentFilter = ref.read(allNewsFilterTeamProvider);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Filter by Team'),
          contentPadding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children:
                  teamEntries.map((entry) {
                    final teamAbbreviation = entry.key;
                    final bool isSelected =
                        (teamAbbreviation == 'NFL' && currentFilter == null) ||
                        (teamAbbreviation != 'NFL' &&
                            currentFilter == teamAbbreviation);

                    return InkWell(
                      onTap: () {
                        final newFilter =
                            teamAbbreviation == 'NFL' ? null : teamAbbreviation;
                        ref.read(allNewsFilterTeamProvider.notifier).state =
                            newFilter;
                        Navigator.pop(dialogContext);
                        debugPrint(
                          "Filter state provider updated to: $newFilter",
                        );
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                      .withOpacity(0.1) // Corrected withOpacity
                                  : Colors.transparent,
                          border:
                              isSelected
                                  ? null
                                  : Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        0.1,
                                      ), // Corrected withOpacity
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Image.asset(
                          getTeamLogoPath(teamAbbreviation),
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (ctx, err, st) =>
                                  const SizedBox(width: 40, height: 40),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterTeamId = ref.watch(allNewsFilterTeamProvider);
    final articlesAsyncValue = ref.watch(
      paginatedArticlesProvider(filterTeamId),
    );

    return Scaffold(
      appBar: const GlobalAppBar(automaticallyImplyLeading: true),
      floatingActionButton: FloatingActionButton(
        mini: true,
        tooltip: 'Filter by Team',
        onPressed: () => _showTeamFilterDialog(context, ref),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4.0,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(
              getTeamLogoPath(filterTeamId ?? 'NFL'),
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) => const Icon(Icons.filter_list),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidthAllNews),
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: articlesAsyncValue.when(
              data: (filteredArticles) {
                ArticlePreview? headlineArticle;
                if (filteredArticles.isNotEmpty) {
                  headlineArticle = filteredArticles.first;
                }

                final List<ArticlePreview> listArticlesToShow =
                    filteredArticles
                        .where((a) => a.id != headlineArticle?.id)
                        .toList();

                final isLoadingNextPage =
                    articlesAsyncValue.isLoading &&
                    (headlineArticle != null || listArticlesToShow.isNotEmpty);

                if (headlineArticle == null &&
                    listArticlesToShow.isEmpty &&
                    !isLoadingNextPage) {
                  if (articlesAsyncValue.isLoading) {
                    return const LoadingIndicator();
                  } else {
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              filterTeamId == null
                                  ? 'No news articles found.'
                                  : 'No news found for ${getTeamFullName(filterTeamId)}.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }

                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (headlineArticle != null)
                      SliverToBoxAdapter(
                        child: InkWell(
                          onTap:
                              () =>
                                  navigateToArticleDetail(headlineArticle!.id),
                          child: HeadlineStoryCard(article: headlineArticle),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == listArticlesToShow.length &&
                                isLoadingNextPage) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(child: LoadingIndicator()),
                              );
                            }
                            if (index < listArticlesToShow.length) {
                              final article = listArticlesToShow[index];
                              return ArticleListItem(
                                article: article,
                                onTap:
                                    () => navigateToArticleDetail(article.id),
                              );
                            }
                            return null;
                          },
                          childCount:
                              listArticlesToShow.length +
                              (isLoadingNextPage ? 1 : 0),
                        ),
                      ),
                    ),
                    if (headlineArticle == null &&
                        listArticlesToShow.isEmpty &&
                        isLoadingNextPage)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: LoadingIndicator()),
                      ),
                  ],
                );
              },
              error: (error, stackTrace) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      child: ErrorMessageWidget(
                        message:
                            'Failed to load news for ${filterTeamId ?? 'All Teams'}.\n$error',
                        onRetry:
                            () => ref.invalidate(
                              paginatedArticlesProvider(filterTeamId),
                            ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LoadingIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
