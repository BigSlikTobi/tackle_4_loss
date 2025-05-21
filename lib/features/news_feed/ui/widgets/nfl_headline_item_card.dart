import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/features/news_feed/ui/cluster_article_detail_screen.dart'; // Import the new screen

// Utility function to strip HTML tags
String _stripHtmlIfNeeded(String htmlText) {
  // Regex to remove HTML tags
  final RegExp htmlRegExp = RegExp(
    r"<[^>]*>",
    multiLine: true,
    caseSensitive: true,
  );
  // Regex to decode common HTML entities
  return htmlText
      .replaceAll(htmlRegExp, '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .trim(); // Trim whitespace
}

class NflHeadlineItemCard extends ConsumerWidget {
  final ClusterArticle clusterArticle; // New property

  const NflHeadlineItemCard({
    super.key,
    required this.clusterArticle,
  }); // New constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final rawHeadline =
        (currentLocale.languageCode == 'de' &&
                clusterArticle.deHeadline.isNotEmpty)
            ? clusterArticle.deHeadline
            : (clusterArticle.englishHeadline.isNotEmpty
                ? clusterArticle.englishHeadline
                : "No Title");

    final headlineToShow = _stripHtmlIfNeeded(
      rawHeadline,
    ); // Strip HTML from the chosen headline

    // Find the newest date from sources
    DateTime? newestSourceDate;
    if (clusterArticle.sources.isNotEmpty) {
      final validDates =
          clusterArticle.sources
              .map((source) => source.createdAt)
              .whereType<DateTime>() // Filter out null dates
              .toList();
      if (validDates.isNotEmpty) {
        validDates.sort(
          (a, b) => b.compareTo(a),
        ); // Sort descending, newest first
        newestSourceDate = validDates.first;
      }
    }
    // If no source dates, fallback to the article's main createdAt
    final displayDate = newestSourceDate ?? clusterArticle.createdAt;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 3.0,
      child: InkWell(
        onTap: () {
          // Navigate to detail screen
          if (clusterArticle.clusterArticleId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ClusterArticleDetailScreen(
                      clusterArticleId: clusterArticle.clusterArticleId,
                    ),
              ),
            );
          } else {
            debugPrint("Cannot navigate: Cluster Article ID is empty.");
          }
        },
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Background Image
            Positioned.fill(
              child:
                  (clusterArticle.imageUrl != null &&
                          clusterArticle.imageUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                        imageUrl: clusterArticle.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: Colors.grey[300]),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.sports_football, // Keep generic icon
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                      )
                      : Container(
                        color: AppColors.primaryGreen.withAlpha(
                          204,
                        ), // 0.8 * 255 ≈ 204
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.jpg', // Fallback app logo
                            width: 100,
                            color: AppColors.white.withAlpha(
                              128,
                            ), // 0.5 * 255 ≈ 128
                          ),
                        ),
                      ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(0), // 0.0 * 255 = 0
                      Colors.black.withAlpha(51), // 0.2 * 255 ≈ 51
                      Colors.black.withAlpha(217), // 0.85 * 255 ≈ 217
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headlineToShow, // Use the stripped headline
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withAlpha(128), // 0.5 * 255 ≈ 128
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Date (No Time)
                      if (displayDate != null)
                        Text(
                          DateFormat.yMd(currentLocale.languageCode).format(
                            displayDate, // Use the determined displayDate
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withAlpha(
                              204,
                            ), // 0.8 * 255 ≈ 204
                          ),
                        ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
