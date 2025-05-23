// lib/features/news_feed/ui/widgets/headline_story_card.dart
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
// Removed import for ArticleDetailScreen
// Import navigation provider to update detail state
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';

class HeadlineStoryCard extends ConsumerWidget {
  final ArticlePreview article;

  const HeadlineStoryCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final headlineToShow =
        currentLocale.languageCode == 'de'
            ? article.germanHeadline
            : article.englishHeadline;

    final displayHeadline =
        headlineToShow.isNotEmpty
            ? headlineToShow
            : (article.englishHeadline.isNotEmpty
                ? article.englishHeadline
                : "Headline Unavailable");

    // Use LayoutBuilder to make decisions based on available width
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Determine if we are on a large screen (web)
        // kIsWeb ensures this logic only applies to web builds.
        final bool isLargeScreen = kIsWeb && constraints.maxWidth > 600;

        // Define responsive properties
        final double cardHeight =
            isLargeScreen ? 600.0 : 200.0; // Updated height for web
        final double cardMaxWidth =
            isLargeScreen ? 800.0 : double.infinity; // Max width for web
        final EdgeInsets cardPadding =
            isLargeScreen
                ? const EdgeInsets.fromLTRB(
                  16.0,
                  16.0,
                  16.0,
                  12.0,
                ) // Larger padding for web
                : const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0);
        final TextStyle headlineStyle =
            isLargeScreen
                ? textTheme.headlineSmall!.copyWith(
                  // Larger font for web
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(1.5, 1.5),
                    ),
                  ],
                )
                : textTheme.titleLarge!.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black.withAlpha((255 * 0.5).round()),
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                );

        return Padding(
          padding: cardPadding,
          child: Center(
            // Center the card on web if it has a max width
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4.0,
                shadowColor: Colors.black.withAlpha((255 * 0.2).round()),
                child: InkWell(
                  onTap: () {
                    // --- MODIFIED: Update detail state instead of Navigator.push ---
                    ref.read(currentDetailArticleIdProvider.notifier).state =
                        article.id;
                    // --- End Modification ---
                  },
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      SizedBox(
                        // Use SizedBox to control height directly on web
                        height: cardHeight,
                        width:
                            double
                                .infinity, // Take full width of ConstrainedBox/Card
                        child:
                            (article.imageUrl != null &&
                                    article.imageUrl!.isNotEmpty)
                                ? CachedNetworkImage(
                                  imageUrl: article.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) =>
                                          Container(color: Colors.grey[300]),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.error_outline),
                                        ),
                                      ),
                                )
                                : Container(
                                  height:
                                      cardHeight, // Ensure consistent height
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withAlpha((255 * 0.0).round()),
                                Colors.black.withAlpha((255 * 0.7).round()),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0,
                        child: Text(
                          displayHeadline,
                          style: headlineStyle, // Use responsive headline style
                          maxLines:
                              isLargeScreen
                                  ? 3
                                  : 3, // Keep maxLines or adjust if needed
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
