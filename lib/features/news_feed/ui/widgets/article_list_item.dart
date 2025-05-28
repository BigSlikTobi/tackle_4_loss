// lib/features/news_feed/ui/widgets/article_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // No longer needed for this

class ArticleListItem extends ConsumerWidget {
  final ArticlePreview article;
  final VoidCallback
  onTap; // Keep onTap if used by parent, but internal nav will use GoRouter

  const ArticleListItem({
    super.key,
    required this.article,
    required this.onTap, // Parent might still want to know about a tap for other reasons
  });

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
          debugPrint(
            '[ArticleListItem onTap] Navigating to /article/${article.id}',
          );
          context.push('/article/${article.id}'); // Use context.push
          // If the parent still needs to know about the tap for non-navigation reasons:
          // onTap();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                  debugPrint('Error loading team logo: $error');
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
