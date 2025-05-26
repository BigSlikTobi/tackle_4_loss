import 'package:flutter/foundation.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/story_line_timeline_entry.dart';

@immutable
class StoryLineTimelineResponse {
  final String clusterId;
  final List<StoryLineTimelineEntry> timelineEntries;
  final String? message;

  const StoryLineTimelineResponse({
    required this.clusterId,
    required this.timelineEntries,
    this.message,
  });

  factory StoryLineTimelineResponse.fromJson(Map<String, dynamic> json) {
    debugPrint(
      "[StoryLineTimelineResponse.fromJson] Raw JSON keys: ${json.keys.toList()}",
    );

    final timelineData =
        json['timeline_entries'] as List<dynamic>? ??
        json['timeline_data'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];

    debugPrint(
      "[StoryLineTimelineResponse.fromJson] Found timeline data with ${timelineData.length} items",
    );

    final List<StoryLineTimelineEntry> entries =
        timelineData
            .whereType<Map<String, dynamic>>()
            .map((item) => StoryLineTimelineEntry.fromJson(item))
            .toList();

    // Sort by date, newest first for chronological display
    entries.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1; // Place nulls at the end
      if (b.createdAt == null) return -1; // Place nulls at the end
      return b.createdAt!.compareTo(
        a.createdAt!,
      ); // Descending order (newest first)
    });

    debugPrint(
      "[StoryLineTimelineResponse.fromJson] Parsed and sorted ${entries.length} timeline entries for cluster ${json['cluster_id'] ?? 'unknown'}",
    );

    return StoryLineTimelineResponse(
      clusterId: json['cluster_id']?.toString() ?? '',
      timelineEntries: entries,
      message: json['message'] as String?,
    );
  }

  bool get isEmpty => timelineEntries.isEmpty;
  bool get isNotEmpty => timelineEntries.isNotEmpty;
  int get length => timelineEntries.length;
}
