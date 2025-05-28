// lib/features/news_feed/ui/widgets/story_line_grid_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:tackle_4_loss/features/news_feed/data/story_line_item.dart';
import 'package:flutter/foundation.dart';
import 'package:tackle_4_loss/core/theme/app_colors.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileLayoutBreakpoint = 960.0;
    final bool useMobileLayout =
        !kIsWeb || (kIsWeb && screenWidth <= mobileLayoutBreakpoint);

    if (useMobileLayout) {
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
        child: InkWell(
          onTap: () {
            if (storyLine.clusterId.isEmpty) {
              debugPrint(
                "[StoryLineGridItem onTap ERROR] Cluster ID is empty. Cannot navigate.",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Error: Story line ID is invalid."),
                ),
              );
              return;
            }
            debugPrint(
              "[StoryLineGridItem onTap] Navigating to /cluster/${storyLine.clusterId}",
            );
            context.push('/cluster/${storyLine.clusterId}');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Web/Tablet Specific Layout
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          if (storyLine.clusterId.isEmpty) {
            debugPrint(
              "[StoryLineGridItem onTap ERROR] Cluster ID is empty. Cannot navigate.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Story line ID is invalid.")),
            );
            return;
          }
          debugPrint(
            "[StoryLineGridItem onTap] Navigating to /cluster/${storyLine.clusterId}",
          );
          context.push('/cluster/${storyLine.clusterId}');
        },
        child: Stack(
          fit: StackFit.expand,
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
                  color: AppColors.primaryGreen.withAlpha(26),
                  child: Center(
                    child: Icon(
                      Icons.dashboard_customize_outlined,
                      size: 40,
                      color: AppColors.primaryGreen.withAlpha(128),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withAlpha(191)],
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
                    fontSize: 14.0,
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
