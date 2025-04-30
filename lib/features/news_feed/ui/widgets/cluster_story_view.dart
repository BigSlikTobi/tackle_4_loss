// lib/features/news_feed/ui/widgets/cluster_story_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
import 'package:tackle_4_loss/features/news_feed/data/source_article_reference.dart';
import 'package:tackle_4_loss/core/constants/source_constants.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';

class ClusterStoryView extends ConsumerWidget {
  final MappedClusterStory story;
  final String? heroTag; // Optional hero tag for animated transitions

  const ClusterStoryView({super.key, required this.story, this.heroTag});

  // Helper function to get the primary image URL with fallback (uses model getter)
  String? get _primaryImageUrl => story.primaryImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add debug log to validate heroTag value
    debugPrint('ClusterStoryView build: heroTag=${heroTag ?? "null"}');

    final currentLocale = ref.watch(localeNotifierProvider);
    final textTheme = Theme.of(context).textTheme;
    final viewMode = ref.watch(galleryViewModeProvider);

    // --- THESE LINES DEFINE headlineToShow AND summaryToShow ---
    // --- THEY MUST BE HERE AND UNCOMMENTED ---
    final headlineToShow = story.getLocalizedHeadline(
      currentLocale.languageCode,
    );
    final summaryToShow = story.getLocalizedSummary(currentLocale.languageCode);
    // --- END DEFINITION ---

    // Back button handler for detail view
    void handleBackButton() {
      // Return to gallery view
      ref.read(galleryViewModeProvider.notifier).state =
          GalleryViewMode.gallery;
      ref.read(selectedGalleryItemIndexProvider.notifier).state = null;
    }

    // --- Function to handle tapping the main content area ---
    void onMainContentTap() {
      // Navigate to the detail screen using the representative source article ID
      // We use the first source article's ID as the representative for now.
      final representativeId = story.representativeSourceArticleId;
      if (representativeId != null) {
        debugPrint(
          "Tapped Cluster Story ${story.id}. Navigating to detail for Source Article ID: $representativeId",
        );
        // Update the navigation state provider to show the detail screen
        ref.read(currentDetailArticleIdProvider.notifier).state =
            representativeId;
      } else {
        debugPrint(
          "Tapped Cluster Story ${story.id}, but no representative source article ID found.",
        );
        // Optional: Show a message to the user (e.g., SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open article details.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    // --- Function to handle tapping a related content item (Source Article) ---
    void onRelatedContentTap(SourceArticleReference sourceRef) {
      debugPrint(
        "Tapped Related Content (Source Article ID: ${sourceRef.id}). Navigating to detail.",
      );
      // Navigate to the detail screen using the specific source article ID
      ref.read(currentDetailArticleIdProvider.notifier).state = sourceRef.id;
    }

    // Main content wrapped with Hero if heroTag is provided
    Widget mainContent = Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Image
        if (_primaryImageUrl != null && _primaryImageUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: _primaryImageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey[500],
                    size: 50,
                  ),
                ),
          )
        else
          Container(
            color: AppColors.primaryGreen,
            child: Center(
              child: Image.asset('assets/images/logo.jpg', width: 100),
            ),
          ),

        // 2. Gradient Overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withAlpha(153), // 0.6 * 255
                Colors.black.withAlpha(0), // 0.0 * 255
                Colors.black.withAlpha(153), // 0.6 * 255
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
        ),

        // Back button in detail mode
        if (viewMode == GalleryViewMode.detail)
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.black.withAlpha(102), // 0.4 * 255
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: handleBackButton,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 3. Sources Section at the TOP (now completely without background)
        if (story.sourceArticles.isNotEmpty)
          Positioned(
            left: 12.0,
            right: 12.0,
            top: 42.0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final numSources = story.sourceArticles.length;

                    return SizedBox(
                      height: 60,
                      width: constraints.maxWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(numSources, (index) {
                            final sourceRef = story.sourceArticles[index];
                            final buttonLabel =
                                sourceIdToDisplayName[sourceRef.newsSourceId] ??
                                'Source ${sourceRef.newsSourceId}';

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                onPressed: () => onRelatedContentTap(sourceRef),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black.withAlpha(
                                    102,
                                  ), // 0.4 * 255
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  elevation:
                                      2, // Added slight elevation for depth
                                ),
                                child: Text(
                                  buttonLabel,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

        // 4. Text Content with glassmorphism effect (keeping this as is)
        Positioned(
          left: 16.0,
          right: 16.0,
          bottom: 32.0,
          child: SafeArea(
            minimum: const EdgeInsets.only(bottom: 0),
            child: InkWell(
              onTap: onMainContentTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(64), // 0.25 * 255
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha(38), // 0.15 * 255
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51), // 0.2 * 255
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // Using SingleChildScrollView to handle overflow if needed
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Headline
                          if (headlineToShow.isNotEmpty)
                            Text(
                              headlineToShow,
                              style: textTheme.headlineSmall?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                shadows: [
                                  Shadow(
                                    blurRadius: 3.0,
                                    color: Colors.black.withAlpha(
                                      77,
                                    ), // 0.3 * 255
                                    offset: const Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                              // Allow headline to wrap as needed
                              overflow: TextOverflow.visible,
                            )
                          else
                            Text(
                              "Headline Unavailable",
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColors.white.withAlpha(
                                  153,
                                ), // 0.6 * 255
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Summary - Removed maxLines and overflow constraints
                          if (summaryToShow != null && summaryToShow.isNotEmpty)
                            Text(
                              summaryToShow,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.white.withAlpha(
                                  230,
                                ), // 0.9 * 255
                                shadows: [
                                  Shadow(
                                    blurRadius: 1.0,
                                    color: Colors.black.withAlpha(
                                      51,
                                    ), // 0.2 * 255
                                    offset: const Offset(0.5, 0.5),
                                  ),
                                ],
                              ),
                              // Removed maxLines and TextOverflow.ellipsis
                            )
                          else
                            Text(
                              "Summary unavailable.",
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.white.withAlpha(
                                  153,
                                ), // 0.6 * 255
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Wrap with Hero if heroTag is provided
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        transitionOnUserGestures: true,
        flightShuttleBuilder: (
          flightContext,
          animation,
          flightDirection,
          fromHeroContext,
          toHeroContext,
        ) {
          // Inflate with a bounce using easeOutBack curve
          final Widget toHeroWidget = (toHeroContext.widget as Hero).child;

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: toHeroWidget,
              );
            },
          );
        },
        child: Material(color: Colors.transparent, child: mainContent),
      );
    }

    return mainContent;
  }
}
