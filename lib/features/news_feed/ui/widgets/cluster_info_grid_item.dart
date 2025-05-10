// File: lib/features/news_feed/ui/widgets/cluster_info_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
// REMOVE: import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';
// --- ADD IMPORT FOR CLUSTER DETAIL SCREEN ---
import 'package:tackle_4_loss/features/cluster_detail/ui/cluster_detail_screen.dart';

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
    // REMOVE: final int? representativeArticleId = cluster.representativeArticleIdForNavigation;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        child: InkWell(
          onTap: () {
            // --- MODIFIED NAVIGATION ---
            debugPrint(
              "Tapped Cluster Grid Item ${cluster.clusterId}. Navigating to Cluster Detail Screen.",
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) =>
                        ClusterDetailScreen(clusterId: cluster.clusterId),
              ),
            );
            // --- END MODIFIED NAVIGATION ---
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
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
                    color: AppColors.primaryGreen.withAlpha(
                      26,
                    ), // 0.1 * 255 ≈ 26
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
      ),
    );
  }
}
