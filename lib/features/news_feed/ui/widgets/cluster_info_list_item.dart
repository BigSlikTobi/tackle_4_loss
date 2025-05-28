// lib/features/news_feed/ui/widgets/cluster_info_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/features/news_feed/data/cluster_info.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';

class ClusterInfoListItem extends ConsumerWidget {
  final ClusterInfo cluster;

  const ClusterInfoListItem({super.key, required this.cluster});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentLocale = ref.watch(localeNotifierProvider);

    final headlineToShow = cluster.getLocalizedHeadline(
      currentLocale.languageCode,
    );
    final imageUrl = cluster.primaryImageUrl;
    final updatedAtDate = cluster.updatedAt;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          if (cluster.clusterId.isEmpty) {
            debugPrint(
              "[ClusterInfoListItem onTap ERROR] Cluster ID is empty. Cannot navigate.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Cluster ID is invalid.")),
            );
            return;
          }
          debugPrint(
            "[ClusterInfoListItem onTap] Navigating to /cluster/${cluster.clusterId}",
          );
          context.push('/cluster/${cluster.clusterId}');
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child:
                      imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Container(color: Colors.grey[200]),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            memCacheHeight: 180,
                            memCacheWidth: 180,
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.dashboard_customize_outlined,
                              color: Colors.grey[500],
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headlineToShow,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (updatedAtDate != null)
                          Text(
                            "Updated: ${DateFormat.yMd(currentLocale.languageCode).format(updatedAtDate)}",
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        const Spacer(),
                        Chip(
                          label: Text(
                            "Story",
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.primary.withAlpha(
                            30,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 0,
                          ),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
