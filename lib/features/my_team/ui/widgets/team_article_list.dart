import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
// --- VERIFY THIS IMPORT PATH AND THE CONTENT OF THE FILE ---
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
// This import brings in NewsFeedService AND PaginatedArticlesResponse
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart'; // For newsFeedServiceProvider
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart';

class TeamArticleList extends ConsumerWidget {
  final String teamId;

  const TeamArticleList({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<PaginatedArticlesResponse>(
      key: ValueKey('team_articles_$teamId'),
      future: ref
          .read(newsFeedServiceProvider)
          .getArticlePreviews(teamId: teamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else if (snapshot.hasError) {
          return ErrorMessageWidget(
            message: 'Could not load articles for $teamId.\n${snapshot.error}',
          );
        } else if (!snapshot.hasData || snapshot.data!.articles.isEmpty) {
          return Center(child: Text('No articles found for $teamId.'));
        } else {
          final articles = snapshot.data!.articles;
          debugPrint(
            '[TeamArticleList] Building ListView with shrinkWrap and NeverScrollableScrollPhysics',
          );
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleListItem(
                article: articles[index],
                onTap: () {
                  debugPrint(
                    '[TeamArticleList] Navigating to detail for articleId: ${articles[index].id}',
                  );
                  context.push('/article/${articles[index].id}');
                },
              );
            },
          );
        }
      },
    );
  }
}
