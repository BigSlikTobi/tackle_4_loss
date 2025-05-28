// lib/features/cluster_detail/ui/cluster_detail_screen.dart
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart'; // Import Share Plus
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle_4_loss/core/providers/locale_provider.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart';
import 'package:tackle_4_loss/core/widgets/loading_indicator.dart';
import 'package:tackle_4_loss/core/widgets/error_message.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/story_line_view_provider.dart';
import 'package:tackle_4_loss/features/cluster_detail/logic/story_line_timeline_provider.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_view_data.dart';
import 'package:tackle_4_loss/features/cluster_detail/ui/widgets/story_line_timeline_widget.dart';
import 'package:tackle_4_loss/core/widgets/web_detail_wrapper.dart';
// Corrected import

// Re-define kAppBaseUrl here or import from a shared constants file
const String kAppBaseUrl = "https://tackle4loss.com";

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

final storyLineDetailProvider = FutureProvider.autoDispose.family<
  StoryLineDetail,
  ({String clusterId, String languageCode})
>((ref, params) async {
  if (params.clusterId.isEmpty) throw Exception('Cluster ID is empty');
  debugPrint(
    "[storyLineDetailProvider] Fetching story line details for clusterId: ${params.clusterId}, languageCode: ${params.languageCode}",
  );
  final supabaseClient = Supabase.instance.client;
  try {
    final response = await supabaseClient.functions.invoke(
      'story_lines_by_id', // Assumes this EF provides StoryLineDetail structure
      method: HttpMethod.get,
      queryParameters: {
        'language_code': params.languageCode,
        'cluster_id': params.clusterId,
      },
    );
    if (response.status != 200) {
      var errorData = response.data;
      String errorMessage = 'Status code ${response.status}';
      if (errorData is Map && errorData.containsKey('error')) {
        errorMessage += ': ${errorData['error']}';
      } else if (errorData != null) {
        errorMessage += ': ${errorData.toString()}';
      }
      throw Exception('Failed to load story line details: $errorMessage');
    }
    if (response.data == null) return StoryLineDetail.fromJson({});
    final jsonData = response.data;
    if (jsonData is Map<String, dynamic> && jsonData['data'] != null) {
      return StoryLineDetail.fromJson(jsonData['data'] as Map<String, dynamic>);
    } else {
      return StoryLineDetail.fromJson({});
    }
  } catch (e) {
    throw Exception('Failed to load story line details: $e');
  }
});

final _overlayContentProvider =
    StateProvider.autoDispose<Map<String, dynamic>?>((ref) => null);
final _showFullContentProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

