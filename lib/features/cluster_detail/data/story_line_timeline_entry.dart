import 'package:flutter/foundation.dart';

@immutable
class StoryLineTimelineEntry {
  final String id;
  final String clusterId;
  final DateTime? createdAt;
  final String headline;
  final String content;
  final String source;

  const StoryLineTimelineEntry({
    required this.id,
    required this.clusterId,
    this.createdAt,
    required this.headline,
    required this.content,
    required this.source,
  });

  factory StoryLineTimelineEntry.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final createdAtValue = json['created_at'];

    if (createdAtValue != null) {
      if (createdAtValue is String) {
        parsedDate = DateTime.tryParse(createdAtValue);
      } else if (createdAtValue is int) {
        // Handle timestamp (assuming milliseconds)
        parsedDate = DateTime.fromMillisecondsSinceEpoch(
          createdAtValue.toString().length == 10
              ? createdAtValue * 1000
              : createdAtValue,
        );
      }
    }

    return StoryLineTimelineEntry(
      id: json['id']?.toString() ?? '',
      clusterId: json['cluster_id']?.toString() ?? '',
      createdAt: parsedDate,
      headline: json['headline'] as String? ?? 'No Headline',
      content: json['content'] as String? ?? 'No Content',
      // Prefer 'source_name', fallback to 'source', then default
      source:
          (json['source_name'] as String?)?.trim().isNotEmpty == true
              ? json['source_name'] as String
              : (json['source'] as String?)?.trim().isNotEmpty == true
              ? json['source'] as String
              : 'Unknown Source',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryLineTimelineEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
