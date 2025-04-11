// lib/features/news_feed/ui/widgets/article_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:tackle_4_loss/core/providers/locale_provider.dart'; // Import locale provider
import 'package:cached_network_image/cached_network_image.dart'; // For optimized image loading
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:tackle_4_loss/core/theme/app_colors.dart'; // Import your app colors
// Import your placeholder detail screen (or the actual one later)
import 'package:tackle_4_loss/features/article_detail/ui/article_detail_screen.dart';

// Make it a ConsumerWidget to access ref
class ArticleListItem extends ConsumerWidget {
  final ArticlePreview article;

  const ArticleListItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    // Get theme data
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final chipTheme = theme.chipTheme;
    // Watch the current locale provider
    final currentLocale = ref.watch(localeNotifierProvider);

    // Determine which headline to show based on locale
    // Provide fallbacks if one language headline is empty
    final headlineToShow =
        (currentLocale.languageCode == 'de' &&
                article.germanHeadline.isNotEmpty)
            ? article.germanHeadline
            : (article.englishHeadline.isNotEmpty
                ? article.englishHeadline
                : "No Title"); // Fallback to English or "No Title"

    return Card(
      // Card uses theme's cardTheme implicitly
      // Removed margin here, assuming handled by CardTheme or parent padding
      child: InkWell(
        onTap: () {
          // Navigate to the detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              // Pass the article ID to the detail screen
              builder: (context) => ArticleDetailScreen(articleId: article.id),
            ),
          );
          // Removed print statement
        },
        borderRadius: BorderRadius.circular(
          12.0,
        ), // Match Card shape for InkWell ripple
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Consistent padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
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
                            // Cache size hint (adjust based on actual display)
                            memCacheHeight: 180,
                            memCacheWidth: 180,
                          )
                          : Container(
                            // Placeholder if no image URL
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
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Distribute vertical space
                  // Ensure Column takes up the height of the Row (important with Row's crossAxisAlignment.start)
                  mainAxisSize:
                      MainAxisSize
                          .min, // Take minimum space needed unless expanded
                  children: [
                    Text(
                      headlineToShow, // Use the selected headline
                      style:
                          textTheme.titleSmall, // Using titleSmall from theme
                      maxLines: 3, // Allow up to 3 lines
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), // Spacing
                    Column(
                      // Group bottom row elements
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.createdAt != null)
                          Text(
                            // Pass the locale string to DateFormat
                            DateFormat.yMMMd(
                              currentLocale.toString(),
                            ).add_jm().format(article.createdAt!),
                            style: textTheme.bodySmall, // Use theme style
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          // Use Wrap for chips
                          spacing: 6.0, // Horizontal space between chips
                          runSpacing: 4.0, // Vertical space if chips wrap
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
                                backgroundColor:
                                    chipTheme
                                        .backgroundColor, // Use theme background
                              ),
                            Chip(
                              label: Text(article.status.toUpperCase()),
                              backgroundColor: _getStatusColor(article.status),
                              padding:
                                  chipTheme.labelPadding ??
                                  const EdgeInsets.symmetric(horizontal: 4),
                              labelStyle: chipTheme.labelStyle?.copyWith(
                                color:
                                    AppColors
                                        .white, // Ensure white text on colored chip
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

  // Helper function to determine status chip color
  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      // Use uppercase for case-insensitive matching
      case 'NEW':
        return Colors.green.shade600;
      case 'UPDATE':
        return Colors.orange.shade700;
      case 'PUBLISHED': // Assuming 'PUBLISHED' is a possible status
        return AppColors.primaryGreen; // Use your primary theme color
      case 'OLD':
        return Colors.grey.shade600;
      default: // Default color for unknown statuses
        return Colors.grey.shade600;
    }
  }
}
