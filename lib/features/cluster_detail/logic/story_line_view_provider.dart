// File: lib/features/cluster_detail/logic/story_line_view_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_view_data.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_view_service.dart';

// Provider for the StoryLineViewService
final storyLineViewServiceProvider = Provider<StoryLineViewService>((ref) {
  return StoryLineViewService();
});

// Provider for fetching story line view data by view ID and language code
final storyLineViewProvider = FutureProvider.autoDispose.family<
  StoryLineViewData,
  ({int viewId, String languageCode, String? clusterId})
>((ref, params) async {
  final service = ref.read(storyLineViewServiceProvider);
  return service.getStoryLineView(
    storyLineViewId: params.viewId,
    languageCode: params.languageCode,
    clusterId: params.clusterId,
  );
});

// Provider to track loading states for specific view IDs
final storyLineViewLoadingProvider = StateProvider.autoDispose
    .family<bool, int>((ref, viewId) {
      return false;
    });

// Provider to cache fetched story line view data
final storyLineViewCacheProvider = StateProvider.autoDispose
    .family<StoryLineViewData?, int>((ref, viewId) {
      return null;
    });
