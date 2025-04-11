// lib/features/news_feed/ui/widgets/article_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
// Removed import for ArticleDetailScreen
// Import navigation provider to update detail state
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';

class ArticleListItem extends ConsumerWidget {
  final ArticlePreview article;

  const ArticleListItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final chipTheme = theme.chipTheme;
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.createdAt != null)
                          Text(
                            DateFormat.yMMMd(
                              currentLocale.toString(),
                            ).add_jm().format(article.createdAt!),
                            style: textTheme.bodySmall,
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: [
                            if (article.teamId != null &&
                                article.teamId!.isNotEmpty)
                              Chip(
                                label: Text(article.teamId!),
                                padding:
                                    chipTheme.labelPadding ??
                                    const EdgeInsets.symmetric(horizontal: 4),
                                labelStyle: chipTheme.labelStyle?.copyWith(
                                  fontSize: 10,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: chipTheme.backgroundColor,
                              ),
                            Chip(
                              label: Text(article.status.toUpperCase()),
                              backgroundColor: _getStatusColor(article.status),
                              padding:
                                  chipTheme.labelPadding ??
                                  const EdgeInsets.symmetric(horizontal: 4),
                              labelStyle: chipTheme.labelStyle?.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
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

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'NEW':
        return Colors.green.shade600;
      case 'UPDATE':
        return Colors.orange.shade700;
      case 'PUBLISHED':
        return AppColors.primaryGreen;
      case 'OLD':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