String _stripHtmlStoryDetail(String htmlText) {
  // Renamed to avoid conflict
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

  void _handleViewDotTap(WidgetRef ref, int viewId, String languageCode) async {
    ref.read(_overlayContentProvider.notifier).state = {
      'type': 'view',
      'id': viewId,
      'loading': true,
    };
    debugPrint(
      "[ClusterDetailScreen] Handling view dot tap for viewId: $viewId, clusterId: $clusterId, languageCode: $languageCode",
    );
    try {
      final viewData = await ref.read(
        storyLineViewProvider((
          viewId: viewId,
          languageCode: languageCode,
          clusterId: clusterId,
        )).future,
      );
      ref.read(_overlayContentProvider.notifier).state = {
        'type': 'view',
        'id': viewId,
        'loading': false,
        'viewData': viewData,
      };
    } catch (error) {
      ref.read(_overlayContentProvider.notifier).state = {
        'type': 'view',
        'id': viewId,
        'loading': false,
        'error': error.toString(),
        'viewData': null,
      };
    }
  }

  Widget _buildDot(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final dotColor = theme.colorScheme.primary.withAlpha(191);
    final selectedDotColor = theme.colorScheme.primary;
    final glowColor = theme.colorScheme.primary.withAlpha(120);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: isSelected ? 18.0 : 15.0,
        height: isSelected ? 18.0 : 15.0,
        decoration: BoxDecoration(
          color: isSelected ? selectedDotColor : dotColor,
          shape: BoxShape.circle,
          border:
              isSelected
                  ? Border.all(
                    color: theme.colorScheme.onPrimary.withAlpha(204),
                    width: 1.5,
                  )
                  : Border.all(
                    color: theme.colorScheme.primary.withAlpha(128),
                    width: 0.5,
                  ),
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: isSelected ? 10.0 : 6.0,
              spreadRadius: isSelected ? 2.5 : 1.5,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(25),
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
    if (overlayState == null) return const SizedBox.shrink();
    String? contentToShow;
    bool isLoading = false;
    StoryLineViewData? viewData;
    if (overlayState['type'] == 'content') {
      contentToShow = storyDetail.content;
    } else if (overlayState['type'] == 'view') {
      viewData = overlayState['viewData'] as StoryLineViewData?;
      isLoading = viewData == null && overlayState['loading'] == true;
      if (!isLoading && viewData == null)
        contentToShow = "Error loading content.";
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          ref.read(_showFullContentProvider.notifier).state = false;
          ref.read(_overlayContentProvider.notifier).state = null;
        },
        child: Container(
          color: Colors.black.withAlpha(191),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: kIsWeb ? screenWidth * 0.9 : screenWidth * 0.95,
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.85,
                  minHeight: screenHeight * 0.3,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
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
        if (viewData.headline.isNotEmpty)
          Text(
            _stripHtmlStoryDetail(viewData.headline),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        if (viewData.headline.isNotEmpty) const SizedBox(height: 16),
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
        if (viewData.content.isNotEmpty &&
            viewData.content != viewData.introduction) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed:
                () =>
                    ref.read(_showFullContentProvider.notifier).state =
                        !showFullContent,
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
      appBar: GlobalAppBar(
        // Add Share button
        actions: storyLineDetailAsync.maybeWhen(
          data: (storyDetail) {
            final shareTitle = _stripHtmlStoryDetail(
              storyDetail.headline.isNotEmpty
                  ? storyDetail.headline
                  : "Tackle4Loss Story Line",
            );
            final String appClusterUrl = "$kAppBaseUrl/cluster/$clusterId";
            return [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  debugPrint(
                    "[ClusterDetailScreen Share] Sharing title: '$shareTitle', URL: '$appClusterUrl'",
                  );
                  Share.share('$shareTitle\n\n$appClusterUrl');
                },
                tooltip: 'Share Story Line',
              ),
            ];
          },
          orElse: () => [],
        ),
      ),
      body: WebDetailWrapper(
        child: storyLineDetailAsync.when(
          data: (storyDetail) {
            final headlineToShow = _stripHtmlStoryDetail(storyDetail.headline);
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        headlineToShow,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: kIsWeb ? 3 : 4,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  const SizedBox(height: 16.0),
                                  Builder(
                                    builder: (context) {
                                      Widget imageContent;
                                      if (storyDetail.imageUrl != null &&
                                          storyDetail.imageUrl!.isNotEmpty) {
                                        imageContent = CachedNetworkImage(
                                          imageUrl:
                                              storyDetail.imageUrl! /* ... */,
                                        );
                                        // Placeholder for actual CachedNetworkImage setup from your code
                                        imageContent = ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: storyDetail.imageUrl!,
                                            fit:
                                                kIsWeb
                                                    ? BoxFit.fitWidth
                                                    : BoxFit.contain,
                                            width: double.infinity,
                                            placeholder:
                                                (context, url) =>
                                                    const AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Center(
                                                        child:
                                                            LoadingIndicator(),
                                                      ),
                                                    ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                        );
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
                                      return imageContent; // Removed redundant ClipRRect
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  Html(
                                    data:
                                        storyDetail.summary.isNotEmpty
                                            ? storyDetail.summary
                                            : "No summary available.",
                                  ),
                                  const SizedBox(height: 24.0),
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(
                                        1.0,
                                      ), // Use surface color with full opacity
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        SizedBox(
                                          height:
                                              60, // Fixed height for timeline
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
                _buildOverlay(context, ref, storyDetail),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error:
              (err, stack) => Center(
                child: ErrorMessageWidget(
                  message: "Failed to load details: ${err.toString()}",
                ),
              ),
        ),
      ),
    );
  }
}
