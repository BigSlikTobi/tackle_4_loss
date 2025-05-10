import 'package:flutter/foundation.dart';

@immutable
class ArticlePreview {
  final int id;
  final String englishHeadline;
  final String germanHeadline;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? teamId;
  final String status;
  final int? source;

  const ArticlePreview({
    required this.id,
    required this.englishHeadline,
    required this.germanHeadline,
    required this.status,
    this.imageUrl,
    this.createdAt,
    this.teamId,
    this.source,
  });

  factory ArticlePreview.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.tryParse(json['createdAt']);
      } catch (e) {
        debugPrint(
          "[ArticlePreview.fromJson] Error parsing date: ${json['createdAt']} - $e",
        );
      }
    }

    // --- DEBUGGING THE 'source' FIELD ---
    final dynamic sourceValue = json['source'];
    int? parsedSource;
    if (sourceValue is int) {
      parsedSource = sourceValue;
    } else if (sourceValue != null) {
      debugPrint(
        "[ArticlePreview.fromJson] ID: ${json['id']} - 'source' field found but is not an int. Value: '$sourceValue', Type: ${sourceValue.runtimeType}",
      );
    } else {
      debugPrint(
        "[ArticlePreview.fromJson] ID: ${json['id']} - 'source' field is null or not found in JSON.",
      );
    }
    // --- END DEBUGGING ---

    return ArticlePreview(
      id:
          json['id'] as int? ??
          0, // Added default for safety if id is also missing
      englishHeadline: json['englishHeadline'] as String? ?? '',
      germanHeadline: json['germanHeadline'] as String? ?? '',
      imageUrl: json['Image'] as String?,
      createdAt: parsedDate,
      teamId: json['teamId'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN', // Added default
      source: parsedSource, // Use the debugged parsedSource
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticlePreview &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          source == other.source;

  @override
  int get hashCode => id.hashCode ^ source.hashCode;
}
