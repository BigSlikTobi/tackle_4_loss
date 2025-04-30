import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/news_feed/logic/news_feed_provider.dart';
import 'package:tackle_4_loss/features/news_feed/ui/widgets/gallery_story_grid.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  Future<void> _handleRefresh() async {
    debugPrint("NewsFeedScreen refresh triggered.");
    // Invalidate the non-family provider
    ref.invalidate(clusterStoriesProvider);

    // Optionally reset selection
    ref.read(galleryViewModeProvider.notifier).state = GalleryViewMode.gallery;
    ref.read(selectedGalleryItemIndexProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the cluster stories data
    final clusterStoriesAsyncValue = ref.watch(clusterStoriesProvider);

    // Always show gallery grid; tapping a card navigates to detail screen
    return Scaffold(
      // AppBar is handled by MainNavigationWrapper
      body: RefreshIndicator(
        // Wrap with RefreshIndicator
        onRefresh: _handleRefresh,
        // Use when to handle loading, error, data states
        child: clusterStoriesAsyncValue.when(
          data: (stories) {
            // Data loaded successfully
            // Check if the list is empty after fetching
            if (stories.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: const Center(
                        child: Text('No cluster stories found.'),
                      ),
                    ),
                  );
                },
              );
            }

            return GalleryStoryGrid(stories: stories);
          },
          // Show full-screen loading indicator on initial fetch
          loading: () => const LoadingIndicator(),
          // Show full-screen error message on initial fetch error
          error: (error, stackTrace) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ErrorMessageWidget(
                          message:
                              'Failed to load cluster stories: ${error.toString()}',
                          onRetry: () => ref.invalidate(clusterStoriesProvider),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
