import 'package:flutter/foundation.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/cluster_timeline_entry.dart';

@immutable
class ClusterTimelineResponse {
  final String timelineName;
  final List<ClusterTimelineEntry> timelineData;

  const ClusterTimelineResponse({
    required this.timelineName,
    required this.timelineData,
  });

  factory ClusterTimelineResponse.fromJson(Map<String, dynamic> json) {
    var timelineDataFromJson = json['timeline_data'] as List<dynamic>? ?? [];
    List<ClusterTimelineEntry> entryList =
        timelineDataFromJson
            .map(
              (i) => ClusterTimelineEntry.fromJson(i as Map<String, dynamic>),
            )
            .toList();

    // Sort by date, oldest first for timeline display
    entryList.sort((a, b) {
      final dateA = a.date;
      final dateB = b.date;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // Place nulls at the end
      if (dateB == null) return -1; // Place nulls at the end
      return dateA.compareTo(dateB); // Ascending
    });

    debugPrint(
      "[ClusterTimelineResponse.fromJson] Parsed and sorted ${entryList.length} timeline entries. First entry date: ${entryList.isNotEmpty ? entryList.first.dateString : 'N/A'}",
    );

    return ClusterTimelineResponse(
      timelineName: json['timeline_name'] as String? ?? 'Unnamed Timeline',
      timelineData: entryList,
    );
  }
}
