import 'package:flutter/foundation.dart';

// Data model for a source within a cluster article
class ClusterSource {
  final String name;
  final String createdAtStr;

  ClusterSource({required this.name, required this.createdAtStr});

  factory ClusterSource.fromJson(Map<String, dynamic> json) {
    return ClusterSource(
      name: json['name'] as String? ?? 'Unknown Source',
      createdAtStr: json['created_at'] as String? ?? '',
    );
  }

  DateTime? get createdAt {
    if (createdAtStr.isNotEmpty) {
      // Attempt to parse as ISO8601, then as int (milliseconds or seconds)
      DateTime? parsedDate = DateTime.tryParse(createdAtStr);
      if (parsedDate != null) return parsedDate.toLocal();

      final intTimestamp = int.tryParse(createdAtStr);
      if (intTimestamp != null && intTimestamp != 0) {
        if (createdAtStr.length == 10) {
          // Likely seconds
          return DateTime.fromMillisecondsSinceEpoch(
            intTimestamp * 1000,
          ).toLocal();
        } else if (createdAtStr.length == 13) {
          // Likely milliseconds
          return DateTime.fromMillisecondsSinceEpoch(intTimestamp).toLocal();
        }
      }
    }
    return null;
  }
}

// Data model for the cluster article
class ClusterArticle {
  final String clusterArticleId;
  final String createdAtStr;
  final String englishHeadline;
  final String englishSummary;
  final String englishContent;
  final String? imageUrl;
  final List<ClusterSource> sources;
  final String deHeadline;
  final String deSummary; // New field
  final String deContent; // New field

  ClusterArticle({
    required this.clusterArticleId,
    required this.createdAtStr,
    required this.englishHeadline,
    required this.englishSummary,
    required this.englishContent,
    this.imageUrl,
    required this.sources,
    required this.deHeadline,
    required this.deSummary, // New parameter
    required this.deContent, // New parameter
  });

  factory ClusterArticle.fromJson(Map<String, dynamic> json) {
    var sourcesList = <ClusterSource>[];
    if (json['sources'] != null && json['sources'] is List) {
      try {
        sourcesList =
            (json['sources'] as List)
                .map((s) => ClusterSource.fromJson(s as Map<String, dynamic>))
                .toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing sources: $e");
        }
        // Keep sourcesList empty or handle error as appropriate
      }
    }
    return ClusterArticle(
      clusterArticleId: json['cluster_article_id'] as String? ?? '',
      createdAtStr: json['created_at'] as String? ?? '',
      englishHeadline: json['english_headline'] as String? ?? 'No Headline',
      englishSummary: json['english_summary'] as String? ?? '',
      englishContent: json['english_content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      sources: sourcesList,
      deHeadline: json['de_headline'] as String? ?? '',
      deSummary: json['de_summary'] as String? ?? '', // Parse new field
      deContent: json['de_content'] as String? ?? '', // Parse new field
    );
  }

  DateTime? get createdAt {
    if (createdAtStr.isNotEmpty) {
      // Attempt to parse as ISO8601, then as int (milliseconds or seconds)
      DateTime? parsedDate = DateTime.tryParse(createdAtStr);
      if (parsedDate != null) return parsedDate.toLocal();

      final intTimestamp = int.tryParse(createdAtStr);
      if (intTimestamp != null && intTimestamp != 0) {
        // Heuristic: if it's a 10-digit number, assume seconds since epoch.
        // If it's a 13-digit number, assume milliseconds since epoch.
        if (createdAtStr.length == 10) {
          return DateTime.fromMillisecondsSinceEpoch(
            intTimestamp * 1000,
          ).toLocal();
        } else if (createdAtStr.length == 13) {
          return DateTime.fromMillisecondsSinceEpoch(intTimestamp).toLocal();
        }
        // Add other heuristics if needed, e.g. for very small numbers that might be valid dates
      }
    }
    return null;
  }
}
