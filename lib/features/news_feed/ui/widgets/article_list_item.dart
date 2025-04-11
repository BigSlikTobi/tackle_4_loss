// lib/features/news_feed/ui/widgets/article_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:intl/intl.dart';
// Removed import for ArticleDetailScreen
// Import navigation provider to update detail state
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
// Import team constants for logo handling
import 'package:tackle_4_loss/core/constants/team_constants.dart';

class ArticleListItem extends ConsumerWidget {
  final ArticlePreview article;

  const ArticleListItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final headlineToShow =
        (currentLocale.languageCode == 'de' &&
                article.germanHeadline.isNotEmpty)
            ? article.germanHeadline
            : (article.englishHeadline.isNotEmpty
                ? article.englishHeadline
                : "No Title");

    return Card(
      child: InkWell(
        onTap: () {
          // --- MODIFIED: Update detail state instead of Navigator.push ---
          ref.read(currentDetailArticleIdProvider.notifier).state = article.id;
          // --- End Modification ---
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child:
                      article.imageUrl != null && article.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Container(color: Colors.grey[200]),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            memCacheHeight: 180,
                            memCacheWidth: 180,
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[500],
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),

              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headlineToShow,
                      style: textTheme.titleSmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (article.createdAt != null)
                          Text(
                            DateFormat.yMMMd(
                              currentLocale.toString(),
                            ).add_jm().format(article.createdAt!),
                            style: textTheme.bodySmall,
                          ),
                        // Team logo - now positioned on the right
                        if (article.teamId != null &&
                            article.teamId!.isNotEmpty)
                          Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  // Use withAlpha instead of withOpacity
                                  color: Colors.black.withAlpha(
                                    (255 * 0.1).round(),
                                  ),
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
                                  // Log the error for debugging
                                  debugPrint('Error loading team logo: $error');
                                  // Return a fallback (either the team ID text or a default icon)
                                  return Center(
                                    child: Text(
                                      article.teamId!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
