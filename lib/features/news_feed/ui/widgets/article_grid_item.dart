// lib/features/news_feed/ui/widgets/article_grid_item.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // Removed currentDetailArticleIdProvider
import 'package:tackle_4_loss/core/constants/team_constants.dart';

class ArticleGridItem extends ConsumerWidget {
  final ArticlePreview article;

  const ArticleGridItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    debugPrint(
      "Building ArticleGridItem for id: ${article.id}, with image URL: ${article.imageUrl}",
    );

    final headlineToShow =
        (currentLocale.languageCode == 'de' &&
                article.germanHeadline.isNotEmpty)
            ? article.germanHeadline
            : (article.englishHeadline.isNotEmpty
                ? article.englishHeadline
                : "No Title");

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: InkWell(
          onTap: () {
            debugPrint(
              "[ArticleGridItem onTap] Tapped Article Grid Item ${article.id}. Navigating to /cluster/${article.id}",
            ); // Assuming article.id here is clusterId for StoryLine
            // This widget seems to be for ArticlePreview which has an `id` and sometimes `teamId`
            // If this is for a "StoryLineItem" which has clusterId, the navigation should be to /cluster/:clusterId
            // Based on the name "ArticleGridItem" and "ArticlePreview article", it should navigate to /article/:id
            // The log message in the original code was confusing.
            // If `article.id` is the correct ID for an article detail:
            context.push('/article/${article.id}');
            // If this item actually represents a cluster and `article.id` is `clusterId`:
            // context.push('/cluster/${article.id}');
            // For now, assuming it's an article.
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[200]),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[500],
                      size: 40,
                    ),
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((255 * 0.75).round()),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.black.withAlpha((255 * 0.35).round()),
                      ),
                      child: Text(
                        headlineToShow,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black.withAlpha(
                                (255 * 0.5).round(),
                              ),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              if (article.teamId != null && article.teamId!.isNotEmpty)
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha((255 * 0.85).round()),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.2).round()),
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/team_logos/${teamLogoMap[article.teamId!]?.toLowerCase() ?? 'nfl'}.png',
                        height: 24,
                        width: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading team logo: $error');
                          return Center(
                            child: Text(
                              article.teamId!.substring(
                                0,
                                article.teamId!.length < 3
                                    ? article.teamId!.length
                                    : 3, // Safe substring
                              ),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
