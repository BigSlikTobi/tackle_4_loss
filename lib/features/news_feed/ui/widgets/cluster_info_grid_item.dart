// File: lib/features/news_feed/ui/widgets/cluster_info_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
// REMOVE: import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
// --- ADD IMPORT FOR CLUSTER DETAIL SCREEN ---

class ClusterInfoGridItem extends ConsumerWidget {
  final ClusterInfo cluster;

  const ClusterInfoGridItem({super.key, required this.cluster});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final headlineToShow = cluster.getLocalizedHeadline(
      currentLocale.languageCode,
    );
    final imageUrl = cluster.primaryImageUrl;

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
              "Tapped Cluster Grid Item ${cluster.clusterId} (Mobile). Navigating to Cluster Detail Screen.",
            );
            context.push('/cluster/${cluster.clusterId}');
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
                        imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) =>
                                      Container(color: AppColors.grey200),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: AppColors.grey200,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.grey400,
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
                        headlineToShow,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          // color: theme.colorScheme.onSurface, // Using default onSurface color
                        ),
                        maxLines: 3, // Allow more lines for headline
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
          // --- MODIFIED NAVIGATION ---
          debugPrint(
            "Tapped Cluster Grid Item ${cluster.clusterId}. Navigating to Cluster Detail Screen.",
          );
          context.push('/cluster/${cluster.clusterId}');
          // --- END MODIFIED NAVIGATION ---
        },
        child: Stack(
          fit: StackFit.expand, // Stack will also fill the Card
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: AppColors.grey200),
                  errorWidget:
                      (context, url, error) => Container(
                        color: AppColors.grey200,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.grey400,
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
                  headlineToShow,
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withAlpha(128), // 0.5 * 255 ≈ 128
                        offset: const Offset(1, 1),
                      ),
                    ],
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
