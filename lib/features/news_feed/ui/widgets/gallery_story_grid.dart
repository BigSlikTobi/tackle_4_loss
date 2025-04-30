// lib/features/news_feed/ui/widgets/gallery_story_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:tackle_4_loss/core/theme/app_colors.dart';
import 'package:tackle_4_loss/features/news_feed/data/mapped_cluster_story.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/cluster_story_detail.dart';

class GalleryStoryGrid extends ConsumerStatefulWidget {
  final List<MappedClusterStory> stories;

  const GalleryStoryGrid({super.key, required this.stories});

  @override
  ConsumerState<GalleryStoryGrid> createState() => _GalleryStoryGridState();
}

class _GalleryStoryGridState extends ConsumerState<GalleryStoryGrid> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If we're within 300px of the bottom, try to load more
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final notifier = ref.read(clusterStoriesProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        debugPrint(
          'GalleryStoryGrid: Near end of grid, loading more stories...',
        );
        notifier.fetchNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(clusterStoriesProvider.notifier);
    final isLoadingMore = notifier.isLoadingMore;
    final stories = widget.stories;
    debugPrint(
      'GalleryStoryGrid: received stories.length = [32m${stories.length}[0m',
    );

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(2.0), // Reduced padding from 4.0 to 2.0
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Changed from 4 to 3 items per row
        childAspectRatio: 0.7,
        crossAxisSpacing: 2, // Reduced from 4 to 2
        mainAxisSpacing: 2, // Reduced from 4 to 2
      ),
      itemCount: isLoadingMore ? stories.length + 1 : stories.length,
      itemBuilder: (context, index) {
        if (index >= stories.length) {
          // Show loading indicator at the end
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final story = stories[index];
        return GalleryStoryItem(
          fullStories: stories,
          story: story,
          initialIndex: index,
          heroTag: 'story-${story.id}',
        );
      },
    );
  }
}

class GalleryStoryItem extends ConsumerWidget {
  final List<MappedClusterStory>
  fullStories; // full cluster story list for detail view
  final MappedClusterStory story;
  final int initialIndex;
  final String heroTag;

  const GalleryStoryItem({
    super.key,
    required this.fullStories,
    required this.story,
    required this.initialIndex,
    required this.heroTag,
  });

  // Helper function to get image URL with fallback
  String? get _imageUrl => story.primaryImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final headlineToShow = story.getLocalizedHeadline(locale.languageCode);

    return Hero(
      tag: heroTag,
      transitionOnUserGestures: true,
      createRectTween:
          (Rect? begin, Rect? end) =>
              MaterialRectArcTween(begin: begin!, end: end!),
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        // Inflate with a bounce using easeOutBack curve
        final Hero toHero = toHeroContext.widget as Hero;
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: toHero.child,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Slightly reduced radius
        ),
        elevation: 2, // Reduced elevation for smaller cards
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Debug the tapped story and initial index
              debugPrint(
                'GalleryStoryItem tap -> storyId=${story.id}, initialIndex=$initialIndex, heroTag=$heroTag',
              );
              // Use MaterialPageRoute so Hero animation works correctly
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          ClusterStoryDetailScreen(
                            stories: fullStories,
                            initialIndex: initialIndex,
                          ),
                  transitionDuration: const Duration(milliseconds: 375),
                  reverseTransitionDuration: const Duration(milliseconds: 375),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    // Use Hero for the transition; no extra visuals
                    return child;
                  },
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                if (_imageUrl != null && _imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[300]),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey[500],
                            size: 20,
                          ), // Reduced icon size
                        ),
                  )
                else
                  Container(
                    color: AppColors.primaryGreen,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: 30,
                      ), // Reduced logo size
                    ),
                  ),

                // Gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withAlpha(204)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Headline text at bottom
                Positioned(
                  bottom: 4, // Reduced padding
                  left: 4,
                  right: 4,
                  child: Text(
                    headlineToShow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11, // Reduced font size for smaller cards
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign:
                        TextAlign
                            .center, // Center-aligned for better layout in small cards
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
