// File: lib/features/cluster_detail/ui/cluster_detail_screen.dart
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/story_line_view_provider.dart'; // For story line view data fetching
import 'package:tackle_4_loss/features/cluster_detail/logic/story_line_timeline_provider.dart'; // For story line timeline provider
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_view_data.dart'; // For StoryLineViewData
import 'package:tackle_4_loss/features/cluster_detail/ui/widgets/story_line_timeline_widget.dart';
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart';
import 'package:tackle_4_loss/core/extensions/color_scheme_extensions.dart';

// Data Models for the story line API response
class StoryLineView {
  final String view;
  final int id;

  StoryLineView({required this.view, required this.id});

  factory StoryLineView.fromJson(Map<String, dynamic> json) {
    return StoryLineView(
      view: json['view'] as String? ?? '',
      id: json['id'] as int? ?? 0,
    );
  }
}

class StoryLineDetail {
  final String headline;
  final String summary;
  final String content;
  final String? imageUrl;
  final List<StoryLineView> views;

  StoryLineDetail({
    required this.headline,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.views,
  });

  factory StoryLineDetail.fromJson(Map<String, dynamic> json) {
    var viewsList = <StoryLineView>[];
    if (json['views'] != null && json['views'] is List) {
      viewsList =
          (json['views'] as List)
              .map((v) => StoryLineView.fromJson(v as Map<String, dynamic>))
              .toList();
    }
    return StoryLineDetail(
      headline: json['headline'] as String? ?? 'No Headline',
      summary: json['summary'] as String? ?? 'No Summary',
      content: json['content'] as String? ?? 'No Content',
      imageUrl: json['image_url'] as String?,
      views: viewsList,
    );
  }
}

// Provider for fetching story line details
final storyLineDetailProvider = FutureProvider.autoDispose.family<
  StoryLineDetail,
  ({String clusterId, String languageCode})
>((ref, params) async {
  if (params.clusterId.isEmpty) {
    throw Exception('Cluster ID is empty');
  }

  debugPrint(
    "[storyLineDetailProvider] Fetching story line details for clusterId: ${params.clusterId}, languageCode: ${params.languageCode}",
  );

  // Use Supabase client instead of direct HTTP calls
  final supabaseClient = Supabase.instance.client;

  try {
    final response = await supabaseClient.functions.invoke(
      'story_lines_by_id',
      method: HttpMethod.get,
      queryParameters: {
        'language_code': params.languageCode,
        'cluster_id': params.clusterId,
      },
    );

    debugPrint("[storyLineDetailProvider] Response status: ${response.status}");

    if (response.status != 200) {
      var errorData = response.data;
      String errorMessage = 'Status code ${response.status}';
      if (errorData is Map && errorData.containsKey('error')) {
        errorMessage += ': ${errorData['error']}';
      } else if (errorData != null) {
        errorMessage += ': ${errorData.toString()}';
      }
      debugPrint('[storyLineDetailProvider] Error response data: $errorData');
      throw Exception('Failed to load story line details: $errorMessage');
    }

    if (response.data == null) {
      debugPrint("[storyLineDetailProvider] Response data is null");
      return StoryLineDetail.fromJson({}); // Return a default/empty object
    }

    final jsonData = response.data;
    if (jsonData is Map<String, dynamic> && jsonData['data'] != null) {
      debugPrint(
        "[storyLineDetailProvider] Successfully parsed story line details",
      );
      return StoryLineDetail.fromJson(jsonData['data'] as Map<String, dynamic>);
    } else {
      debugPrint(
        "[storyLineDetailProvider] Invalid response format, returning default",
      );
      return StoryLineDetail.fromJson({}); // Return a default/empty object
    }
  } on FunctionException catch (e) {
    debugPrint(
      '[storyLineDetailProvider] Supabase FunctionException: ${e.details}',
    );
    final errorMessage = e.details?.toString() ?? e.toString();
    throw Exception('Error invoking story_lines_by_id function: $errorMessage');
  } catch (e) {
    debugPrint('[storyLineDetailProvider] Generic error: $e');
    throw Exception('Failed to load story line details: $e');
  }
});

