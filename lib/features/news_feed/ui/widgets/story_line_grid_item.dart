// lib/features/news_feed/ui/widgets/story_line_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/story_line_item.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/features/cluster_detail/ui/cluster_detail_screen.dart';

String _stripHtml(String htmlText) {
  final RegExp htmlTags = RegExp(
    r'<[^>]*>',
    multiLine: true,
    caseSensitive: true,
  );
  return htmlText.replaceAll(htmlTags, '');
}

class StoryLineGridItem extends ConsumerWidget {
  final StoryLineItem storyLine;

  const StoryLineGridItem({super.key, required this.storyLine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Determine screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    // Define a breakpoint for mobile-like layout on web
    const mobileLayoutBreakpoint = 960.0;

    // Condition for mobile-style card layout
    final bool useMobileLayout =
        !kIsWeb || (kIsWeb && screenWidth <= mobileLayoutBreakpoint);

    if (useMobileLayout) {
      // --- Mobile Specific Layout (Image left, Text right) ---
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 0,
        ), // Adjusted margin for list-like appearance
        child: InkWell(
          onTap: () {
            debugPrint(
              "Tapped Story Line Grid Item ${storyLine.clusterId} (Mobile). Navigating to Cluster Detail Screen.",
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) =>
                        ClusterDetailScreen(clusterId: storyLine.clusterId),
              ),
            );
          },
          child: Padding(
            // Added padding around the Row
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80, // Fixed width for the image
                  height: 80, // Fixed height for the image
                  child: ClipRRect(
                    // Clip image to rounded corners
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        storyLine.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: storyLine.imageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) =>
                                      Container(color: Colors.grey[200]),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey[400],
                                      size: 30,
                                    ),
                                  ),
                            )
                            : Container(
                              color: AppColors.primaryGreen.withAlpha(26),
                              child: Center(
                                child: Icon(
                                  Icons.dashboard_customize_outlined,
                                  size: 30,
                                  color: AppColors.primaryGreen.withAlpha(128),
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12), // Spacing between image and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center, // Center text vertically if row is tall
                    children: [
                      Text(
                        _stripHtml(
                          storyLine.headline.isNotEmpty
                              ? storyLine.headline
                              : 'No Title Available',
                        ),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Optionally, add more details here if needed for mobile
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- Web/Tablet Specific Layout (Existing Stack-based layout for larger screens) ---
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          debugPrint(
            "Tapped Story Line Grid Item ${storyLine.clusterId}. Navigating to Cluster Detail Screen.",
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                      ClusterDetailScreen(clusterId: storyLine.clusterId),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand, // Stack will also fill the Card
          children: [
            if (storyLine.imageUrl.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: storyLine.imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: Colors.grey[200]),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: AppColors.primaryGreen.withAlpha(26), // 0.1 * 255 ≈ 26
                  child: Center(
                    child: Icon(
                      Icons.dashboard_customize_outlined,
                      size: 40,
                      color: AppColors.primaryGreen.withAlpha(
                        128,
                      ), // 0.5 * 255 ≈ 128
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(191), // 0.75 * 255 ≈ 191
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: Text(
                  _stripHtml(
                    storyLine.headline.isNotEmpty
                        ? storyLine.headline
                        : 'No Title Available',
                  ),
                  style: const TextStyle(
                    fontSize: 14.0, // Readable font size
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
