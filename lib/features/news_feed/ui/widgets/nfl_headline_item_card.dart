import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_article.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/features/news_feed/ui/cluster_article_detail_screen.dart'; // Import the new screen
import 'package:flutter/foundation.dart'; // Added for kIsWeb

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

// Changed to ConsumerStatefulWidget
class NflHeadlineItemCard extends ConsumerStatefulWidget {
  final ClusterArticle clusterArticle;

  const NflHeadlineItemCard({super.key, required this.clusterArticle});

  @override
  ConsumerState<NflHeadlineItemCard> createState() =>
      _NflHeadlineItemCardState();
}

class _NflHeadlineItemCardState extends ConsumerState<NflHeadlineItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 40,
      ), // Duration for one way pan (40% slower)
    )..repeat(reverse: true); // Loop and reverse

    _alignmentAnimation = AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth easing for the pan
      ),
    );

    // Add listener to rebuild widget on animation ticks
    // Using AnimatedBuilder is an alternative, but direct setState is fine here.
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final rawHeadline =
        (currentLocale.languageCode == 'de' &&
                widget.clusterArticle.deHeadline.isNotEmpty)
            ? widget.clusterArticle.deHeadline
            : (widget.clusterArticle.englishHeadline.isNotEmpty
                ? widget.clusterArticle.englishHeadline
                : "No Title");

    final headlineToShow = _stripHtmlIfNeeded(rawHeadline);

    // Find the newest date from sources
    DateTime? newestSourceDate;
    if (widget.clusterArticle.sources.isNotEmpty) {
      final validDates =
          widget.clusterArticle.sources
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
    final displayDate = newestSourceDate ?? widget.clusterArticle.createdAt;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isLargeScreen = kIsWeb && constraints.maxWidth > 600;

        final double cardHeight =
            isLargeScreen
                ? 500.0
                : 250.0; // Default mobile height was implicitly around 250 due to PageView
        final double cardMaxWidth = isLargeScreen ? 800.0 : double.infinity;
        final EdgeInsets cardMargin =
            isLargeScreen
                ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
        final TextStyle headlineStyle =
            isLargeScreen
                ? textTheme.headlineMedium!.copyWith(
                  // Larger font for web
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black.withAlpha(
                        179,
                      ), // 0.7 * 255 = 178.5 ≈ 179
                      offset: const Offset(1.5, 1.5),
                    ),
                  ],
                )
                : textTheme.titleLarge!.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black.withAlpha(128),
                      offset: const Offset(1, 1),
                    ),
                  ],
                );
        final EdgeInsets contentPadding =
            isLargeScreen
                ? const EdgeInsets.all(16.0)
                : const EdgeInsets.all(12.0);

        return Padding(
          // Use Padding for margin to work well with Center + ConstrainedBox
          padding: cardMargin,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardMaxWidth),
              child: SizedBox(
                // Explicitly set height for the card area
                height: cardHeight,
                child: Card(
                  margin: EdgeInsets.zero, // Margin is handled by outer Padding
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 3.0,
                  child: InkWell(
                    onTap: () {
                      // Navigate to detail screen
                      if (widget.clusterArticle.clusterArticleId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ClusterArticleDetailScreen(
                                  clusterArticleId:
                                      widget.clusterArticle.clusterArticleId,
                                ),
                          ),
                        );
                      } else {
                        debugPrint(
                          "Cannot navigate: Cluster Article ID is empty.",
                        );
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        // Background Image
                        Positioned.fill(
                          child:
                              (widget.clusterArticle.imageUrl != null &&
                                      widget
                                          .clusterArticle
                                          .imageUrl!
                                          .isNotEmpty)
                                  ? CachedNetworkImage(
                                    imageUrl: widget.clusterArticle.imageUrl!,
                                    // fit: BoxFit.cover, // Removed: Handled by Image widget in imageBuilder
                                    imageBuilder:
                                        (context, imageProvider) => Image(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                          alignment:
                                              _alignmentAnimation
                                                  .value, // Apply animated alignment
                                        ),
                                    placeholder:
                                        (context, url) =>
                                            Container(color: Colors.grey[300]),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons
                                                .sports_football, // Keep generic icon
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
                                  Colors.black.withAlpha(
                                    217,
                                  ), // 0.85 * 255 ≈ 217
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
                          padding: contentPadding, // Use responsive padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headlineToShow, // Use the stripped headline
                                style: headlineStyle, // Use responsive style
                                maxLines:
                                    isLargeScreen
                                        ? 4
                                        : 3, // Adjust max lines for web
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Date (No Time)
                                  if (displayDate != null)
                                    Text(
                                      DateFormat.yMd(
                                        currentLocale.languageCode,
                                      ).format(
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
