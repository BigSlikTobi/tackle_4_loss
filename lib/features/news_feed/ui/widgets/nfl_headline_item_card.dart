import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/constants/team_constants.dart';
import 'package:tackle_4_loss/core/constants/source_constants.dart'; // For source names

class NflHeadlineItemCard extends ConsumerWidget {
  final ArticlePreview article;

  const NflHeadlineItemCard({super.key, required this.article});

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

    final sourceName =
        article.source != null
            ? sourceIdToDisplayName[article.source!] ??
                "NFL" // Fallback to NFL
            : "NFL"; // Default if source is null

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 3.0,
      child: InkWell(
        onTap: () {
          debugPrint(
            "Tapped NFL Headline Item ${article.id}. Navigating to detail.",
          );
          ref.read(currentDetailArticleIdProvider.notifier).state = article.id;
        },
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Background Image
            Positioned.fill(
              child:
                  (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: Colors.grey[300]),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.sports_football,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                      )
                      : Container(
                        color: AppColors.primaryGreen.withOpacity(0.8),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.jpg', // Fallback app logo
                            width: 100,
                            color: AppColors.white.withOpacity(0.5),
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
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.85),
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
                    headlineToShow,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.5),
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
                      // Source Info (Text Only)
                      Text(
                        sourceName, // Should be "NFL" or from sourceIdToDisplayName
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                      // Separator if date exists
                      if (article.createdAt != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            '•',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      // Date (No Time)
                      if (article.createdAt != null)
                        Text(
                          // --- CHANGE 2: DateFormat changed ---
                          DateFormat.yMd(
                            currentLocale.languageCode,
                          ).format(article.createdAt!.toLocal()),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      const Spacer(),
                      // Team Logo
                      if (article.teamId != null && article.teamId!.isNotEmpty)
                        // --- CHANGE 3: Ensure circular display and clean look ---
                        Container(
                          height:
                              28, // Increased size slightly for better presence
                          width: 28,
                          decoration: BoxDecoration(
                            // The white background for the logo to "pop"
                            color: AppColors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2, // Softer shadow
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            // Ensures the image itself is clipped to a circle
                            child: Padding(
                              // Padding inside the circle, around the image
                              padding: const EdgeInsets.all(
                                3.0,
                              ), // Adjust as needed
                              child: Image.asset(
                                getTeamLogoPath(article.teamId!),
                                fit:
                                    BoxFit
                                        .contain, // Contain ensures whole logo is visible
                                errorBuilder:
                                    (ctx, err, st) => const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      // --- End CHANGE 3 ---
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
