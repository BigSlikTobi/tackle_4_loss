import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart'; // Import new model
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/providers/navigation_provider.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';

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
    final int? representativeArticleId =
        cluster.representativeArticleIdForNavigation;

    // --- FIX: Wrap Card in AspectRatio ---
    return AspectRatio(
      aspectRatio:
          1.0, // Makes the card square. Adjust as needed (e.g., 4/3 for landscape-ish)
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        child: InkWell(
          onTap: () {
            if (representativeArticleId != null) {
              debugPrint(
                "Tapped Cluster Grid Item ${cluster.clusterId}. Navigating to detail for Article ID: $representativeArticleId",
              );
              ref.read(currentDetailArticleIdProvider.notifier).state =
                  representativeArticleId;
            } else {
              debugPrint(
                "Tapped Cluster Grid Item ${cluster.clusterId}, but no representative article ID for navigation.",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot open details for this story yet.'),
                ),
              );
            }
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
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.dashboard_customize_outlined,
                        size: 40,
                        color: AppColors.primaryGreen.withOpacity(0.5),
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
                        Colors.black.withOpacity(0.75),
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
                          color: Colors.black.withOpacity(0.5),
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
    // --- End FIX ---
  }
}