// Provider to manage the content shown in the overlay
final _overlayContentProvider =
    StateProvider.autoDispose<Map<String, dynamic>?>((ref) => null);

// Provider to track "read more" state for story line views
final _showFullContentProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

String _stripHtml(String htmlText) {
  final RegExp bareTags = RegExp(
    r'<[^>]*>',
    multiLine: true,
    caseSensitive: true,
  );
  return htmlText.replaceAll(bareTags, '');
}

class ClusterDetailScreen extends ConsumerWidget {
  final String clusterId;

  const ClusterDetailScreen({super.key, required this.clusterId});

  /// Handles tapping on a story line view dot
  /// Fetches the view content dynamically and shows it in the overlay
  void _handleViewDotTap(WidgetRef ref, int viewId, String languageCode) async {
    // Show loading state immediately
    ref.read(_overlayContentProvider.notifier).state = {
      'type': 'view',
      'id': viewId,
      'loading': true,
    };

    debugPrint(
      "[ClusterDetailScreen] Handling view dot tap for viewId: $viewId, clusterId: $clusterId, languageCode: $languageCode",
    );

    try {
      // Fetch the story line view data with cluster ID for validation
      final viewData = await ref.read(
        storyLineViewProvider((
          viewId: viewId,
          languageCode: languageCode,
          clusterId: clusterId,
        )).future,
      );

      debugPrint(
        "[ClusterDetailScreen] Successfully fetched view data for viewId: $viewId. Content length: ${viewData.content.length}",
      );

      // Update overlay with fetched content
      ref.read(_overlayContentProvider.notifier).state = {
        'type': 'view',
        'id': viewId,
        'loading': false,
        'viewData': viewData, // Store the full view data object
      };
    } catch (error) {
      debugPrint(
        "[ClusterDetailScreen] Error fetching view data for viewId: $viewId, clusterId: $clusterId - $error",
      );

      // Handle error state
      ref.read(_overlayContentProvider.notifier).state = {
        'type': 'view',
        'id': viewId,
        'loading': false,
        'error': error.toString(),
        'viewData': null, // No view data available due to error
      };
    }
  }

