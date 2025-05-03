import 'package:flutter/material.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';

class ArticleGridItem extends ConsumerWidget {
  final ArticlePreview article;

  const ArticleGridItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    // Log to help debug
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

    // Use AspectRatio for responsive sizing instead of fixed height
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: InkWell(
          onTap: () {
            debugPrint(
              "Tapped Article Grid Item ${article.id}. Navigating to detail.",
            );
            ref.read(currentDetailArticleIdProvider.notifier).state =
                article.id;
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // Background Image with fixed height
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

              // Gradient overlay for text
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

              // Text Title Overlay at Bottom with LayoutBuilder
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

              // Team logo in top right corner (replacing three-dot menu)
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
                                min(3, article.teamId!.length),
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

// Helper function to handle string length safely
int min(int a, int b) {
  return a < b ? a : b;
}
