import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_timeline_service.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_timeline_response.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_timeline_entry.dart';

// Provider for the StoryLineTimelineService
final storyLineTimelineServiceProvider = Provider<StoryLineTimelineService>((
  ref,
) {
  return StoryLineTimelineService();
});

// Provider for fetching story line timeline data
final storyLineTimelineProvider = FutureProvider.autoDispose
    .family<StoryLineTimelineResponse, String>((ref, clusterId) async {
      if (clusterId.isEmpty) {
        throw Exception('Cluster ID is empty');
      }

      final service = ref.watch(storyLineTimelineServiceProvider);
      return service.getTimelineByClusterId(clusterId);
    });

// Provider to track the currently selected timeline entry
final selectedStoryLineTimelineEntryProvider =
    StateProvider<StoryLineTimelineEntry?>((ref) => null);
