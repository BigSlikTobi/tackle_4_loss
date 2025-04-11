// lib/features/my_team/ui/widgets/team_article_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/features/news_feed/data/news_feed_service.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart'; // To get service provider
import 'package:tackle_4_loss/features/news_feed/ui/widgets/article_list_item.dart'; // Reuse list item

class TeamArticleList extends ConsumerWidget {
  final String teamId; // Requires the selected team ID

  const TeamArticleList({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use FutureBuilder to fetch articles when this widget builds or teamId changes
    return FutureBuilder<PaginatedArticlesResponse>(
      // Keying the FutureBuilder can help refetch when the teamId changes,
      // though FutureBuilder itself refetches if the future instance changes.
      // Using teamId in the key ensures it rebuilds the future when teamId changes.
      key: ValueKey('team_articles_$teamId'),
      // Call the service method with the specific teamId
      future: ref
          .read(newsFeedServiceProvider)
          .getArticlePreviews(teamId: teamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else if (snapshot.hasError) {
          return ErrorMessageWidget(
            message: 'Could not load articles for $teamId.\n${snapshot.error}',
            // Optional: Add retry logic specific to this fetch if needed
          );
        } else if (!snapshot.hasData || snapshot.data!.articles.isEmpty) {
          return Center(child: Text('No articles found for $teamId.'));
        } else {
          // Data loaded successfully
          final articles = snapshot.data!.articles;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleListItem(article: articles[index]);
            },
          );
        }
      },
    );
  }
}