  Widget _buildDot(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
    // Color? color, // Removed: color is now handled internally using primary theme color
  }) {
    final theme = Theme.of(context);
    // Use primary color for non-selected, slightly brighter/different for selected
    final dotColor = theme.colorScheme.primary.withAlpha(
      191, // 0.75 * 255 = 191.25 ≈ 191
    ); // Base primary color for dots
    final selectedDotColor =
        theme.colorScheme.primary; // Full primary for selected
    final glowColor = theme.colorScheme.primary.withAlpha(
      120,
    ); // Softer glow, adjust alpha for intensity

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 4.0,
        ), // Adjust margin as needed
        width: isSelected ? 18.0 : 15.0, // Slightly larger when selected
        height: isSelected ? 18.0 : 15.0,
        decoration: BoxDecoration(
          color: isSelected ? selectedDotColor : dotColor,
          shape: BoxShape.circle,
          border:
              isSelected
                  ? Border.all(
                    color: theme.colorScheme.onPrimary.withAlpha(
                      204,
                    ), // 0.8 * 255 = 204
                    width: 1.5,
                  ) // Border for selected
                  : Border.all(
                    color: theme.colorScheme.primary.withAlpha(
                      128,
                    ), // 0.5 * 255 = 127.5 ≈ 128
                    width: 0.5,
                  ), // Subtle border for non-selected
          boxShadow: [
            // Glow effect
            BoxShadow(
              color: glowColor,
              blurRadius: isSelected ? 10.0 : 6.0,
              spreadRadius: isSelected ? 2.5 : 1.5,
            ),
            BoxShadow(
              // Inner subtle shadow for depth if desired
              color: Colors.black.withAlpha(25), // 0.1 * 255 = 25.5 ≈ 25
              blurRadius: 2.0,
              spreadRadius: 0.5,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    WidgetRef ref,
    StoryLineDetail storyDetail,
  ) {
    final overlayState = ref.watch(_overlayContentProvider);
    if (overlayState == null) {
      return const SizedBox.shrink();
    }

    String? contentToShow;
    bool isLoading = false;
    StoryLineViewData? viewData;

    if (overlayState['type'] == 'content') {
      contentToShow = storyDetail.content;
    } else if (overlayState['type'] == 'view') {
      // Check if we have cached view data
      viewData = overlayState['viewData'] as StoryLineViewData?;
      if (viewData != null) {
        // We have the full view data with headline, introduction, and content
        isLoading = false;
      } else {
        // Show loading state while fetching
        isLoading = overlayState['loading'] == true;
        contentToShow = isLoading ? null : "Error loading content.";
      }
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          // Reset the read more state when closing overlay
          ref.read(_showFullContentProvider.notifier).state = false;
          ref.read(_overlayContentProvider.notifier).state = null;
        },
        child: Container(
          color: Colors.black.withAlpha(191), // 0.75 * 255 = 191.25 ≈ 191
          child: Center(
            child: GestureDetector(
              onTap: () {}, // To prevent taps on content from closing overlay
              child: Container(
                width:
                    kIsWeb
                        ? screenWidth * 0.9
                        : screenWidth * 0.95, // Use more width
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.85,
                  minHeight: screenHeight * 0.3,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            // Reset the read more state when closing overlay
                            ref.read(_showFullContentProvider.notifier).state =
                                false;
                            ref.read(_overlayContentProvider.notifier).state =
                                null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child:
                            isLoading
                                ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text("Loading story line view..."),
                                    ],
                                  ),
                                )
                                : viewData != null
                                ? _buildStoryLineViewContent(
                                  context,
                                  ref,
                                  viewData,
                                )
                                : Html(
                                  data:
                                      contentToShow ?? "No content available.",
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize.medium,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                    ),
                                    "p": Style(lineHeight: LineHeight.em(1.5)),
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the story line view content with headline, introduction/content, and read more button
  Widget _buildStoryLineViewContent(
    BuildContext context,
    WidgetRef ref,
    StoryLineViewData viewData,
  ) {
    final showFullContent = ref.watch(_showFullContentProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline (always visible)
        if (viewData.headline.isNotEmpty)
          Text(
            _stripHtml(viewData.headline),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

        if (viewData.headline.isNotEmpty) const SizedBox(height: 16),

        // Introduction or Content based on state
        Html(
          data:
              showFullContent
                  ? (viewData.content.isNotEmpty
                      ? viewData.content
                      : viewData.introduction)
                  : viewData.introduction,
          style: {
            "body": Style(
              fontSize: FontSize.medium,
              color: textTheme.bodyLarge?.color,
              lineHeight: LineHeight.em(1.5),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "p": Style(margin: Margins.only(bottom: 12.0)),
            "a": Style(
              color: theme.colorScheme.primary,
              textDecoration: TextDecoration.underline,
            ),
          },
        ),

        // Read more / Show less button
        if (viewData.content.isNotEmpty &&
            viewData.content != viewData.introduction) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(_showFullContentProvider.notifier).state =
                  !showFullContent;
            },
            child: Text(showFullContent ? "Show less..." : "Read more..."),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final storyLineParams = (
      clusterId: clusterId,
      languageCode: currentLocale.languageCode,
    );
    final storyLineDetailAsync = ref.watch(
      storyLineDetailProvider(storyLineParams),
    );
    final textTheme = Theme.of(context).textTheme;
    final overlayState = ref.watch(_overlayContentProvider);

    return Scaffold(
      appBar: const GlobalAppBar(),
      body: WebDetailWrapper(
        child: storyLineDetailAsync.when(
          data: (storyDetail) {
            final headlineToShow = _stripHtml(storyDetail.headline);

            return Stack(
              // Stack remains the outermost for the overlay
              children: [
                Column(
                  // Main layout column: Headline then Content+Timeline Row
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      // Headline Padding
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        headlineToShow,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign:
                            TextAlign
                                .start, // Ensures it tries to use available width
                      ),
                    ),
                    Expanded(
                      // This Expanded will contain the Row for content and timeline
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            // Central content area (dots, image, summary)
                            flex: kIsWeb ? 3 : 4,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dots section
                                  if (storyDetail.content.isNotEmpty ||
                                      storyDetail.views.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          if (storyDetail.content.isNotEmpty)
                                            _buildDot(
                                              context,
                                              isSelected:
                                                  overlayState?['type'] ==
                                                  'content',
                                              onTap: () {
                                                ref
                                                    .read(
                                                      _overlayContentProvider
                                                          .notifier,
                                                    )
                                                    .state = {
                                                  'type': 'content',
                                                };
                                              },
                                            ),
                                          ...storyDetail.views.map(
                                            (view) => _buildDot(
                                              context,
                                              isSelected:
                                                  overlayState?['type'] ==
                                                      'view' &&
                                                  overlayState?['id'] ==
                                                      view.id,
                                              onTap:
                                                  () => _handleViewDotTap(
                                                    ref,
                                                    view.id,
                                                    currentLocale.languageCode,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 16.0,
                                  ), // Space between dots and image
                                  // Image section
                                  Builder(
                                    builder: (context) {
                                      Widget imageContent;
                                      if (storyDetail.imageUrl != null &&
                                          storyDetail.imageUrl!.isNotEmpty) {
                                        final imageWidget = CachedNetworkImage(
                                          imageUrl: storyDetail.imageUrl!,
                                          fit:
                                              kIsWeb
                                                  ? BoxFit.fitWidth
                                                  : BoxFit.contain,
                                          width: double.infinity,
                                          placeholder:
                                              (context, url) => AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: Center(
                                                  child: LoadingIndicator(),
                                                ),
                                              ),
                                          errorWidget:
                                              (
                                                context,
                                                url,
                                                error,
                                              ) => AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                  ),
                                                ),
                                              ), // This closes the AspectRatio for errorWidget
                                        ); // This closes CachedNetworkImage() and ends the 'final imageWidget = ...;' statement.
                                        if (kIsWeb) {
                                          imageContent = imageWidget;
                                        } else {
                                          imageContent = AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: imageWidget,
                                          );
                                        }
                                      } else {
                                        imageContent = AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        child: imageContent,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  // Summary section
                                  Html(
                                    data:
                                        storyDetail.summary.isNotEmpty
                                            ? storyDetail.summary
                                            : "No summary available.",
                                  ),
                                  const SizedBox(height: 24.0),

                                  // Story Line Timeline section
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.withValues(1.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                      // Removed border as requested
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        SizedBox(
                                          height: 60,
                                          child: Consumer(
                                            builder: (context, ref, child) {
                                              final storyTimelineAsync = ref
                                                  .watch(
                                                    storyLineTimelineProvider(
                                                      clusterId,
                                                    ),
                                                  );

                                              return storyTimelineAsync.when(
                                                data: (timelineResponse) {
                                                  if (timelineResponse
                                                      .timelineEntries
                                                      .isNotEmpty) {
                                                    return StoryLineTimelineWidget(
                                                      entries:
                                                          timelineResponse
                                                              .timelineEntries,
                                                      clusterId: clusterId,
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child: Text(
                                                        'No timeline data available',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                loading:
                                                    () => const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                error:
                                                    (error, stack) => Center(
                                                      child: Text(
                                                        'Error loading timeline: $error',
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildOverlay(context, ref, storyDetail), // Overlay on top
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (err, stack) {
            return Center(
              child: ErrorMessageWidget(
                message: "Failed to load details: ${err.toString()}",
              ),
            );
          },
        ),
      ),
    );
  }
}
