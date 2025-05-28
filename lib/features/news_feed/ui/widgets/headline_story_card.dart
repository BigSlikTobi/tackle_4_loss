// lib/features/news_feed/ui/widgets/headline_story_card.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:tackle_4_loss/features/news_feed/data/article_preview.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
// import 'package:tackle_4_loss/core/providers/navigation_provider.dart'; // No longer needed for this

class HeadlineStoryCard extends ConsumerStatefulWidget {
  final ArticlePreview article;

  const HeadlineStoryCard({super.key, required this.article});

  @override
  ConsumerState<HeadlineStoryCard> createState() => _HeadlineStoryCardState();
}

class _HeadlineStoryCardState extends ConsumerState<HeadlineStoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _alignmentAnimation = AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final headlineToShow =
        currentLocale.languageCode == 'de'
            ? widget.article.germanHeadline
            : widget.article.englishHeadline;

    final displayHeadline =
        headlineToShow.isNotEmpty
            ? headlineToShow
            : (widget.article.englishHeadline.isNotEmpty
                ? widget.article.englishHeadline
                : "Headline Unavailable");

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isLargeScreen = kIsWeb && constraints.maxWidth > 600;

        final double cardHeight = isLargeScreen ? 600.0 : 200.0;
        final double cardMaxWidth = isLargeScreen ? 800.0 : double.infinity;
        final EdgeInsets cardPadding =
            isLargeScreen
                ? const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0)
                : const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0);
        final TextStyle headlineStyle =
            isLargeScreen
                ? textTheme.headlineSmall!.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withAlpha(153),
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
                    debugPrint(
                      "[HeadlineStoryCard onTap] Navigating to /article/${widget.article.id}",
                    );
                    context.push(
                      '/article/${widget.article.id}',
                    ); // Use context.push
                  },
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      SizedBox(
                        height: cardHeight,
                        width: double.infinity,
                        child:
                            (widget.article.imageUrl != null &&
                                    widget.article.imageUrl!.isNotEmpty)
                                ? CachedNetworkImage(
                                  imageUrl: widget.article.imageUrl!,
                                  imageBuilder:
                                      (context, imageProvider) => Image(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        alignment: _alignmentAnimation.value,
                                      ),
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
                                  height: cardHeight,
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
                          style: headlineStyle,
                          maxLines: isLargeScreen ? 3 : 3,
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
